# cc-spec

This public repository contains the versioned interface specifications for the
CronCommander project. HTTP v2 is the current agent transport.

The specifications defined here describe the stable contracts between CronCommander components,
such as job runners, agents, and the central server. These documents are intended to be:

- Implementation-agnostic
- Stable within a major version
- A single source of truth for cross-component behavior

## Scope

This repository defines **what crosses process or network boundaries**.

It intentionally does **not** define:
- Internal server architecture
- Storage schemas
- Internal credential storage or issuance implementation
- Retry or transport implementations

## Current specifications

- `agent-gateway-http-v2.md` — Current HTTPS agent/gateway contract
- `execution-report-v1.md` — Canonical format for reporting cron job executions

`agent-listener-spec-v1.md` is the historical WebSocket contract.

## Versioning

Breaking changes to a specification require a new major version.
Minor, backward-compatible additions may be made within a version.

Only stable, reviewed cross-component contracts belong here. Private planning,
implementation details, and product backlog material remain in `cc-server`.

## Project

Part of the **CronCommander** project.

Website: https://croncommander.com
