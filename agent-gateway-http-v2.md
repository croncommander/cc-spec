# CronCommander Agent-Gateway HTTP API v2

## 1. Scope

This specification defines the request-oriented contract between `cc-agent`
and `cc-listener`. HTTP v2 directly replaces WebSocket v1 before the first
production launch.

All production requests use HTTPS and JSON. Plain HTTP is permitted only for
explicitly configured local development.

## 2. Common behavior

- Base URL example: `https://gateway.croncommander.com`
- Request and response media type: `application/json`
- Maximum request body: 1 MiB
- Agent authorization: `Authorization: Bearer <agent-token>`
- Successful report responses mean the database transaction committed.
- Error responses use `{ "error": "description" }`.
- Credentials never appear in URLs or logs.

## 3. Registration

`POST /api/v2/agents/register`

Header:

```http
X-CC-API-Key: <workspace-bootstrap-key>
```

Request:

```json
{
  "hostname": "worker-01",
  "os": "Ubuntu 24.04",
  "executionMode": "user",
  "isRoot": false
}
```

Response:

```json
{
  "agentId": "11111111-1111-4111-8111-111111111111",
  "agentToken": "cca_example",
  "pollIntervalSeconds": 60,
  "pollJitterSeconds": 30
}
```

Registering an existing hostname in the same workspace renews its metadata and
rotates its agent token. The workspace key is a bootstrap credential; poll and
report requests use only the agent-scoped token.

## 4. Heartbeat and desired-state poll

`POST /api/v2/agents/{agentId}/poll`

Request:

```json
{
  "manifestVersion": "previous-sha256-version"
}
```

Changed response:

```json
{
  "manifestVersion": "current-sha256-version",
  "changed": true,
  "jobs": [
    {
      "jobId": "22222222-2222-4222-8222-222222222222",
      "cronExpression": "*/5 * * * *",
      "command": "/opt/jobs/collect-metrics"
    }
  ]
}
```

Unchanged response:

```json
{
  "manifestVersion": "current-sha256-version",
  "changed": false,
  "jobs": []
}
```

Every authenticated poll updates persisted agent liveness. Agents wait a
uniformly random 30-90 seconds between successful polls and randomize their
initial delay.

## 5. Execution reports

`POST /api/v2/agents/{agentId}/execution-reports`

Header:

```http
Idempotency-Key: 33333333-3333-4333-8333-333333333333
```

The body is the canonical payload in `execution-report-v1.md`.

First successful persistence returns HTTP `201`:

```json
{
  "executionId": "44444444-4444-4444-8444-444444444444",
  "duplicate": false
}
```

Retrying the same event ID for the same agent returns HTTP `200` with the
original execution ID and `"duplicate": true`.

The agent must write reports to its durable local spool before acknowledging
local receipt. It removes a report only after a `2xx` gateway response.
Transient failures use exponential backoff with jitter. Permanent `4xx`
payload rejections, except `401`, `408`, and `429`, may be quarantined for
operator inspection.

## 6. Status codes

| Status | Meaning |
|---|---|
| `200` | Registration, poll, or duplicate report succeeded |
| `201` | New execution report committed |
| `400` | Malformed request or idempotency key |
| `401` | Missing, invalid, or rotated credential |
| `409` | Agent limit reached or idempotency conflict |
| `413` | Request body exceeds the configured limit |
| `429` | Request throttled; retry with backoff |
| `5xx` | Transient gateway failure; retry with backoff |

On `401`, an agent clears its rejected scoped credential and re-registers using
the workspace bootstrap key.
