# CronCommander Execution Report — v1

This document defines the public execution reporting contract used by
`cc-run`, `cc-agent`, and the CronCommander server.

This contract is stable within major version **v1**.
Breaking changes require a new major version.

---

## Overview

A **job execution** represents a single attempt to run a command scheduled by cron.

Execution reports are emitted by `cc-run`, optionally forwarded or enriched by `cc-agent`,
and ingested by the CronCommander server.

---

## Execution lifecycle

1. A scheduled job is invoked by cron
2. `cc-run` executes the command
3. Execution metadata is collected
4. An execution report is generated
5. The report is transmitted to the agent or server

---

## Execution report (canonical payload)

### Required fields

```json
{
  "version": "1",
  "execution_id": "uuid",
  "timestamp": "RFC3339",
  "command": "string",
  "exit_code": 0,
  "duration_ms": 1234,
  "status": "success | failure | timeout",
  "host": "string"
}
```

---

## Field semantics

| Field | Description |
|------|-------------|
| `version` | Specification version |
| `execution_id` | Unique identifier for this execution |
| `timestamp` | Execution start time (RFC3339) |
| `command` | Command executed by `cc-run` |
| `exit_code` | Process exit code |
| `duration_ms` | Wall-clock execution duration |
| `status` | Derived execution status |
| `host` | Host or container identifier |

---

## Optional fields

```json
{
  "job_name": "string",
  "schedule": "cron expression",
  "environment": {
    "key": "value"
  },
  "stderr_truncated": true
}
```

Optional fields:
- Must not change the meaning of required fields
- May be ignored by receivers
- Must preserve backward compatibility

---

## Transport

Execution reports may be transmitted using different mechanisms, including but not limited to:

- Local IPC
- HTTP(S)
- File-based handoff

Transport mechanisms are **out of scope** for this specification.
Only payload structure and semantics are defined here.

---

## Versioning rules

- New optional fields may be added within v1
- Required fields may not be removed or repurposed
- Semantic changes require a new major version

---

## Component responsibilities

### `cc-run`
- Generates execution reports
- Must conform to this specification

### `cc-agent`
- Forwards and may enrich execution reports
- Must not alter required field semantics

### CronCommander server
- Accepts and validates execution reports
- Acts as the system of record
