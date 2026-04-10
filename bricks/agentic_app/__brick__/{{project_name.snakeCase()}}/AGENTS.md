# AGENTS.md

AI coding agent guide for `{{project_name.titleCase()}}`.

## 1. Starter Contract

- Flutter-layer source of truth:
  - `lib/app/**`
  - `lib/main*.dart`
  - `assets/i18n/**`
  - `.vscode/**`
  - `.idea/runConfigurations/**`
- Generated outputs:
  - `lib/app/i18n/translations.g.dart`
  - router, DI, freezed, json files under `lib/**`
- Forbidden leftovers:
  - `lib/app.dart`
  - `lib/flavors.dart`
  - `lib/pages/**`
  - `.idea/workspace.xml`
  - `.idea/modules.xml`
  - `.idea/libraries/**`

## 2. Architecture

This project follows Clean Architecture with Cubit state management.

```text
presentation -> domain <- data
```

Feature layout:

```text
lib/features/<name>/
├── data/
├── domain/
├── presentation/
├── <name>.module.dart
└── <name>.spec.yaml
```

## 3. Commands

```bash
flutter pub get
./tools/gen.sh
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=env/dev.env.example
flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=env/staging.env.example
flutter run --flavor prod -t lib/main_prod.dart --dart-define-from-file=env/prod.env.example
flutter test
dart analyze
```

## 4. Feature Workflow

1. Scaffold: `agentic_base feature profile`
2. Implement domain/data/presentation layers
3. Add translations:
   - `assets/i18n/profile/profile_en.i18n.yaml`
   - `assets/i18n/profile/profile_vi.i18n.yaml`
4. Run `make gen`
5. Register the route if needed
6. Add tests

## 5. Boundaries

- No relative imports
- No cross-layer imports from `data` to `presentation`
- No business logic in widgets
- No direct `GetIt` lookups inside leaf widgets
- No manual edits to generated files
- No user-local IDE files in git

## 6. CI/CD

- `.info/agentic.yaml` is the source of truth for `ci_provider`
- Generated projects ship one CI provider only:
  - `github` => `.github/workflows/*.yml`
  - `gitlab` => `.gitlab-ci.yml` and `.gitlab/ci/*.yml`
- `agentic_base deploy <dev|staging|prod>` must follow the stored provider, not a second flag
- GitLab native validation requires a macOS runner with shell executor, Xcode, and `tags: [macos]`
- Linux jobs may cover Dart-only work, but they do not satisfy the native validation gate
