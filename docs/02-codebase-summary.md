# 02. Codebase Summary

## Snapshot

The repo root is now the real product root. `docs/` and `plans/` hold repo-level knowledge and delivery artifacts alongside the package source.

Before this init pass, `docs/` contained only one session journal. Evergreen project docs did not exist yet.

## Top-Level Layout

| Path | Purpose |
| --- | --- |
| [`README.md`](../README.md) | Package landing page and usage guide. |
| [`docs/`](./) | Repo-level docs, architecture, roadmap, journals. |
| [`plans/`](../plans/) | Timestamped implementation plans and reports. |
| [`.github/workflows/`](../.github/workflows/ci.yml) | Package CI automation. |

## Package Metrics

Counts below exclude generated caches such as `.dart_tool`.

| Area | Files | LOC |
| --- | ---: | ---: |
| `lib` | 52 | 6762 |
| `bricks` | 110 | 3087 |
| `test` | 9 | 1489 |
| repo root package files | 6 | 671 |
| `example` | 1 | 22 |
| `bin` | 1 | 13 |

## Main Code Areas

| Area | Responsibility |
| --- | --- |
| `lib/src/cli/` | Command runner plus individual CLI commands. |
| `lib/src/generators/` | Project, feature, and test generation orchestration. |
| `lib/src/config/` | `.info/agentic.yaml` state plus feature spec and state config parsing. |
| `lib/src/modules/` | Module contract, registry, install/uninstall helpers, module implementations. |
| `lib/src/tui/` | Logging and interactive prompt helpers. |
| `bricks/agentic_app` | Main app starter brick plus Mason hooks. |
| `bricks/agentic_feature` | Feature scaffold brick. |
| `test/src/` | Unit-focused tests around CLI metadata, parsers, registry logic, and generators. |

## Verified Command Surface

The CLI runner registers:

- `create`
- `feature`
- `add`
- `remove`
- `gen`
- `eval`
- `doctor`
- `init`
- `upgrade`
- `deploy`
- `brick`

## Generated Output Model

The package creates or modifies Flutter projects in two main ways:

- `create` makes a fresh Flutter project, overlays the `agentic_app` brick, and verifies it
- `init` adds agentic scaffolding to an existing Flutter project without overwriting existing files

The app brick also ships its own generated-project docs under the template `docs/` folder, which means this repo has two doc surfaces:

- repo docs in root `docs/`
- generated app docs inside the Mason template

## Test Coverage Shape

Current tests are mostly fast unit tests:

- CLI runner behavior
- create command parsing and validation
- config parsing and state config mapping
- test file generation
- module registry dependency logic
- prompt helpers

What is not present yet in this repo CI:

- end-to-end "generate a full app and compile it" tests
- brick smoke tests for both app and feature templates
- release or deployment workflow validation

## Notable Findings

- `ModuleRegistry` currently exposes 27 modules, while the package README still advertises 25
- only one repo workflow is checked in: CI
- `deploy` expects target-project workflows that are not included here
- some command/orchestration files exceed the repo's 200 LOC target:
  - `init_command.dart`
  - `project_generator.dart`
  - `deploy_command.dart`
  - `brick_command.dart`
  - `eval_command.dart`

## References

- [`lib/src/cli/cli_runner.dart`](../lib/src/cli/cli_runner.dart)
- [`lib/src/generators/project_generator.dart`](../lib/src/generators/project_generator.dart)
- [`lib/src/modules/module_registry.dart`](../lib/src/modules/module_registry.dart)
- [`bricks/agentic_app/brick.yaml`](../bricks/agentic_app/brick.yaml)
- [`test/src/modules/module_registry_test.dart`](../test/src/modules/module_registry_test.dart)
