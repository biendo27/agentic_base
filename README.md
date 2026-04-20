# agentic_base

`agentic_base` is a Dart CLI that generates harness-first Flutter repositories with:

- one finite canonical context surface for humans and agents
- one typed machine contract in `.info/agentic.yaml`
- deterministic local scripts for setup, run, test, verify, build, and release prep
- evidence-backed verify and release-preflight runs
- explicit human approval boundaries around credentials and final production publish

The package lives at the repository root. Root-level [`docs/`](./docs/) stores evergreen package docs. [`plans/`](./plans/) stores implementation plans and reports.

## Installation

```bash
dart pub global activate agentic_base
```

## Quick Start

```bash
# Create a new agent-ready repo
# Default profile: subscription-commerce-app
agentic_base create my_app \
  --org com.example \
  --flutter-sdk-manager system

# Add modules
agentic_base add analytics
agentic_base add logging

# Scaffold a feature
agentic_base feature auth
agentic_base feature settings --simple

# Run generation and verification
agentic_base gen
agentic_base eval --coverage

# Inspect the latest local evidence bundle
agentic_base inspect --kind verify
```

## Commands

| Command | Description |
| --- | --- |
| `create <name>` | Generate a new Flutter project. |
| `feature <name>` | Scaffold a Clean Architecture feature. |
| `add <module>` | Install a built-in module. |
| `remove <module>` | Remove an installed module. |
| `gen` | Run build_runner + format pipeline. |
| `eval [feature]` | Run tests, optionally scoped to one feature. |
| `deploy <env>` | Trigger downstream CI/CD deployment via the persisted CI provider. |
| `doctor` | Check environment health and SDK contract drift. |
| `brick <add|remove|list>` | Manage community Mason bricks. |
| `init` | Add or repair the agent-ready scaffold in an existing Flutter project. |
| `inspect` | Derive a local run ledger from the latest evidence bundle. |
| `upgrade` | Upgrade dependencies and resync generator-owned repo surfaces. |

## State Management Options

```bash
agentic_base create my_app --state cubit
agentic_base create my_app --state riverpod
agentic_base create my_app --state mobx
```

## Generated Repo Contract

Every generated repo ships:

- one machine-readable source of truth in `.info/agentic.yaml`
- one finite human-readable context surface in `README.md`, `docs/01-07`, `AGENTS.md`, and `CLAUDE.md`
- deterministic wrapper scripts in `tools/` for setup, run, test, verify, build, release-preflight, and release
- named verify and release-preflight evidence bundles under `artifacts/evidence/`
- local-first runtime observability seams plus `./tools/inspect-evidence.sh` for latest-run inspection
- a profile-aware starter journey that proves runtime diagnostics, detail navigation, settings preview, config and lifecycle signals, and separated payments, entitlement, consent, and ads seams for the selected profile
- starter tests for repository seams, the selected state runtime, starter widget behavior, app boot smoke, and native readiness where the host supports it
- explicit human checkpoints for credentials and final store publish

`init` uses the same brick-owned scaffold source as `create` and `upgrade`, but sync remains additive:

- missing generator-owned docs, adapters, scripts, CI wrappers, and Fastlane files are copied in
- conflicting thin adapters or opposite-provider CI files cause `init` to fail and roll back copied scaffold changes
- module-added package constraints come from the repo-owned version catalog
- Firebase-backed modules keep generated startup code compilable until real provider configuration replaces the stub surfaces

## Harness Contract V1

Harness Contract V1 is implemented in generator code and generated downstream repos.

The shipped V1 surface covers:

- typed harness metadata for profile, traits, capabilities, evidence, approvals, and SDK policy
- support-tier summaries derived from the declared app profile
- named verify and release-preflight evidence bundles from the generated `tools/*.sh` contract
- explicit human pauses for product direction, credential setup, and final production publish
- manager-aware local and CI entrypoints that preserve one gate vocabulary

The detailed contract docs live in [`docs/08-15`](./docs/08-harness-contract-v1.md).

`subscription-commerce-app` is now the canonical V1 golden-path profile and the shipped CLI default. Preset resolution, starter seams, and profile-aware verify behavior now render from the same generator-owned policy, and the upgrade path for older generated repos is documented in [`docs/16-profile-rollout-migration-guide.md`](./docs/16-profile-rollout-migration-guide.md).

## Available Modules (27)

### Core (8)
`analytics`, `crashlytics`, `auth`, `local_storage`, `connectivity`, `permissions`, `secure_storage`, `logging`

### Communication (5)
`notifications`, `deep_link`, `in_app_review`, `share`, `social_login`

### Monetization (4)
`ads`, `payments`, `remote_config`, `feature_flags`

### Media (4)
`image_picker`, `camera`, `video_player`, `qr_scanner`

### Location (2)
`location`, `maps`

### Device (4)
`biometric`, `file_manager`, `app_update`, `webview`

## Generated Project Structure

```text
assets/i18n/
├── app/          # App-shell translations
└── home/         # Starter feature translations

lib/
├── app/          # Bootstrap, flavors, generated i18n
├── core/         # DI, network, theme, router, error handling
├── features/     # Starter home flow plus spec-driven feature modules
└── shared/       # Shared widgets and utilities
```

## Flags

| Flag | Description | Default |
| --- | --- | --- |
| `--org` | Organization reverse domain. | `com.example` |
| `--platforms` | Target platforms (comma-separated). | `android,ios,web` |
| `--state` | State management. | `cubit` |
| `--flavors` | Build flavors. | `dev,staging,prod` |
| `--ci-provider` | Generated project CI provider (`github` or `gitlab`). | `github` |
| `--app-profile` | Declared Harness Contract V1 primary profile. | `subscription-commerce-app` |
| `--traits` | Optional profile traits (comma-separated). | none |
| `--flutter-sdk-manager` | Declared Flutter SDK manager (`system`, `fvm`, `puro`). | `system` |
| `--flutter-version` | Explicit tested Flutter SDK version. | auto-detected from selected manager |
| `--no-interactive` | Skip prompts and use defaults. | `false` |

The shipped default V1 lane is documented in [`docs/15-default-app-service-matrix.md`](./docs/15-default-app-service-matrix.md), and upgrade guidance for older generated repos lives in [`docs/16-profile-rollout-migration-guide.md`](./docs/16-profile-rollout-migration-guide.md).

## CI Provider Selection

Generated and initialized projects persist one CI provider in `.info/agentic.yaml`:

- `github`: emits `.github/workflows/*.yml` and `agentic_base deploy <env>` uses `gh`
- `gitlab`: emits root `.gitlab-ci.yml` plus `.gitlab/ci/*.yml`; `agentic_base deploy <env>` maps to the real generated manual jobs for that environment via `glab`

GitLab native validation is macOS-only by contract. Generated GitLab projects require a macOS runner with a shell executor, Xcode, and `tags: [macos]`; Linux runners do not replace the native gate.

## Documentation Index

1. [`01-project-overview-pdr.md`](./docs/01-project-overview-pdr.md)
2. [`02-codebase-summary.md`](./docs/02-codebase-summary.md)
3. [`03-code-standards.md`](./docs/03-code-standards.md)
4. [`04-system-architecture.md`](./docs/04-system-architecture.md)
5. [`05-project-roadmap.md`](./docs/05-project-roadmap.md)
6. [`06-deployment-guide.md`](./docs/06-deployment-guide.md)
7. [`07-design-guidelines.md`](./docs/07-design-guidelines.md)
8. [`08-harness-contract-v1.md`](./docs/08-harness-contract-v1.md)
9. [`09-support-tier-matrix.md`](./docs/09-support-tier-matrix.md)
10. [`10-manifest-schema.md`](./docs/10-manifest-schema.md)
11. [`11-eval-and-evidence-model.md`](./docs/11-eval-and-evidence-model.md)
12. [`12-approval-state-machine.md`](./docs/12-approval-state-machine.md)
13. [`13-flutter-adapter-boundaries.md`](./docs/13-flutter-adapter-boundaries.md)
14. [`14-sdk-and-version-policy.md`](./docs/14-sdk-and-version-policy.md)
15. [`15-default-app-service-matrix.md`](./docs/15-default-app-service-matrix.md)
16. [`16-profile-rollout-migration-guide.md`](./docs/16-profile-rollout-migration-guide.md)
17. [`17-observability-contract.md`](./docs/17-observability-contract.md)
18. [`18-local-operator-reporting.md`](./docs/18-local-operator-reporting.md)
19. [`19-observability-rollout-migration-guide.md`](./docs/19-observability-rollout-migration-guide.md)

## Local Development

```bash
dart pub get
dart analyze --fatal-infos
dart test
```

## Gitflow

This repo uses classic Gitflow:

- `main`: production-ready history and release tags
- `develop`: integration branch for ongoing work
- `feature/*`: branch from `develop`, merge back into `develop`
- `release/*`: branch from `develop`, merge into `main`, then back into `develop`
- `hotfix/*`: branch from `main`, merge into `main`, then back into `develop`

Repo automation validates PR routing and runs CI on pull requests into `main` and `develop`, plus pushes to `main`, `develop`, `release/*`, and `hotfix/*`.

Generated downstream repos document the same branch model as a recommended default workflow in their README, workflow doc, and thin adapters. That guidance stays human-readable only; `.info/agentic.yaml` does not encode downstream Gitflow policy.

## Notes

- Root `docs/` is repo-level documentation for this package.
- Generated Flutter repos ship their own canonical docs, thin agent adapters, and harness scripts.

## License

MIT
