# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.1] - 2026-04-22

### Added

- explicit generated-app verification modes for full, fast, and intentionally skipped create-time validation
- strict generated-project CI contract checks for unresolved Mason tokens, credentialless PR build scope, and root-level iOS AdMob metadata

### Changed

- root CI now keeps protected check contexts while splitting fast package tests from conditional generated-app, slow-canary, and native validation lanes
- generated GitHub PR CI builds only credentialless `dev` and `staging` artifacts, leaving `prod` to protected release and deploy workflows
- generated `tools/lint.sh` now supports an opt-in `--strict` mode backed by `dart analyze --fatal-infos`

### Fixed

- generated GitHub and GitLab workflow templates no longer leave unresolved provider or evidence-path tokens after Mason rendering
- iOS AdMob plist mutation now preserves exactly one root-level `GADApplicationIdentifier` and repairs nested sample entries
- interactive create prompts for CI provider, while non-interactive create keeps the documented GitHub default

### Testing

- `dart analyze --fatal-infos` passed
- focused create, generator contract, AdMob module, and documentation tests passed
- generated-app fast smoke, slow canary, and fresh native gate passed locally and in GitHub CI

## [0.3.0] - 2026-04-21

### Added

- explicit `agentic_base firebase setup` flow with generated `tools/setup-firebase.sh` and flavor-aware Firebase option placeholders
- generator-owned module startup policy surfaces for `lib/app/modules/module_startup.dart` and `lib/app/modules/module_providers.dart`

### Changed

- generated apps now use one flavor runner: `./tools/run.sh [dev|staging|stg|prod]`
- installed module implementations now live under `lib/services/<capability>/`
- default runtime seams now stay bootable until Firebase credentials and native config are explicitly installed

### Fixed

- Android-only generated projects no longer fail native flavor-output validation by requiring iOS artifacts
- Firebase setup rollback now restores generated Dart outputs plus Android and iOS native mutations
- Crashlytics bootstrap error forwarding now avoids uncaught future propagation from the global platform error hook

### Testing

- `dart analyze --fatal-infos` passed
- focused rollback, Crashlytics, generator, and generated-app smoke coverage passed
- generated Android-only create plus generated verify passed

## [0.2.2] - 2026-04-20

### Fixed

- explicitly package hidden generated-app brick files such as `.vscode/launch.json`, `.github/workflows/ci.yml`, and `.info/agentic.yaml`
- restore packaged `agentic_base create` output for IDE launch configs, generated repo CI files, and the machine-readable `.info/agentic.yaml` contract

### Testing

- package archive regression now verifies hidden generated-app contract paths are present in source and explicitly re-included by `.pubignore`
- `dart pub publish --dry-run` verifies hidden app-brick files remain in the archive before tag-driven pub.dev publishing

## [0.2.1] - 2026-04-20

### Fixed

- root-anchor `.pubignore` entries so generated-app brick docs stay in the pub.dev archive
- restore packaged `agentic_base create` output for required generated docs such as `docs/01-architecture.md`

### Testing

- `dart pub publish --dry-run` verified that `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/01-architecture.md` remains in the archive

## [0.2.0] - 2026-04-20

### Added

- classic Gitflow repo policy with documented `main`, `develop`, `feature/*`, `release/*`, and `hotfix/*` roles
- PR route enforcement via `.github/workflows/gitflow-guard.yml`
- `CODEOWNERS` and a pull request template to standardize review requests after CI passes
- `docs/15-default-app-service-matrix.md` as the canonical V1 default-app service matrix reference
- `docs/16-profile-rollout-migration-guide.md` with the manual upgrade checklist for older generated repos
- `lib/src/config/profile_preset.dart` as the generator-owned source of truth for default modules, providers, starter seams, and profile verify policy
- generated starter seams for `EntitlementService`, `ConsentService`, and `starter_runtime_profile.dart`
- starter widget regression coverage for commerce, journey, and settings profile signals
- `harness.observability` as the additive local-first observability support envelope in `.info/agentic.yaml`
- generated app runtime observability seams, network correlation, and telemetry export hooks
- `agentic_base inspect` plus generated `./tools/inspect-evidence.sh` for latest-run bundle inspection
- `docs/17-observability-contract.md`, `docs/18-local-operator-reporting.md`, and `docs/19-observability-rollout-migration-guide.md`

### Changed

- pub.dev release archives now exclude repo-only `docs/`, `plans/`, coverage output, and repomix artifacts via `.pubignore`
- package README deep links now point at the repository docs so the published page keeps working after the leaner archive cut
- repo CI now runs for pull requests into `main` and `develop`, plus pushes to `main`, `develop`, `release/*`, and `hotfix/*`
- deployment docs now record the repo merge strategy targets and the current GitHub branch-protection limitation for private repos on this plan
- shared contract guidance now prefers extension-based ergonomics for raw contract models, keeping locale/DI/runtime behavior outside the transport contract
- generated smoke verification now uses a dedicated `app-shell-smoke` tag so the slow canary is not duplicated in the generic test pass
- smoke policy now distinguishes a fast blocking lane from a slow blocking canary for harness, verify, evidence, and native-surface changes
- contract-frozen surfaces now use `evidence_quality` instead of `observability`, with validator and manifest parsing updated to enforce canonical quality dimensions and normalize stale manifest values
- `create` now defaults to `subscription-commerce-app`, while explicit empty module overrides still suppress preset-owned defaults
- generated verify and release-preflight surfaces now render profile-aware gate packs and explicit advisory skips for Tier 2 profiles
- the package slow canary now runs generated `verify.sh` in a fast smoke mode, streams verify output live, and leaves real native readiness to the dedicated CI native gate
- the default starter theme now ships the trustworthy-commerce family with Lexend, Source Sans 3, and `google_fonts`
- the default payments seam now uses store-native `in_app_purchase`, and the starter commerce lane keeps payments, entitlement, consent, and ads responsibilities separate
- evidence bundles now emit structured telemetry files beside `summary.json` and `commands.ndjson`, and the latest run is published through a deterministic local `latest/` pointer
- observability stays local-first and additive; `evidence_quality` remains a run-evidence dimension, not a telemetry rename

### Testing

- `dart analyze --fatal-infos` passed
- targeted tests passed: `test/src/config/project_metadata_test.dart` and `test/src/generators/project_generator_test.dart`
- targeted tests passed: `test/src/config/profile_preset_test.dart`, `test/src/cli/commands/create_command_test.dart`, `test/src/generators/profile_gate_contract_test.dart`, and `test/src/docs/harness_contract_documentation_test.dart`
- generated-app smoke regression passed: `test/integration/generated_app_smoke_test.dart`
- targeted tests passed: `test/src/cli/commands/inspect_command_test.dart` and `test/src/observability/run_ledger_test.dart`
- shell syntax checks passed for the generated `tools/verify.sh` and `tools/release-preflight.sh`
- full `dart test` passed

## [0.1.0] - 2026-04-09

### Added

- `create` command — generate Flutter projects with Clean Architecture
- `feature` command — scaffold 3-layer features (full or flat)
- `add`/`remove` commands — manage 25 built-in modules
- `gen` command — code generation pipeline (build_runner + format)
- `eval` command — test runner with optional coverage reporting
- `deploy` command — trigger CI/CD deployment via GitHub Actions
- `doctor` command — environment health check (Dart, Flutter, Mason)
- `brick` command — community Mason brick management (add/remove/list)
- `init` command — add agentic_base to existing Flutter projects
- `upgrade` command — dependency upgrade with version tracking
- 3 state management options: Cubit (default), Riverpod, MobX
- Full Material 3 theme generation with 19 component themes
- CI/CD workflow templates (GitHub Actions + Fastlane)
- `AGENTS.md` + `CLAUDE.md` generation for AI agent integration
- 25 built-in modules across 6 categories: Core, Communication, Monetization, Media, Location, Device
