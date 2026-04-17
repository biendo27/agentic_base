# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- classic Gitflow repo policy with documented `main`, `develop`, `feature/*`, `release/*`, and `hotfix/*` roles
- PR route enforcement via `.github/workflows/gitflow-guard.yml`
- `CODEOWNERS` and a pull request template to standardize review requests after CI passes
- `docs/15-default-app-service-matrix.md` as the canonical V1 default-app service matrix reference
- `docs/16-profile-rollout-migration-guide.md` with the manual upgrade checklist for older generated repos
- `lib/src/config/profile_preset.dart` as the generator-owned source of truth for default modules, providers, starter seams, and profile verify policy
- generated starter seams for `EntitlementService`, `ConsentService`, and `starter_runtime_profile.dart`
- starter widget regression coverage for commerce, journey, and settings profile signals

### Changed

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

### Testing

- `dart analyze --fatal-infos` passed
- targeted tests passed: `test/src/config/project_metadata_test.dart` and `test/src/generators/project_generator_test.dart`
- targeted tests passed: `test/src/config/profile_preset_test.dart`, `test/src/cli/commands/create_command_test.dart`, `test/src/generators/profile_gate_contract_test.dart`, and `test/src/docs/harness_contract_documentation_test.dart`
- generated-app smoke regression passed: `test/integration/generated_app_smoke_test.dart`
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
