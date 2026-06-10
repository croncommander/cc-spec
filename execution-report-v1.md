# CronCommander Execution Report — v1.3

This document defines the execution reporting contract used by `cc-agent` to report job status to the CronCommander server.

## Overview

An **execution report** provides the complete result of a job run, including exit status, output logs, and security context.

---

## JSON Payload Structure

The execution report is the JSON body of the HTTP v2 execution-report endpoint.

### Required Fields

```json
{
  "jobId": "uuid-1234-5678",
  "command": "/bin/bash backup.sh",
  "exitCode": 0,
  "stdout": "Backup successful...",
  "stderr": "",
  "startTime": "2024-03-20T10:00:00Z",
  "durationMs": 1500,
  "executingUid": 1001,
  "executingUser": "cc-agent-user"
}
```

### Optional Fields

```json
{
  "warning": "Running as root (UID 0). Ensure this is intentional."
}
```

---

## Field Semantics

| Field | Type | Description |
|---|---|---|
| `jobId` | UUID (String) | Unique identifier of the CronJob definition. |
| `command` | String | The exact command line executed. |
| `exitCode` | Integer | Process exit code (0 = success, >0 = failure). |
| `stdout` | String | Standard output captured (capped at 256KB). |
| `stderr` | String | Standard error captured (capped at 256KB). |
| `startTime` | RFC3339 String | When the process execution began. |
| `durationMs` | Integer | Wall-clock duration in milliseconds. |
| `executingUid` | Integer | **(New in v1.3)** The Effective UID of the process. |
| `executingUser` | String | **(New in v1.3)** The username resolved from the UID. |
| `warning` | String | **(New in v1.3)** Security warnings (e.g., unexpected root execution). |

---

## Security Context (Dual-Mode)

In **User Mode**, `executingUid` should correspond to the unprivileged agent user (e.g., `cc-agent-user`).
In **System Mode**, `executingUid` will be `0` (root).

The `warning` field is populated by the agent if it detects a configuration mismatch (e.g., running as root when configured for User Mode).

---

## Transport

Execution reports are sent to
`POST /api/v2/agents/{agentId}/execution-reports` with an agent bearer token and
a stable UUID in the `Idempotency-Key` header. See
`agent-gateway-http-v2.md`.
