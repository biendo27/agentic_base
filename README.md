# agentic_base

A Dart CLI tool that generates agent-ready Flutter repositories with canonical context, deterministic harness scripts, and honest verify/release contracts.

The package now lives at the repository root. Root-level [`docs/`](./docs/) stores evergreen project documentation, and [`plans/`](./plans/) stores implementation plans and reports.

## Installation

```bash
dart pub global activate agentic_base
```

## Quick Start

```bash
# Create a new agent-ready repo
agentic_base create my_app --org com.example

# Add modules
agentic_base add analytics
agentic_base add logging

# Scaffold a feature
agentic_base feature auth
agentic_base feature settings --simple

# Run code generation
agentic_base gen

# Run tests
agentic_base eval --coverage
```

## Commands

| Command | Description |
|---------|-------------|
| `create <name>` | Generate a new Flutter project |
| `feature <name>` | Scaffold a Clean Architecture feature |
| `add <module>` | Install a built-in module |
| `remove <module>` | Remove an installed module |
| `gen` | Run build_runner + format pipeline |
| `eval [feature]` | Run tests (optional: specific feature) |
| `deploy <env>` | Trigger CI/CD deployment via the stored GitHub or GitLab provider |
| `doctor` | Check environment health |
| `brick <add|remove|list>` | Manage community Mason bricks |
| `init` | Add or repair the agent-ready scaffold in an existing Flutter project |
| `upgrade` | Upgrade dependencies and resync generator-owned repo surfaces |

## State Management Options

```bash
agentic_base create my_app --state cubit     # Default
agentic_base create my_app --state riverpod
agentic_base create my_app --state mobx
```

## Generated Repo Contract

Every generated repo ships:

- one machine-readable source of truth in `.info/agentic.yaml`
- canonical human-readable context in `README.md` and `docs/`
- thin vendor adapters in `AGENTS.md` and `CLAUDE.md`
- deterministic local entrypoints in `tools/` for setup, run, verify, build, and release preflight
- explicit human checkpoints for credentials and final store publish

`init` now uses the same brick-owned scaffold source as `create` and `upgrade`, but sync is additive:

- missing generator-owned docs, adapters, scripts, CI wrappers, and Fastlane files are copied in
- existing thin adapters or provider surfaces that conflict with the contract cause `init` to fail and roll back copied scaffold changes instead of leaving a false `.info/agentic.yaml`
- module-added package constraints come from a repo-owned version catalog; installs no longer fall back to `any`
- Firebase-backed modules now ship a compilable `lib/firebase_options.dart` stub until `flutterfire configure` replaces it, and startup-bound modules register against the owned bootstrap seam so generated startup wiring is executable

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
├── features/     # Feature modules (3-layer Clean Architecture)
└── shared/       # Shared widgets and utilities
```

## Flags

| Flag | Description | Default |
|------|-------------|---------|
| `--org` | Organization reverse domain | `com.example` |
| `--platforms` | Target platforms (comma-separated) | `android,ios,web` |
| `--state` | State management | `cubit` |
| `--flavors` | Build flavors | `dev,staging,prod` |
| `--ci-provider` | Generated project CI provider (`github` or `gitlab`) | `github` |
| `--primary-color` | Primary color hex | `6750A4` |
| `--no-interactive` | Skip prompts, use defaults | `false` |

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
8. [`08-agent-ready-repo-architecture-and-review-prompt.md`](./docs/08-agent-ready-repo-architecture-and-review-prompt.md)

## Local Development

```bash
dart pub get
dart analyze --fatal-infos
dart test
```

## Notes

- Root `docs/` is repo-level documentation for this package.
- Generated Flutter repos ship their own canonical docs, thin agent adapters, and harness scripts.

## License

MIT
