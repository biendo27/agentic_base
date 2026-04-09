# 03. Code Standards

## Scope

These standards describe the current repo conventions for [`agentic_base`](../README.md) and the root documentation workspace.

## Placement And Naming

- repo-level evergreen docs live in `docs/`
- plans, reports, and research live in `plans/`
- Dart source lives under `lib/`
- tests live under `test/`
- markdown filenames use kebab-case
- Dart filenames follow snake_case
- user-facing generated names such as project and feature names must be snake_case

## Size Targets

- target: keep code files under 200 LOC
- prefer splitting orchestration, shell execution, and formatting/reporting into separate helpers
- current repo does not fully meet this target yet; see "Known Deviations"

## CLI Command Conventions

Each command should:

- subclass `Command<int>`
- validate arguments before invoking external tools
- use `UsageException` for usage errors
- return `0` for success and `1` for handled runtime failure
- log via `AgenticLogger`, not `print`
- surface stderr/stdout from failed external processes clearly

## Configuration And YAML Rules

- project state lives in `.info/agentic.yaml`
- read and write state through `AgenticConfig`
- mutate YAML with `yaml_edit` when preserving comments or ordering matters
- avoid destructive rewrites of user-managed files
- `init` should only add files when absent

## Generator And Module Patterns

- keep command files thin where practical; orchestration should live in generators or helpers
- `ProjectGenerator` owns create-flow orchestration
- `FeatureGenerator` owns feature brick generation
- every installable module implements `AgenticModule`
- shared file and `pubspec.yaml` edits go through `ModuleInstaller`
- module definitions must declare:
  - `dependencies`
  - `devDependencies`
  - `conflictsWith`
  - `requiresModules`
  - `platformSteps`

## Template And Generated-Code Rules

- Mason bricks are the source of truth for generated structure
- brick hooks should validate inputs early and keep post-generation steps minimal
- generated app docs inside the app brick should stay aligned with CLI behavior
- generated-project claims must be backed by actual template files or post-gen steps

## Testing Standards

- use `package:test` and `mocktail` for package tests
- keep parser and registry tests deterministic and fast
- when changing brick behavior or shell orchestration, add integration coverage, not only unit coverage
- CI baseline for the package:
  - `dart pub get`
  - `dart analyze --fatal-infos`
  - `dart format --set-exit-if-changed lib bin`
  - `dart test`

## Documentation Standards

- root `docs/` is the repo-level source of truth
- package usage and installation stay in `README.md`
- update architecture, roadmap, and summary docs when command surface, module inventory, or delivery workflow changes
- do not hide known gaps; docs should record them explicitly

## Known Deviations

Current files over the 200 LOC target:

- [`lib/src/cli/commands/init_command.dart`](../lib/src/cli/commands/init_command.dart)
- [`lib/src/generators/project_generator.dart`](../lib/src/generators/project_generator.dart)
- [`lib/src/cli/commands/deploy_command.dart`](../lib/src/cli/commands/deploy_command.dart)
- [`lib/src/cli/commands/brick_command.dart`](../lib/src/cli/commands/brick_command.dart)
- [`lib/src/cli/commands/eval_command.dart`](../lib/src/cli/commands/eval_command.dart)

Current process gaps:

- no repo-level integration test that generates a full app in CI
- no checked-in release automation for pub.dev publishing
- root `CLAUDE.md` is still absent if you want repo-level AI instructions beyond `AGENTS.md`

## References

- [`lib/src/config/agentic_config.dart`](../lib/src/config/agentic_config.dart)
- [`lib/src/modules/base_module.dart`](../lib/src/modules/base_module.dart)
- [`lib/src/modules/module_installer.dart`](../lib/src/modules/module_installer.dart)
- [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)
