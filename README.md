# agentic_base

A Dart CLI tool that generates production-ready Flutter codebases optimized for AI-agent-driven development.

The package now lives at the repository root. Root-level [`docs/`](./docs/) stores evergreen project documentation, and [`plans/`](./plans/) stores implementation plans and reports.

## Installation

```bash
dart pub global activate agentic_base
```

## Quick Start

```bash
# Create a new project
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
| `deploy <env>` | Trigger CI/CD deployment via GitHub Actions |
| `doctor` | Check environment health |
| `brick <add|remove|list>` | Manage community Mason bricks |
| `init` | Add agentic_base to existing project |
| `upgrade` | Upgrade Flutter dependencies |

## State Management Options

```bash
agentic_base create my_app --state cubit     # Default
agentic_base create my_app --state riverpod
agentic_base create my_app --state mobx
```

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
lib/
├── app/          # Bootstrap, flavors, observers
├── core/         # DI, network, theme, router, error handling
├── features/     # Feature modules (3-layer Clean Architecture)
├── shared/       # Shared widgets and utilities
└── l10n/         # Localization
```

## Flags

| Flag | Description | Default |
|------|-------------|---------|
| `--org` | Organization reverse domain | `com.example` |
| `--platforms` | Target platforms (comma-separated) | `android,ios,web` |
| `--state` | State management | `cubit` |
| `--flavors` | Build flavors | `dev,staging,prod` |
| `--primary-color` | Primary color hex | `6750A4` |
| `--no-interactive` | Skip prompts, use defaults | `false` |

## Documentation Index

1. [`01-project-overview-pdr.md`](./docs/01-project-overview-pdr.md)
2. [`02-codebase-summary.md`](./docs/02-codebase-summary.md)
3. [`03-code-standards.md`](./docs/03-code-standards.md)
4. [`04-system-architecture.md`](./docs/04-system-architecture.md)
5. [`05-project-roadmap.md`](./docs/05-project-roadmap.md)
6. [`06-deployment-guide.md`](./docs/06-deployment-guide.md)
7. [`07-design-guidelines.md`](./docs/07-design-guidelines.md)

## Local Development

```bash
dart pub get
dart analyze --fatal-infos
dart test
```

## Notes

- Root `docs/` is repo-level documentation.
- Generated Flutter app docs inside Mason templates are separate from the root `docs/` set.

## License

MIT
