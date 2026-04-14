# 14. SDK And Version Policy

## Scope

Harness reliability depends on tested toolchains, not whatever Flutter version happens to be newest on a machine.

This document defines the V1 SDK manager and version policy.

Status:

- design target for future implementation waves
- current generator does not yet persist this full SDK policy in `.info/agentic.yaml`

## Policy Summary

- support explicit Flutter manager modes: `system`, `fvm`, `puro`
- record the selected manager and tested version in `.info/agentic.yaml`
- prefer newest tested, not newest available
- fail clearly when the local toolchain does not match the declared contract

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

The future adapter should resolve Flutter in this order:

1. manifest-declared manager and version
2. repo-local manager config if the manifest allows inference during migration
3. system Flutter as an explicit fallback only when documented and validated

`doctor` should report both the declared contract and the discovered local toolchain.

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

- declared manager is unavailable
- local SDK version falls outside the tested window
- manager metadata and actual executable disagree
- release-preflight would use an unverified toolchain

## Security And Reliability Notes

- silent toolchain jumps are reliability regressions
- CI images must be pinned to tested toolchains
- human operators still own account-level upgrades for store or signing dependencies

## References

- [`docs/13-flutter-adapter-boundaries.md`](./13-flutter-adapter-boundaries.md)
- [`plans/reports/brainstorm-260414-1119-harness-first-flutter-agentic-base-direction.md`](../plans/reports/brainstorm-260414-1119-harness-first-flutter-agentic-base-direction.md)
- [`plans/reports/researcher-260414-1046-agent-ready-codebase-synthesis.md`](../plans/reports/researcher-260414-1046-agent-ready-codebase-synthesis.md)
