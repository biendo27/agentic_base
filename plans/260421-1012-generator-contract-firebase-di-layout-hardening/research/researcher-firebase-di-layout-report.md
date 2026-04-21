# Researcher Report: Firebase Setup, DI Startup, Service Layout

## Scope

Investigated Firebase multi-flavor setup, generated module DI/startup seams, and generated `lib/core` layout.

## Findings

- Repo policy already says generated apps must not auto-provision Firebase and must boot without product credentials.
- Default profile includes Firebase-backed modules, so the generated app must safely no-op until Firebase setup is explicitly completed.
- Current `ModuleIntegrationGenerator` scans only `lib/core`, detects `init()` by regex, and writes `module_registrations.dart` for GetIt even though injectable already owns DI. This creates two DI sources of truth.
- Best target: injectable owns GetIt registration; generated `module_startup.dart` owns startup order only.
- Riverpod still needs `module_providers.dart`, but templates must not unconditionally import injectable or emit `@LazySingleton`.
- `meup` validates the practical pattern: per-flavor Firebase options and flavorizr `firebase.config` paths. It is reference material, not a contract to copy directly.
- New generated services should move under `lib/services/<capability>`, while `lib/core` should keep app-shell and runtime-agnostic infrastructure.

## Recommended Shape

```text
lib/
├── app/
├── core/
│   ├── contracts/
│   ├── error/
│   ├── network/
│   ├── observability/
│   ├── router/
│   └── theme/
├── services/
│   ├── analytics/
│   ├── crash_reporting/
│   ├── firebase/
│   │   ├── firebase_runtime.dart
│   │   ├── firebase_options.dart
│   │   └── options/
│   └── notifications/
├── features/
└── shared/
```

## Risks

- Moving module files from `lib/core` to `lib/services` will invalidate many tests and generated imports.
- Startup cannot be inferred solely from `Future<void> init()` because Firebase-backed services must stay credential-safe.
- Scanner should support both `lib/services` and legacy `lib/core` during migration, then drop legacy later.

**Status:** DONE_WITH_CONCERNS

