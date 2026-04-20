# 02. Codebase Summary

## Snapshot

The repo root is the real product root. `docs/` stores evergreen repo docs and `plans/` stores delivery artifacts.

## Top-Level Layout

| Path | Purpose |
| --- | --- |
| [`README.md`](../README.md) | Package landing page and usage guide. |
| [`docs/`](./) | Repo-level product, architecture, contract, and delivery docs. |
| [`plans/`](../plans/) | Timestamped implementation plans and reports. |
| [`.github/workflows/`](../.github/workflows/ci.yml) | Package CI automation. |

## Main Code Areas

| Area | Responsibility |
| --- | --- |
| `lib/src/cli/` | Command runner plus individual CLI commands. |
| `lib/src/config/` | `.info/agentic.yaml` state, init metadata inference/repair, support-tier summaries, and profile preset resolution. |
| `lib/src/generators/` | Project, feature, and contract generation orchestration. |
| `lib/src/modules/` | Module contract, registry, rollback journal, integration generator, install/uninstall helpers. |
| `lib/src/tui/` | Logging and interactive prompt helpers. |
| `bricks/agentic_app` | Main app starter brick plus Mason hooks and state-conditional scaffolding. |
| `bricks/agentic_feature` | Feature scaffold brick with cubit/riverpod/mobx branches. |
| `test/src/` | Unit tests around CLI metadata, parsers, registry logic, and generators. |
| `test/integration/` | Generated-app smoke tests plus module wiring coverage. |

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

- `create` makes a fresh Flutter project, overlays the `agentic_app` brick, writes `.info/agentic.yaml`, resolves profile-owned default modules and providers when the user does not explicitly override them, materializes typed translations, and verifies the generated app with profile-aware gate policy.
- `init` adds agentic scaffolding to an existing Flutter project without overwriting existing files and can repair stale or fabricated metadata with provenance.

Generated starter apps now follow one explicit ownership contract:

- Flutter layer source of truth lives in `lib/app/**`, `lib/main*.dart`, `assets/i18n/**`, `.vscode/**`, and `.idea/runConfigurations/**`
- native shells come from `flutter create`
- native flavor assets come from `flutter_flavorizr`
- duplicate root shell files such as `lib/app.dart`, `lib/flavors.dart`, and `lib/pages/**` are deleted and asserted absent
- starter scaffolds now keep cubit, riverpod, and mobx output aligned with the selected state profile
- starter scaffolds now render `starter_runtime_profile.dart` plus consent and entitlement seams from one profile-owned preset resolver
- analytics now wires a concrete `AnalyticsService` seam into the generated DI graph and is smoke-tested

The app brick also ships its own generated-project docs under the template `docs/` folder, which means this repo has two doc surfaces:

- repo docs in root `docs/`
- generated app docs inside the Mason template

## Test Coverage Shape

Current tests are mostly fast unit tests:

- CLI runner behavior
- create command parsing and validation
- add/remove command transactional module-refresh orchestration
- init metadata inference and repair
- config parsing and state config mapping
- test file generation
- module registry dependency logic
- project contract validation and generated-app smoke tests
- analytics module DI wiring in generated starter apps

What is not present yet in this repo CI:

- release or pub.dev publish automation

## Notable Findings

- repo automation remains GitHub-hosted, but generated projects can now scaffold either GitHub or GitLab CI from one persisted provider contract
- `deploy` resolves the target-project provider from `.info/agentic.yaml` and routes through `gh` or `glab`
- preview-only `--dry-run` now spans the command surface, and previews no longer probe Flutter managers before printing the planned reads, writes, and commands
- manager-aware command execution now resolves `flutter`/`dart` invocations through `system`, `fvm`, or `puro`, while `doctor` reports manager fallback as a contract mismatch instead of a healthy state
- generated app smoke coverage now asserts analytics module DI wiring in the emitted `injection.config.dart`
- generated app smoke coverage now exercises cubit, riverpod, and mobx starter apps
- generated starter contracts now use file-per-contract shared models for `AppResult`, response envelopes, pagination, and runtime-agnostic localized text, while the theme layer splits family selection from theme composition
- default profile execution now lives in `profile_preset.dart`, which resolves the default `subscription-commerce-app` module pack, provider map, gate pack, and starter seam toggles from one source of truth
- generated starter apps now ship a trustworthy-commerce family, Lexend plus Source Sans 3 via `google_fonts`, profile-aware dashboard signals, and explicit `PaymentsService`, `EntitlementService`, and `ConsentService` seams
- the default payments lane is now store-native via `in_app_purchase`, while ads stay generated-but-safe until consent and config gates allow richer behavior
- `ProjectMutationJournal` keeps module mutations rollback-safe while `ModuleIntegrationGenerator` rewrites the live bootstrap seam
- some command/orchestration files exceed the repo's 200 LOC target:
  - `init_command.dart`
  - `brick_command.dart`
  - `eval_command.dart`

## References

- [`lib/src/cli/cli_runner.dart`](../lib/src/cli/cli_runner.dart)
- [`lib/src/generators/project_generator.dart`](../lib/src/generators/project_generator.dart)
- [`lib/src/config/profile_preset.dart`](../lib/src/config/profile_preset.dart)
- [`lib/src/generators/generated_project_contract.dart`](../lib/src/generators/generated_project_contract.dart)
- [`lib/src/modules/module_registry.dart`](../lib/src/modules/module_registry.dart)
- [`lib/src/modules/module_integration_generator.dart`](../lib/src/modules/module_integration_generator.dart)
- [`lib/src/modules/project_mutation_journal.dart`](../lib/src/modules/project_mutation_journal.dart)
- [`bricks/agentic_app/brick.yaml`](../bricks/agentic_app/brick.yaml)
- [`test/src/modules/module_registry_test.dart`](../test/src/modules/module_registry_test.dart)
