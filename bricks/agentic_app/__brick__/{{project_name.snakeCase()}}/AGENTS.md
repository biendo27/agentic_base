# AGENTS.md

AI coding agent guide for `{{project_name.titleCase()}}`.

---

## 1. Project Architecture

This project follows **Clean Architecture** with **Cubit** state management.

### Dependency Direction
```
presentation → domain ← data
```

### Layer Responsibilities
- **data**: API models, repository implementations, data sources
- **domain**: Entities, repository interfaces, use cases (pure Dart)
- **presentation**: Pages, widgets, Cubit, State (UI logic only)

### Feature Structure
```
lib/features/<name>/
├── data/
│   ├── models/          # Freezed JSON models (*.g.dart generated)
│   └── repositories/    # Repository implementations
├── domain/
│   ├── entities/        # Pure Dart classes
│   ├── repositories/    # Abstract interfaces
│   └── usecases/        # Single-responsibility use cases
├── presentation/
│   ├── cubit/           # Cubit + sealed State (freezed)
│   ├── pages/           # Route entry points
│   └── widgets/         # Feature-local widgets
├── <name>.module.dart   # Injectable module registration
└── <name>.spec.yaml     # Feature metadata for agentic_base
```

### DI (get_it + injectable)
- Annotate with `@injectable`, `@singleton`, `@lazySingleton`
- Run `make gen` after adding annotations
- Entry point: `lib/core/di/injection.dart`

---

## 2. Commands

### agentic_base CLI
```bash
agentic_base add feature <name>    # Scaffold a new feature
agentic_base add module <name>     # Add a shared module
agentic_base remove feature <name> # Remove a feature
```

### Flutter
```bash
flutter pub get                    # Install dependencies
flutter run --flavor dev           # Run dev flavor
flutter run --flavor staging       # Run staging flavor
flutter run --flavor prod          # Run production flavor
flutter build apk --flavor prod    # Build production APK
flutter test                       # Run all tests
dart analyze                       # Static analysis
```

### Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs
```

### Makefile Shortcuts
```bash
make gen        # Code generation + format
make test       # Run tests
make lint       # Dart analyze
make build      # Build APK
make clean      # Clean + pub get
make setup      # First-time setup
make format     # Format lib/ and test/
make ci-check   # Full CI check locally
```

---

## 3. Code Standards

### Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/methods: `camelCase`
- Constants: `kCamelCase`
- Cubits: `<Feature>Cubit` / States: `<Feature>State`

### Imports
- Always use **package imports**, never relative imports
  ```dart
  // Good
  import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/home_item.dart';
  // Bad
  import '../../../domain/entities/home_item.dart';
  ```

### File Size
- Keep files under 200 lines
- Split large widgets into sub-widgets in the `widgets/` directory

### Generated Files
- Never manually edit: `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`
- Run `make gen` to regenerate after model changes

### Analysis
- Config: `analysis_options.yaml` (very_good_analysis)
- `public_member_api_docs` is disabled for internal code
- Fix all warnings before committing

---

## 4. Feature Development

Step-by-step guide to add a new feature (e.g., `profile`):

**Step 1 — Scaffold**
```bash
agentic_base add feature profile
```

**Step 2 — Define domain layer**
1. Create entity: `lib/features/profile/domain/entities/profile.dart`
2. Create repository interface: `lib/features/profile/domain/repositories/profile_repository.dart`
3. Create use case: `lib/features/profile/domain/usecases/get_profile.dart`

**Step 3 — Implement data layer**
1. Create model with `@freezed` + `@JsonSerializable`
2. Implement repository using `ApiClient` (injected via constructor)
3. Run `make gen` to generate serialization code

**Step 4 — Build presentation layer**
1. Define sealed `ProfileState` with `@freezed`
2. Implement `ProfileCubit` extending `Cubit<ProfileState>`
3. Build `ProfilePage` using `BlocBuilder<ProfileCubit, ProfileState>`

**Step 5 — Register route**
1. Add `@RoutePage()` annotation to page
2. Run `make gen` to update `app_router.gr.dart`
3. Add route to `AppRouter` in `lib/core/router/app_router.dart`

**Step 6 — Write tests**
```
test/features/profile/
├── profile_cubit_test.dart
└── mock_profile_repository.dart
```

---

## 5. Boundaries

Things the AI agent MUST NOT do:

- **No direct pubspec.yaml edits** — use `agentic_base add/remove` commands
- **No editing generated files** — `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`
- **No committing secrets** — `.env` files, API keys, credentials
- **No relative imports** — always use package imports
- **No cross-layer imports** — `data` must not import from `presentation`
- **No business logic in widgets** — delegate to Cubit
- **No direct `GetIt` calls in widgets** — use constructor injection or `context.read<>()`
- **No skipping `make gen`** after model/annotation changes
- **No force-push** to `main` or `develop` branches
