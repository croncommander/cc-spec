# cc-spec

This repository contains the versioned interface specifications for the
CronCommander project. It is private while the next agent transport is being
designed.

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

- `agent-listener-spec-v1.md` — Current WebSocket v1 agent/gateway contract
- `execution-report-v1.md` — Canonical format for reporting cron job executions

These documents describe the implemented WebSocket protocol. The proposed HTTPS
polling transport will be defined as HTTP v2. Because there is no production
agent fleet, implementations will cut over directly before launch; v1 remains
as historical context rather than a compatibility requirement.

## Versioning

Breaking changes to a specification require a new major version.
Minor, backward-compatible additions may be made within a version.

The repository can be made public again after the HTTP contract is stable and
the documents have been reviewed for internal implementation details.

## Project

Part of the **CronCommander** project.

Website: https://croncommander.com
