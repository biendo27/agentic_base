# Architecture Overview

## Pattern: Clean Architecture

Dependencies flow inward — outer layers depend on inner layers, never the reverse.

```
presentation  →  domain  ←  data
(Cubit/Pages)    (Entities)   (Repos/Models)
```

## Layers

### domain (innermost — pure Dart, no Flutter)
- **Entities**: plain Dart classes, no serialization
- **Repository interfaces**: abstract contracts only
- **Use cases**: single-responsibility, depend only on repository interfaces

### data (implements domain contracts)
- **Models**: Freezed + JSON serialization (`*.g.dart` generated)
- **Repository implementations**: wire API responses to domain entities
- **Data sources**: `ApiClient` (Dio) calls

### presentation (Flutter UI)
- **Cubit**: extends `Cubit<State>`, holds business logic, calls use cases
- **State**: sealed class via `@freezed` — `initial`, `loading`, `success`, `failure`
- **Pages**: `BlocProvider` + `BlocBuilder`, no logic
- **Widgets**: pure UI, receive data via constructor

## Dependency Injection

`get_it` + `injectable` with auto-scanning:

```dart
@injectable          // transient
@singleton           // single instance
@lazySingleton       // created on first access
@module              // third-party bindings
```

Entry point: `lib/core/di/injection.dart` — call `configureDependencies()` in bootstrap.

## Feature Module Structure

```
lib/features/<name>/
├── data/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── cubit/
│   ├── pages/
│   └── widgets/
├── <name>.module.dart
└── <name>.spec.yaml
```

## App Bootstrap Sequence

1. `FlavorConfig.init(flavor)` — set env config
2. `bootstrap(() => App())` — initialize DI, BlocObserver, run app
3. `AppRouter` — auto_route handles navigation
4. `ScreenUtilInit` — responsive sizing setup
