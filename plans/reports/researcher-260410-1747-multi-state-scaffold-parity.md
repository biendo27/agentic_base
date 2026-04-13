# Research Memo: Multi-State Scaffold Parity Regression Guards

Date: 2026-04-10

## Executive Summary

The repo already treats state as a first-class input in config and CLI plumbing: `StateConfig`, `CreateCommand`, `InitCommand`, `FeatureCommand`, and `ProjectContext` all carry `cubit`, `riverpod`, and `mobx`. The gap is the generated scaffold surface. Today the app brick and feature brick are still cubit-shaped, and the current contract/test net only proves flavor + CI-provider behavior, not state parity.

Best fit: keep the current public surface, keep one `agentic_app` brick and one `agentic_feature` brick, and add three internal state kits behind the existing `state_management` var. Do not split into three bricks. Do not full-cross-product state x provider in CI. Use a table-driven contract map and a 3-state smoke matrix instead.

## Source Basis

High-confidence local sources consulted:

- `README.md`
- `docs/03-code-standards.md`
- `docs/04-system-architecture.md`
- `lib/src/config/state_config.dart`
- `lib/src/generators/project_generator.dart`
- `lib/src/generators/feature_generator.dart`
- `lib/src/generators/generated_project_contract.dart`
- `lib/src/cli/commands/create_command.dart`
- `lib/src/cli/commands/init_command.dart`
- `lib/src/cli/commands/feature_command.dart`
- `bricks/agentic_app/brick.yaml`
- `bricks/agentic_feature/brick.yaml`
- `bricks/agentic_app/__brick__/**`
- `bricks/agentic_feature/__brick__/**`
- `test/src/**`
- `test/integration/generated_app_smoke_test.dart`
- `.github/workflows/ci.yml`

No external sources were needed; repo sources were enough.

## What Is True Today

- `create` already exposes `--state` with the 3 options in CLI docs and prompts.
- `init` already detects state from `pubspec.yaml` and persists `state_management`.
- `feature` already reads `state_management` from `.info/agentic.yaml`.
- `ProjectGenerator` and `FeatureGenerator` already pass `state_management` into Mason.
- The app brick is cubit-only in content: `pubspec.yaml`, `bootstrap.dart`, `app.dart`, home feature page/test/docs all hardcode Bloc/Cubit.
- The feature brick is cubit-only too, in both `simple` and full branches.
- `GeneratedProjectContract` validates base app/flavor/CI ownership only; no state assertions yet.
- CI currently smoke-tests create only, plus a separate GitLab native gate. No state matrix exists.

## Recommendation

### Ranked Options

1. **Recommended: one brick per generator, three state kits inside each, one shared state contract map**
   - Lowest duplication that still gives real parity.
   - Fits current repo shape: `StateConfig` is already the source of truth for packages/DI.
   - Lets cubit and mobx share the `get_it`/`injectable` spine; riverpod stays separate where it must.

2. **Not recommended: split into 3 app bricks and 3 feature bricks**
   - Fast to reason about, but template sprawl explodes.
   - Violates DRY, makes docs and tests drift.

3. **Not recommended: patch generated projects post hoc**
   - Hides parity behind shell logic.
   - Hard to verify, fragile, and expensive to debug.

### Shape of the solution

- Keep `state_management` as the only public selector.
- Add a small internal scaffold descriptor keyed by `StateConfig.values`.
- Use that descriptor to drive:
  - brick file selection/content,
  - state-aware contract assertions,
  - table-driven tests.
- Keep common files common. Only branch where the runtime model changes:
  - `pubspec.yaml`
  - app bootstrap/root widget
  - home feature page/state/store/provider
  - starter feature docs and tests

## Smallest Effective Regression Matrix

| Layer | Coverage | CI shape | Why this is enough |
|---|---|---:|---|
| Pure Dart unit/contract tests | all 3 states | 1 job | catches option drift, state detection, contract fragments, and pass-through wiring fast |
| End-to-end scaffold smoke | all 3 states | 3 matrix jobs | catches Mason/template/codegen regressions that unit tests cannot see |
| Native provider gate | existing GitLab macOS path | 1 job | keep orthogonal; do not multiply by state |

### Recommended matrix details

- One smoke job per state: `cubit`, `riverpod`, `mobx`.
- Each smoke job should do:
  1. `create` a project with that state.
  2. run `feature` once with `--simple`.
  3. run `feature` once with full structure.
  4. rerun the generated app's gen/lint/test pipeline.
  5. validate a state-aware contract helper.
- Do **not** add `provider x state` Cartesian jobs at first. That is the wrong axis to multiply.

## Contract Assertions To Add Or Update

### 1. CLI surface consistency

- `stateManagementOptions` must equal `StateConfig.values.map((s) => s.name)`.
- `CreateCommand` allowed states must stay in lockstep with `StateConfig`.
- `InitCommand` must resolve all 3 canonical pubspec patterns:
  - cubit -> `cubit`
  - riverpod -> `riverpod`
  - mobx -> `mobx`
- `FeatureCommand` must consume `state_management` from `.info/agentic.yaml`, not re-guess it.

### 2. Base project contract

Keep `GeneratedProjectContract` for app-level invariants:

- required shell files
- forbidden leftovers
- CI provider contract
- native flavor wiring

Add a separate state-aware contract helper instead of bloating the base contract:

- `pubspec.yaml` dependency set matches `StateConfig`
- app root files contain the correct state-root wrapper
- generated docs mention the selected state
- home feature starter files use the correct state kit

### 3. Feature contract

Assert the smallest useful shape, not whole-tree snapshots:

- `simple` branch:
  - correct state entrypoint file
  - page file
  - state/store/provider file
  - i18n stubs
- full branch:
  - correct state entrypoint file
  - module/spec
  - presentation/data/domain layout
  - i18n stubs

### 4. Docs/instructions parity

Assert fragments, not entire files.

- `README.md`
  - state-specific architecture line
  - run matrix stays correct
- `AGENTS.md`
  - correct state contract mention
  - no stale cubit-only wording for riverpod/mobx
- `CLAUDE.md`
  - same as above
- `docs/03-state-management.md`
  - correct state technology section
- `docs/06-testing-guide.md`
  - correct test harness per state

### 5. Test-harness parity

Use state-specific testing expectations:

- cubit -> `bloc_test`
- riverpod -> provider/container tests
- mobx -> store/action/observable tests

Do not use one generic test example for all 3; that hides real differences.

## Build / Codegen / DI / Router Impacts

| State | Build + codegen | DI root | Router impact | Test harness |
|---|---|---|---|---|
| cubit | `build_runner`, Freezed, injectable, auto_route, Slang | `get_it` + `injectable` | shared auto_route graph | `bloc_test` |
| riverpod | `build_runner`, Freezed, riverpod generator, auto_route, Slang | `ProviderScope` / provider-based DI | shared auto_route graph | provider/container tests |
| mobx | `build_runner`, Freezed, mobx_codegen, injectable, auto_route, Slang | `get_it` + `injectable` | shared auto_route graph | store/action tests |

Key point: router stays shared. State choice should only affect the root widget and feature presentation layer, not the route graph itself.

## Trade-Offs And Risk

- **Cubit**: lowest risk, baseline path, already proven.
- **MobX**: medium risk, because it can share `get_it`/`injectable`, but the presentation model and codegen are different.
- **Riverpod**: highest risk, because it changes the DI/root model, not just dependencies.

Main failure mode if we under-test: create passes, but feature generation or docs drift silently. The current create-only smoke would miss that.

## Phase Breakdown For Planning

### Phase 1: Contract model

- Add a small state scaffold spec keyed by `StateConfig`.
- Update tests to derive expectations from that spec.
- Add consistency checks between prompts, config, and CLI.

### Phase 2: App brick parity

- Make `agentic_app` state-aware.
- Branch `pubspec.yaml`, bootstrap/root widget, home feature starter, docs, and tests by state.
- Keep common router/theme/flavor files shared.

### Phase 3: Feature brick parity

- Make `agentic_feature` state-aware in both `simple` and full branches.
- Keep the `simple` axis orthogonal to the state axis.

### Phase 4: Smoke matrix

- Expand scaffold smoke to run once per state.
- Have each run create an app, scaffold features, rerun gen/lint/test, and validate the state contract.

### Phase 5: CI tightening

- Keep analyzer/format/unit tests as-is.
- Add the 3-state smoke matrix.
- Keep the existing macOS GitLab gate separate.

## File Groups Affected

- `lib/src/config/state_config.dart`
- `lib/src/tui/prompts.dart`
- `lib/src/cli/commands/create_command.dart`
- `lib/src/cli/commands/init_command.dart`
- `lib/src/cli/commands/feature_command.dart`
- `lib/src/generators/project_generator.dart`
- `lib/src/generators/feature_generator.dart`
- `lib/src/generators/generated_project_contract.dart`
- `bricks/agentic_app/brick.yaml`
- `bricks/agentic_feature/brick.yaml`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/**`
- `bricks/agentic_feature/__brick__/**`
- `test/src/config/state_config_test.dart`
- `test/src/tui/prompts_test.dart`
- `test/src/cli/commands/create_command_test.dart`
- `test/src/cli/commands/init_command_test.dart`
- `test/src/cli/commands/feature_command_test.dart` (new)
- `test/src/generators/project_generator_test.dart`
- `test/integration/generated_app_smoke_test.dart`
- `.github/workflows/ci.yml`

## Limitations

- I did not run full generation in this research pass, so the matrix cost estimate is inferred from source inspection, not measured wall time.
- I did not inspect every installable module template; if some modules assume cubit-only behavior, they may need a follow-up pass after scaffold parity lands.

## Unresolved Questions

- For Riverpod, should the starter use `ProviderScope` + `Notifier`/`AsyncNotifier`, or a thinner provider wrapper?
- For MobX, should the starter be a pure store/observer model, or keep a lightweight state union for consistency?
- Should `init` keep the current heuristic precedence on mixed dependency graphs, or move to an explicit state marker-first strategy later?
