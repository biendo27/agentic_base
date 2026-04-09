# agentic_base

A Dart CLI tool that generates production-ready Flutter codebases optimized for AI-agent-driven development.

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

## Available Modules (25)

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

```
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

## License

MIT
