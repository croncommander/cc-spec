# cc-spec

This repository contains the **public interface specifications** for the CronCommander project.

The specifications defined here describe the stable contracts between CronCommander components,
such as job runners, agents, and the central server. These documents are intended to be:

- Public and implementation-agnostic
- Stable within a major version
- A single source of truth for cross-component behavior

## Scope

This repository defines **what crosses process or network boundaries**.

It intentionally does **not** define:
- Internal server architecture
- Storage schemas
- Authentication mechanisms
- Retry or transport implementations

## Current specifications

- `execution-report-v1.md` — Canonical format for reporting cron job executions

## Versioning

Breaking changes to a specification require a new major version.
Minor, backward-compatible additions may be made within a version.

## Project

Part of the **CronCommander** project.

Website: https://croncommander.com
