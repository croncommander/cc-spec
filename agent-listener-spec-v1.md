# CronCommander Agent–Listener Specification

This document defines the contract between **agents** and the **listener** service.  
The listener is responsible for maintaining persistent connections, authenticating agents, and delivering instructions.

---

## Terminology

- **Agent**: A lightweight binary running on a host, responsible for reporting status and executing instructions.
- **Listener**: The backend service managing WebSocket connections from agents.
- **Dashboard**: The web UI for operators (separate service).

---

## Connection Lifecycle

### Registration

When an agent connects, it must send a `hello` message:

```json
{
  "type": "hello",
  "agent_id": "uuid",
  "hostname": "server1.example.com",
  "version": "1.0.0",
  "capabilities": ["cron", "metrics"]
}
```

The listener responds with:

```json
{
  "type": "hello_ack",
  "status": "ok",
  "session_id": "uuid"
}
```

---

## Authentication

Agents authenticate using either:

- Token-based authentication (JWT or signed secret)
- Mutual TLS (optional, for stronger identity)

### Login message

```json
{
  "type": "login",
  "agent_id": "uuid",
  "token": "signed-jwt"
}
```

Response:

```json
{
  "type": "login_ack",
  "status": "ok"
}
```

---

## Heartbeats

Agents must send a heartbeat every 30 seconds:

```json
{
  "type": "heartbeat",
  "agent_id": "uuid",
  "timestamp": 1734326400
}
```

Listener responds with:

```json
{
  "type": "heartbeat_ack",
  "status": "alive"
}
```

---

## Instruction Delivery

### Push

The listener pushes instructions only to agents with pending work:

```json
{
  "type": "instruction",
  "id": "instr-123",
  "payload": {
    "action": "run",
    "command": "cc-run --job backup"
  }
}
```

### Acknowledgment

Agents must acknowledge each instruction:

```json
{
  "type": "ack",
  "id": "instr-123",
  "status": "success"
}
```

---

## Error Handling

- Invalid message → error response with reason.
- Unauthorized agent → connection closed.
- Instruction failure → agent sends `ack` with `"status": "error"` and optional details.

---

## Message Types Summary

| Type            | Direction            | Purpose                          |
|-----------------|----------------------|----------------------------------|
| hello           | Agent → Listener     | Registration handshake           |
| hello_ack       | Listener → Agent     | Registration confirmation        |
| login           | Agent → Listener     | Authentication request           |
| login_ack       | Listener → Agent     | Authentication confirmation      |
| heartbeat       | Agent → Listener     | Liveness check                   |
| heartbeat_ack   | Listener → Agent     | Liveness confirmation            |
| instruction     | Listener → Agent     | Deliver work                     |
| ack             | Agent → Listener     | Confirm instruction result       |
| error           | Listener → Agent     | Report protocol error            |

---

## Transport & Security

- WebSockets (`wss://`) with TLS 1.2+.
- Optional mutual TLS for agent identity.
- All payloads encoded as JSON (YAML discouraged for performance).
