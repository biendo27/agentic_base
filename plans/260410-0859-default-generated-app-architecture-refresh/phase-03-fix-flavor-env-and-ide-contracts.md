# Phase 03 - Fix Flavor Env And IDE Contracts

## Context Links

- Current config: `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/flavorizr.yaml`, `env/*.env.example`, `lib/app/flavors.dart`, `lib/main*.dart`
- Current drift: `my_app/flavorizr.yaml`, `my_app/lib/app/flavors.dart`, `my_app/.idea/*`
- Generator: `lib/src/generators/project_generator.dart`
- Research: `./research/current-state-and-tooling-contracts.md`

## Overview

- Priority: P1
- Status: completed
- Effort: 6h
- Blocked by: phases 01-02
- File ownership for this phase:
  - Brick flavor, env, and IDE config files
  - Generator orchestration for flavor tool execution

## Key Insights

- `flavorizr.yaml` already contains per-flavor names. The real failures are invalid app-id templating and the tool owning too much.
- Runtime URLs are hardcoded inside `lib/app/flavors.dart`, while `env/*.env.example` sits unused.
- `.vscode` is missing, and `.idea` currently includes user-local files that should never be template-owned.

## Requirements

- Restrict `flutter_flavorizr` to native flavor artifacts only.
- Strengthen `flavorizr.yaml` so generated app ids are valid and deterministic.
- Move runtime config to env-driven compile-time values, not hardcoded URLs.
- Ship brick-owned `.vscode` plus shared `.idea/runConfigurations` only.
- Keep starter app runnable out of the box with example env files.
- Freeze one supported run matrix across CLI, IDE, scripts, tests, and CI before changing launch files.

## Architecture

### Data Flow

- Input:
  - CLI create args: `org`, `projectName`, `flavors`
  - Example env files: `env/dev.env.example`, `env/staging.env.example`, `env/prod.env.example`
- Transform:
  1. Brick renders validated `flavorizr.yaml`.
  2. `flutter_flavorizr` runs with explicit native-only instructions.
  3. IDE and CLI launch configs pass `--dart-define-from-file=env/<flavor>.env.example`.
  4. `FlavorConfig` reads compile-time keys via `String.fromEnvironment`.
- Output: valid native flavor setup plus one runtime config path for all app code.

### Run Matrix

| Surface | Supported command |
| --- | --- |
| Plain `flutter run` | dev alias through `lib/main.dart` |
| Explicit dev run | `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.env.example` |
| Explicit staging run | `flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=env/staging.env.example` |
| Explicit prod run | `flutter run --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.env.example` |
| VS Code / JetBrains | mirror the explicit commands above |
| Tests / CI | use the same entrypoints or documented dev alias where flavor is not required |

### IDE Contract

- Template-owned:
  - `.vscode/launch.json`
  - `.vscode/settings.json`
  - `.idea/runConfigurations/*.xml`
- Local only:
  - `.idea/workspace.xml`
  - `.idea/modules.xml`
  - SDK library XML files

## Related Code Files

- Modify:
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/flavorizr.yaml`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/env/dev.env.example`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/env/staging.env.example`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/env/prod.env.example`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/flavors.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/main.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/main_dev.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/main_staging.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/main_prod.dart`
  - `lib/src/generators/project_generator.dart`
- Create:
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.vscode/launch.json`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.vscode/settings.json`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.idea/runConfigurations/*.xml`
- Delete or stop generating:
  - `<generated-app>/lib/app.dart`
  - `<generated-app>/lib/flavors.dart`
  - `<generated-app>/lib/pages/**`
  - shared `.idea` files outside `runConfigurations`

## Implementation Steps

1. Add explicit `instructions` allowlist in `flavorizr.yaml` so the tool generates native assets only.
2. Replace Mason-only app-id templating with one explicit generator-owned helper that validates inputs, normalizes the app-id segment deterministically, and fails on invalid output.
3. Refactor `FlavorConfig` to read `API_BASE_URL`, `APP_NAME`, and similar keys from `String.fromEnvironment`, with safe starter defaults only as a last fallback.
4. Add VSCode launch configs and shared IDEA run configs for dev, staging, prod using `--dart-define-from-file=env/<flavor>.env.example`.
5. Update scripts, setup flow, and docs to use the same run matrix.
6. Update generator logging and sequencing so flavor setup happens with the new native-only boundary.

## Todo List

- [ ] Lock native-only `flutter_flavorizr` instructions
- [ ] Add explicit app-id helper and validation rules
- [ ] Remove hardcoded runtime URLs from Dart
- [ ] Freeze documented run matrix
- [ ] Add VSCode flavor launches
- [ ] Add shared IDEA flavor run configs

## Success Criteria

- Generated `android` and `ios` app ids are valid for all flavors.
- Generated app contains no Dart/UI files emitted by `flutter_flavorizr`.
- `flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.env.example` is documented and works.
- `.vscode` and `.idea/runConfigurations` are present in the template; local `.idea` noise is absent.
- CLI, IDE, scripts, and CI all point at the same supported entrypoint matrix.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| `flutter_flavorizr` still emits Dart files because instructions are incomplete | Medium | High | Assert forbidden file absence in phase-5 smoke tests |
| Env defines missing in manual runs or CI | Medium | Medium | Bake flags into docs, IDE configs, and setup scripts |
| App-id helper breaks unusual org inputs | Medium | High | Add targeted tests for org/project normalization and explicit reject cases |

## Security Considerations

- Keep checked-in env files as examples with non-secret values only.
- Never log full env file contents during setup or tests.
- Shared IDE configs must not embed machine-specific SDK paths or user names.

## Rollback

- Revert to prior flavor/runtime config only if native-only flavor generation blocks starter-app boot.
- Keep phase-1 ownership guard so old duplicate Dart outputs do not silently return.

## Next Steps

- Phase 04 consumes final flavor config and IDE launches.
- Phase 05 adds regression coverage for app-id generation and forbidden file absence.
