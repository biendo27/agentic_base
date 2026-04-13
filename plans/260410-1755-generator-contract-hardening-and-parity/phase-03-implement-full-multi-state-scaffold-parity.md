# Phase 03 — Implement Full Multi-State Scaffold Parity

## Context Links

- [Plan Overview](./plan.md)
- [Phase 01](./phase-01-lock-canonical-contract-model.md)
- [Phase 02](./phase-02-add-transactional-project-mutations.md)
- [Multi-State Scaffold Parity Research](../reports/researcher-260410-1743-multi-state-scaffold-parity.md)

## Overview

- Priority: P1
- Status: Completed
- Goal: make the generated app and feature scaffolds genuinely support `cubit`, `riverpod`, and `mobx` without cloning the brick families.
- Result: one state profile now drives cubit, riverpod, and mobx app/feature generation with contract checks and smoke coverage.

## Key Insights

- The current app brick hardcodes cubit in pubspec, bootstrap, docs, starter feature, and tests.
- The feature brick only emits cubit-shaped templates in both simple and full modes.
- `GeneratedProjectContract` and smoke coverage are state-blind, so drift is invisible.

## Requirements

- Keep one app brick and one feature brick.
- Branch only the files and content that truly differ by state: bootstrap, DI/app shell seams, starter presentation state, docs, and starter tests.
- Keep router, flavors, i18n, and shared domain/data layers common.
- Make `GeneratedProjectContract` state-aware with required and forbidden paths/content.

## Architecture

Data flow:
1. `ScaffoldStateProfile` emits Mason vars (`is_cubit`, `is_riverpod`, `is_mobx`, DI mode, bootstrap mode).
2. `ProjectGenerator` and `FeatureGenerator` pass those vars into one app brick and one feature brick.
3. Generated contract validates state-specific presence/absence rules.
4. Smoke tests assert no cross-state leftovers.

## Related Code Files

- Modify: `lib/src/generators/project_generator.dart`
- Modify: `lib/src/generators/feature_generator.dart`
- Modify: `lib/src/generators/generated_project_contract.dart`
- Modify: `lib/src/config/state_config.dart`
- Modify: `bricks/agentic_app/**`
- Modify: `bricks/agentic_feature/**`
- Modify: `test/integration/generated_app_smoke_test.dart`

## Implementation Steps

1. Add profile-driven Mason vars.
2. Branch app-brick `pubspec.yaml`, bootstrap/app shell seams, starter home feature, docs, and tests.
3. Branch feature-brick simple/full presentation and test skeletons.
4. Extend generated-project contract with state-aware required/forbidden assertions.
5. Add per-state scaffold tests and smoke coverage.

## Todo List

- [x] App brick parity complete
- [x] Feature brick parity complete
- [x] State-aware generated contract complete
- [x] Per-state create smoke coverage complete
- [x] No cubit leftovers in riverpod/mobx outputs

## Success Criteria

- `create --state cubit|riverpod|mobx` yields analyzable/testable apps.
- `feature` scaffolds state-specific presentation code for both simple and full modes.
- Riverpod output has no `flutter_bloc`, `BlocProvider`, or `getIt` leftovers unless explicitly required by shared non-state code.
- MobX output has no cubit leftovers and includes its codegen/runtime contract.

## Risk Assessment

- Residual: any future state family must update the profile, brick vars, and contract checks together.
- Residual: keep branching local to differing files; avoid whole-brick copies.

## Security / Integrity Considerations

- Honest scaffold parity prevents the CLI from advertising unsupported generation modes.
- State-aware contracts stop false-positive smoke tests from blessing broken outputs.

## Rollback Plan

- Preserve the single-brick architecture even if one state branch needs temporary simplification.
- If one state branch fails, do not silently map it back to cubit; block the release until the branch is real.

## Next Steps

- Phase 05 will plug module integration into the new state-specific seams.
