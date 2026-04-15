# 14. SDK And Version Policy

## Scope

Harness reliability depends on tested toolchains, not whatever Flutter version happens to be newest on a machine.

This document defines the V1 SDK manager and version policy.

Status:

- implemented for `create`, `init`, `add`, `remove`, `gen`, and `upgrade`
- `.info/agentic.yaml` now persists resolved `manager` / `version` plus manifest-facing `preferred_manager` / `preferred_version`

## Policy Summary

- support explicit Flutter manager modes: `system`, `fvm`, `puro`
- record both the preferred toolchain request and the resolved executable toolchain in `.info/agentic.yaml`
- prefer newest tested, not newest available
- fall back deterministically when the preferred manager is unavailable
- fail clearly when no executable Flutter SDK can be resolved

## Manager Strategy

### `system`

Use the Flutter binary already on `PATH`.

Best for:

- simple local setups
- CI images with a pinned Flutter toolchain

### `fvm`

Use repo-local FVM-managed Flutter versions.

Best for:

- teams that want per-repo version pinning
- contributors who already standardize on FVM

### `puro`

Use Puro-managed Flutter toolchains when teams prefer its workspace and channel workflow.

Best for:

- teams already invested in Puro
- repos that need explicit workspace-aware toolchain selection

## Resolution Rules

The adapter now resolves Flutter in this order:

1. preferred manager from manifest or CLI input if executable
2. repo-local inferred manager if executable
3. system Flutter as the final validated fallback
4. fail if no executable Flutter SDK exists

Resolved values are the public contract used by generated surfaces and scripts. Preferred values stay in manifest/runtime metadata so agents can reason about the user’s intent without cluttering README-level docs.

## Version Policy

V1 support language should be:

- "newest tested stable Flutter version"
- optionally "plus one previously tested stable minor" when the repo can prove it

V1 should not say:

- "latest Flutter"
- "always current"
- "works on any recent SDK"

Those claims are not reliable enough for a harness-first product.

## Upgrade Policy

Version movement should be explicit:

1. `agentic_base` release validates a newer Flutter version
2. package docs and manifest schema are updated with the newly tested version window
3. `agentic_base upgrade` syncs generator-owned surfaces without silently jumping SDKs
4. moving to a newer SDK requires an explicit repo-level action and fresh evidence

## Failure Rules

Generated repos should fail clearly when:

- no executable manager can be resolved through the fallback order
- a pinned upgrade contract resolves to a different version/channel than declared
- manager metadata and actual executable disagree after resolution
- release-preflight would use an unverified toolchain

## Security And Reliability Notes

- silent toolchain jumps are reliability regressions
- CI images must be pinned to tested toolchains
- human operators still own account-level upgrades for store or signing dependencies

## References

- [`docs/13-flutter-adapter-boundaries.md`](./13-flutter-adapter-boundaries.md)
- [`plans/reports/brainstorm-260414-1119-harness-first-flutter-agentic-base-direction.md`](../plans/reports/brainstorm-260414-1119-harness-first-flutter-agentic-base-direction.md)
- [`plans/reports/researcher-260414-1046-agent-ready-codebase-synthesis.md`](../plans/reports/researcher-260414-1046-agent-ready-codebase-synthesis.md)
