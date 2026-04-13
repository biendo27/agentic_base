# Phase 06 — Close The Loop With Verification And Docs

## Context Links

- [Plan Overview](./plan.md)
- [Phases 01-05](./plan.md)
- [System Architecture Doc](../../docs/04-system-architecture.md)
- [Code Standards Doc](../../docs/03-code-standards.md)

## Overview

- Priority: P1
- Status: Completed
- Goal: make the new contracts provable in CI and documented truthfully for maintainers and generated-project users.
- Result: expanded automated coverage now exercises unit, integration, smoke, provider, native, and module/analytics paths, with root docs synced for the touched docs set.

## Key Insights

- Current smoke coverage is provider-aware but state-blind.
- Current tests validate inventory and parsing more than rollback, provenance, or live module integration.
- Docs already emphasize honesty; this phase must keep README/docs aligned with the implemented reality.

## Requirements

- Keep test layers separate: unit, integration, generated-app smoke, provider contract, native gate.
- Avoid a full `state x provider x native` cross product in CI.
- Update README and root docs to reflect actual parity, metadata provenance, and module integration behavior.
- Update roadmap/changelog/system architecture after implementation lands.

## Architecture

Verification matrix:
1. Unit: config schema, provenance resolver, state profiles, transaction planner.
2. Integration: `create --modules` rollback, `add/remove` round-trips, `init` retrofit fixtures, feature brick generation.
3. Generated-app smoke: one create flow per state on the primary CI provider.
4. Provider contract: GitHub/GitLab output validation on a baseline state.
5. Native gate: keep one pinned macOS generated-app job separate from the state matrix.

## Related Code Files

- Modify: `test/src/config/**`
- Modify: `test/src/cli/commands/**`
- Modify: `test/src/modules/**`
- Modify: `test/integration/generated_app_smoke_test.dart`
- Modify: `.github/workflows/ci.yml`
- Modify: `README.md`
- Modify: `docs/01-project-overview-pdr.md`
- Modify: `docs/03-code-standards.md`
- Modify: `docs/04-system-architecture.md`
- Modify: `docs/05-project-roadmap.md`
- Modify: `docs/project-changelog.md` if present

## Implementation Steps

1. Add unit tests for schema/provenance/profile behavior.
2. Add integration tests for rollback, retrofit, and live module seams.
3. Split smoke/provider/native checks into targeted CI jobs.
4. Update docs to describe actual behavior and remaining non-goals.
5. Mark prior related roadmap work complete and record this hardening pass.

## Todo List

- [x] unit matrix complete
- [x] integration matrix complete
- [x] smoke/provider/native split complete
- [x] docs updated
- [x] root docs synced

## Success Criteria

- CI fails if any state branch leaks foreign runtime artifacts.
- CI fails if config provenance disappears or rollback leaves partial state.
- Docs make no promise the repo does not actually keep.

## Risk Assessment

- Residual: keep provider/state/native matrices orthogonal so CI stays bounded.
- Residual: keep root docs aligned with contract changes after merge.

## Security / Integrity Considerations

- Regression gates protect trust in generated outputs and retrofit metadata.
- Truthful docs reduce operator error and false assumptions in downstream projects.

## Rollback Plan

- Keep new CI jobs additive first; only make them required once green.
- If matrix time is too high, trim duplication before trimming coverage classes.

## Next Steps

- After implementation, this phase closes the follow-up plan and syncs evergreen docs.
