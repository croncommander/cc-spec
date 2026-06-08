# cc-spec Instructions

## Tests and compatibility

- Every new feature must include its own contract tests or executable validation
  in the implementing repositories in the same coordinated change.
- Add valid and invalid examples for new fields and behaviors.
- Breaking changes require a new major protocol version. Preserve compatibility
  for agent registration, cron discovery, desired-state delivery, cron
  synchronization, execution-report delivery, acknowledgements, and logs after
  the first public release. Before release, direct cutovers are allowed when all
  implementations, tests, installers, and deployment configuration change
  together.
- Do not rewrite a published/current contract to hide an incompatible change.

## Security and SOC 2 readiness

- Security is release-blocking. Specifications must define authentication and
  authorization boundaries, tenant binding, replay/idempotency behavior,
  payload limits, secret handling, error behavior, and safe retry semantics.
- Review every protocol change for downgrade, replay, injection, confused
  deputy, cross-workspace access, denial-of-service, and sensitive-data
  disclosure risks.
- We are not currently undergoing a SOC 2 audit and must not claim compliance.
  Keep contracts versioned, reviewable, traceable, and suitable as future
  control evidence from day zero.

## UX and documentation

- Keep specifications simple, practical, unambiguous, and implementation-aware
  without leaking private internals.
- Examples and diagrams should use a restrained Bauhaus-inspired visual
  language: clear hierarchy, geometric structure, purposeful color, minimal
  decoration, and accessibility before novelty.
