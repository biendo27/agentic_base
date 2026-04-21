# Phase 03: Service Layout And DI Startup Split

## Context Links

- Research: [Firebase, DI, Layout Report](./research/researcher-firebase-di-layout-report.md)
- `/Users/biendh/base/lib/src/modules/module_integration_generator.dart`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/di/injection.dart`
- `/Users/biendh/base/docs/03-code-standards.md`

## Overview

Priority: P1. Status: Complete.

Move generated module services out of `lib/core`, make injectable the GetIt DI source of truth, and keep a separate generated startup seam.

## Key Insights

- `module_registrations.dart` duplicates injectable for GetIt projects.
- Riverpod still needs generated providers.
- Startup order is not DI. It needs a small explicit seam and safe hooks.
- `lib/core` should not be the dumping ground for every provider service.

## Requirements

- New generated service modules write to `lib/services/<capability>/...`.
- Keep `lib/core` for contracts, error, network, observability, router, theme, constants, extensions, DI.
- Replace GetIt `module_registrations.dart` with `module_startup.dart`.
- `injection.dart` runs injectable codegen first, then module startup if enabled.
- For GetIt/MobX, service implementations use injectable annotations.
- For Riverpod, generate providers without injectable imports/annotations.
- Scanner supports both `lib/services` and legacy `lib/core` during this migration.
- Startup hooks come from explicit module metadata or allowlist, not only regex `init()`.
- Startup policy fields: `id`, `dependsOn`, `stateProfiles`, `required`, `timeout`, `runWhen`, `onFailure`.
- Startup order is topological and deterministic.
- Firebase-backed startup hooks depend on `firebase_runtime`.
- Optional provider failures log once and continue; required failures fail bootstrap with a typed error.

## Architecture

```text
GetIt/MobX:
  build_runner -> injection.config.dart registers services
  bootstrap -> configureDependencies -> initializeModuleServices(getIt)

Riverpod:
  module_providers.dart defines providers
  bootstrap -> initializeModuleProviders(container)
```

## Related Code Files

- Modify `/Users/biendh/base/lib/src/modules/base_module.dart`.
- Modify `/Users/biendh/base/lib/src/modules/module_integration_generator.dart`.
- Modify all module files under `/Users/biendh/base/lib/src/modules/core/`.
- Modify all module files under `/Users/biendh/base/lib/src/modules/extended/`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/di/injection.dart`.
- Modify `/Users/biendh/base/test/src/modules/module_integration_generator_test.dart`.
- Modify `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`.

## Implementation Steps

1. Extend `AgenticModule` with explicit startup hook metadata, or add a focused `ModuleStartupPolicy` owned by module registry.
2. Split `ModuleIntegrationGenerator` if needed to stay below 200 LOC:
   - service scanner
   - GetIt startup writer
   - Riverpod provider/startup writer
3. Implement startup policy ordering, dependency validation, timeout behavior, and failure behavior.
4. Change GetIt output from registration file to startup file.
5. Update `injection.dart` import and call site.
6. Move module template output paths from `lib/core/<module>` to `lib/services/<module>`.
7. Update generated imports in module templates and starter feature code.
8. Keep transitional scanner support for existing `lib/core` services.
9. Update tests for GetIt, Riverpod, and MobX branches.

## Todo List

- [x] Design explicit startup hook model.
- [x] Add startup ordering/failure tests.
- [x] Split or refactor `ModuleIntegrationGenerator`.
- [x] Remove generated GetIt registration file.
- [x] Generate `module_startup.dart`.
- [x] Move module output paths to `lib/services`.
- [x] Update all imports/tests.

## Success Criteria

- New GetIt generated apps do not contain `lib/app/modules/module_registrations.dart`.
- `injection.config.dart` remains the only GetIt registration output.
- Startup hooks still initialize notifications/remote-config/crash-reporting safely.
- New generated module services land under `lib/services`.
- Riverpod generated apps still compile and have provider access.
- Cubit, Riverpod, and MobX generated apps all pass contract validation after DI/startup changes.

## Risk Assessment

- High import churn across modules and tests.
- Riverpod parity can regress if injectable annotations remain in module templates.
- Regex-based service discovery can miss services after path migration unless scanner is updated.

## Security Considerations

- Startup hooks must not eagerly require credentials.
- Services that handle user identifiers or crash logs must remain provider-swappable.

## Next Steps

Phase 04 builds Firebase setup on top of the new service layout.
