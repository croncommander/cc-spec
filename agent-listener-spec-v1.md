# CronCommander Agent–Listener Specification v1.3

This document defines the WebSocket protocol between **cc-agent** and **cc-listener**.
The listener is responsible for maintaining persistent connections, authenticating agents, and orchestrating job execution.

---

## 1. Connection & Authentication

### Handshake
Agents connect via WebSocket to the listener URL (e.g., `ws://cc-listener:8081/agent`).
Authentication is performed via HTTP Headers during the initial upgrade request.

**Headers:**
- `X-CC-API-KEY`: The API key for authentication.

If valid, the connection is upgraded. If invalid, the server returns `401 Unauthorized`.

---

## 2. Protocol Messages

All messages are JSON objects with a `type` and a `payload`.

### 2.1 Registration
Immediately after connection, the agent sends a registration message to identify itself and its capabilities.

**Type:** `register`

**Payload:**
```json
{
  "hostname": "server-01",
  "os": "linux",
  "arch": "amd64",
  "tags": ["prod", "db"],
  "executionMode": "system",  // "user" or "system"
  "isRoot": true               // true if process effective UID is 0
}
```

*Note: The `executionMode` and `isRoot` fields inform the server about the agent's privilege level (Dual-Mode Model).*

### 2.2 Heartbeat
Agents send a heartbeat every 60 seconds (configurable) to maintain the connection.

**Type:** `heartbeat`

**Payload:** (Empty or Timestamp)
```json
{
  "timestamp": "2024-03-20T10:00:00Z"
}
```

### 2.3 Job Execution Instruction (Server -> Agent)
The server sends this message to trigger a job execution.

**Type:** `execute_job`

**Payload:**
```json
{
  "jobId": "uuid-123",
  "command": "backup.sh",
  "args": ["--full"],
  "timeout": 3600
}
```

### 2.4 Execution Report (Agent -> Server)
After running a job, the agent reports the result.

**Type:** `execution_report`

**Payload:**
```json
{
  "jobId": "uuid-123",
  "command": "backup.sh --full",
  "exitCode": 0,
  "stdout": "Backup complete...",
  "stderr": "",
  "startTime": "2024-03-20T10:00:00Z",
  "durationMs": 1500,
  "executingUid": 0,           // The UID that ran the process
  "executingUser": "root",     // The username that ran the process
  "warning": "Running as root..." // Optional security warning
}
```

### 2.5 Cron Refresh (Server -> Agent)
The server pushes the full list of active cron jobs for the agent to synchronize its local cron file.

**Type:** `cron_refresh`

**Payload:**
```json
[
  {
    "id": "job-uuid-1",
    "schedule": "0 0 * * *",
    "command": "/opt/scripts/daily.sh"
  },
  {
    "id": "job-uuid-2",
    "schedule": "*/5 * * * *",
    "command": "curl http://check.internal"
  }
]
```

*In **User Mode**, these are written to the user's crontab.*
*In **System Mode**, these are written to `/etc/cron.d/croncommander`.*

---

## 3. Dual-Mode Privilege Model

The protocol supports two operating modes for the agent:

1.  **User Mode (Default)**
    - Agent identifies with `executionMode: "user"`.
    - `isRoot` should be `false`.
    - Jobs are executed as the `cc-agent-user`.

2.  **System Mode (Opt-in)**
    - Agent identifies with `executionMode: "system"`.
    - `isRoot` is usually `true`.
    - Jobs are executed as `root` (UID 0).
    - If `isRoot` is true but mode is User, the UI displays a security warning.

---

## 4. Message Flow Summary

| Type             | Direction        | Purpose                          |
|------------------|------------------|----------------------------------|
| register         | Agent → Server   | Initial identification           |
| heartbeat        | Agent → Server   | Keep-alive                       |
| execute_job      | Server → Agent   | Ad-hoc execution request         |
| execution_report | Agent → Server   | Result of ad-hoc or cron job     |
| cron_refresh     | Server → Agent   | Sync local cron schedule         |

