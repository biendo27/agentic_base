# Multi-State Scaffold Parity Research Memo

Timestamp: 2026-04-10 17:43 Asia/Saigon
Scope: full parity for `cubit`, `riverpod`, and `mobx` across `create`, `init`, `feature`, app brick, feature brick, generated docs/tests, build/codegen, DI, router, and regression checks.

## Executive Summary

Current CLI surface already accepts the three state options, but the scaffold layer is still cubit-first. The public contract is there; the template contract is not.

Best fit here: keep one app brick and one feature brick, then make them state-aware through a small internal profile layer and Mason conditionals. Do not fork into three full bricks. That would create avoidable template sprawl, triple doc drift, and brittle maintenance.

Router, flavors, i18n, and shell scripts should stay shared. The state choice should only branch where the runtime model actually changes: bootstrap, DI, presentation state files, starter tests, and state-specific docs/examples.

Riverpod is the only branch that materially changes bootstrap/DI shape. Cubit and MobX can keep the current get_it/injectable style. That keeps the architecture coherent without inventing a second build pipeline.

## What The Repo Already Has

- `create` already accepts `--state cubit|riverpod|mobx` and forwards it into `ProjectGenerator`. See [create_command.dart](/Users/biendh/base/lib/src/cli/commands/create_command.dart) and [project_generator.dart](/Users/biendh/base/lib/src/generators/project_generator.dart).
- `init` already detects state management and writes `state_management` into `.info/agentic.yaml`, but the detector is string-based and should become dependency-based. See [init_command.dart](/Users/biendh/base/lib/src/cli/commands/init_command.dart) and [agentic_config.dart](/Users/biendh/base/lib/src/config/agentic_config.dart).
- `feature` already forwards `state_management` into `FeatureGenerator`, but the feature brick is still cubit-only. See [feature_command.dart](/Users/biendh/base/lib/src/cli/commands/feature_command.dart) and [feature_generator.dart](/Users/biendh/base/lib/src/generators/feature_generator.dart).
- `StateConfig` already encodes package sets and DI mode per state, so it should stay the source of truth. See [state_config.dart](/Users/biendh/base/lib/src/config/state_config.dart).
- The app brick hardcodes cubit in pubspec, bootstrap, docs, tests, and the starter home feature. See [pubspec.yaml](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/pubspec.yaml), [bootstrap.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/bootstrap.dart), [03-state-management.md](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/03-state-management.md), and [home_page.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/presentation/pages/home_page.dart).
- The feature brick hardcodes cubit in both `simple` and full modes. See [agentic_feature brick files](/Users/biendh/base/bricks/agentic_feature/__brick__/) and the cubit templates under that tree.
- The generated-project contract and smoke test are state-blind today. See [generated_project_contract.dart](/Users/biendh/base/lib/src/generators/generated_project_contract.dart) and [generated_app_smoke_test.dart](/Users/biendh/base/test/integration/generated_app_smoke_test.dart).

## Recommendation

### Rank 1: Single brick per scope, state-aware via profiles and conditional templates

Use one app brick and one feature brick. Add a small internal `ScaffoldStateProfile` layer derived from `StateConfig` and pass profile booleans/values into Mason:

- `is_cubit`
- `is_riverpod`
- `is_mobx`
- `uses_get_it`
- `uses_bloc_observer`
- `uses_provider_scope`
- `uses_mobx_store`

That keeps the public surface unchanged while making the template layer state-aware without cloning the whole scaffold.

Why this wins:

- one generator path
- one template inventory
- minimal duplication
- easier verification
- no new CLI surface
- no extra brick families

### What should stay shared

- router shape and `auto_route` contract
- flavor files and `tools/*.sh`
- i18n folder layout
- feature domain/data layers
- package naming, directory naming, and the current create/init/feature commands

### What must branch

- app bootstrap
- DI strategy
- starter home feature presentation
- starter tests
- state-management docs/examples
- feature brick presentation/test stubs
- contract validation

## Build / Codegen / DI / Router Impact By State

| Area | Cubit | Riverpod | MobX |
|---|---|---|---|
| Build/codegen | shared `build_runner`, `freezed`, `auto_route`, `slang`; `bloc_test` in tests | shared `build_runner`, `auto_route`, `slang`; add `riverpod_annotation` / `riverpod_generator` / linting | shared `build_runner`, `auto_route`, `slang`; add `mobx_codegen` |
| DI/bootstrap | `get_it` + `injectable`; `BlocObserver` bootstrap | `ProviderScope` / provider-driven DI; no `BlocObserver` | `get_it` + `injectable`; no `BlocObserver` |
| Router | keep `auto_route` as-is | keep `auto_route` as-is | keep `auto_route` as-is |
| Page wiring | `BlocProvider` + `BlocBuilder` | `ConsumerWidget` / provider reads | `Observer` + store reads |
| Starter tests | `bloc_test` + widget tests | provider/container tests + widget tests | store tests + widget tests |

## Minimal Architecture

1. Keep `StateConfig` as the source of truth for packages and DI mode.
2. Add a small internal profile object so generator code does not switch on raw strings everywhere.
3. Use one app brick and one feature brick with conditional file emission.
4. Keep build scripts shared. Do not create separate `gen.sh` / `ci-check.sh` per state.
5. Make docs state-aware inside the same file tree, not three separate doc trees.
6. Generalize `TestGenerator` to emit state-specific test skeletons from `FeatureSpec`.

This is the lowest-entropy design that still gives real parity.

## File Groups Affected

- Generator core: [project_generator.dart](/Users/biendh/base/lib/src/generators/project_generator.dart), [feature_generator.dart](/Users/biendh/base/lib/src/generators/feature_generator.dart), [test_generator.dart](/Users/biendh/base/lib/src/generators/test_generator.dart), [generated_project_contract.dart](/Users/biendh/base/lib/src/generators/generated_project_contract.dart), [state_config.dart](/Users/biendh/base/lib/src/config/state_config.dart)
- CLI flow: [create_command.dart](/Users/biendh/base/lib/src/cli/commands/create_command.dart), [feature_command.dart](/Users/biendh/base/lib/src/cli/commands/feature_command.dart), [init_command.dart](/Users/biendh/base/lib/src/cli/commands/init_command.dart)
- App brick: `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/**`
- Feature brick: `/Users/biendh/base/bricks/agentic_feature/__brick__/**`
- Tests: [generated_app_smoke_test.dart](/Users/biendh/base/test/integration/generated_app_smoke_test.dart), [project_generator_test.dart](/Users/biendh/base/test/src/generators/project_generator_test.dart), [state_config_test.dart](/Users/biendh/base/test/src/config/state_config_test.dart), [create_command_test.dart](/Users/biendh/base/test/src/cli/commands/create_command_test.dart), [init_command_test.dart](/Users/biendh/base/test/src/cli/commands/init_command_test.dart)
- CI: [ci.yml](/Users/biendh/base/.github/workflows/ci.yml)

## Verification Strategy

### Keep these separate

- state parity checks
- CI-provider checks
- native flavor checks

Do not fold all three into one giant smoke matrix. It will be slow and noisy.

### Recommended test matrix

1. Unit tests: verify `StateConfig`, `create`, `init`, and generator profile mapping.
2. Template tests: validate app/feature brick file sets and key content for each state.
3. Contract tests: extend `GeneratedProjectContract` with state-specific required/forbidden paths.
4. Smoke tests: run one state-smoke per state, ideally on one provider only, plus the existing CI-provider contract coverage separately.
5. Native gate: keep one representative generated app on macOS as the current contract already does.

### What to assert

- `cubit`: cubit files, bloc provider wiring, bloc tests, get_it/injectable bootstrapping
- `riverpod`: provider scope wiring, provider-based page/tests, no cubit leftovers
- `mobx`: store/observer wiring, mobx_codegen deps, no cubit leftovers

## Trade-Off Matrix

| Option | Rank | Trade-off |
|---|---:|---|
| One brick + state profiles + conditional templates | 1 | Best fit. Smallest surface area, lowest drift, easiest regression testing |
| Three full bricks | 2 | Simple to understand but duplicates almost everything; maintenance cost is high |
| Post-gen patch scripts | 3 | Brittle. Hard to reason about and harder to verify |

## Risks

- Riverpod is the highest-risk branch because DI/bootstrap semantics change, not just widget syntax.
- MobX is medium risk because the store shape differs, but it still fits the current build_runner stack.
- CI time can balloon if the smoke matrix becomes a full state × provider cross product.
- `GeneratedProjectContract` will keep missing regressions until it becomes state-aware.

## Phase Breakdown For Planning

### Phase 1: State profile plumbing

- derive profile data from `StateConfig`
- replace string heuristics in `init`
- add state booleans for Mason templates
- extend contract tests to understand state

### Phase 2: App brick parity

- branch `pubspec.yaml`, bootstrap, starter home feature, docs, and tests by state
- keep router/flavors/i18n/scripts shared
- remove cubit-only assumptions from README/docs

### Phase 3: Feature brick parity

- branch simple and full feature templates by state
- add state-specific presentation and test stubs
- keep domain/data layers shared

### Phase 4: Generator and test parity

- generalize `TestGenerator` for cubit/riverpod/mobx
- add generator tests for all states
- add content assertions for the generated app/feature bricks

### Phase 5: Verification hardening

- expand contract and smoke tests
- keep CI-provider and native-gate coverage separate from state parity
- add regression checks for forbidden leftovers and missing state files

## External Docs Consulted

- [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- [riverpod](https://riverpod.dev)
- [mobx](https://pub.dev/packages/mobx)

## Unresolved Questions

- Should Riverpod fully replace `get_it/injectable` in the scaffold, or should core services keep a service-locator bridge? The current `StateConfig` says riverpod is self-contained, but the app brick is still built around injectable.
- Should MobX keep the current `freezed` state model for consistency, or move to a more idiomatic store-only shape?
- Should smoke coverage stay at `state x 1 provider` and leave provider coverage to contract tests, or should CI pay the cost of the full `3 x 2` cross product?
