# Phase 2 — Feature & Module System (v0.2.0)

## Context Links
- [Architecture Report](../reports/brainstorm-260409-1103-agentic-base-architecture.md) — Sections 6, 16.3, 16.9, 16.10
- [Phase 1](./phase-01-tool-scaffold-and-create-command.md)

## Overview
- **Priority**: P1
- **Status**: Pending
- **Effort**: 25h
- **Depends on**: Phase 1

Build `feature` command (scaffold new features), `add` command (install built-in modules), `remove` command, module auto-wiring into DI, and `.info/agentic.yaml` config system. Ship 8 core modules: analytics, crashlytics, auth, local_storage, connectivity, permissions, secure_storage, logging.

## Requirements

### Functional
- `agentic_base feature <name>` scaffolds 3-layer feature (data/domain/presentation + spec.yaml + module.dart)
- `agentic_base feature <name> --simple` scaffolds flat feature (no domain layer)
- `agentic_base add <module>` installs module: adds packages, copies files, wires DI, updates .info/agentic.yaml
- `agentic_base remove <module>` uninstalls module: removes files, cleans pubspec, updates config
- Module conflict detection: warn + block incompatible modules
- .info/agentic.yaml tracks: tool_version, state_management, installed modules, platforms, flavors

### Non-Functional
- Module install <30 seconds
- Each module independently testable
- Module files <200 LOC each

## Architecture

### AgenticModule Contract (State-Agnostic)
**Red team fix**: Contract must be state-agnostic from day 1 to support Cubit/Riverpod/MobX without refactoring.

```dart
abstract class AgenticModule {
  String get name;
  String get description;
  List<String> get dependencies;
  List<String> get devDependencies;
  List<String> get conflictsWith;
  List<String> get requiresModules;      // dependency modules
  List<String> get platformSteps;        // manual platform config steps for user
  
  /// State-agnostic: impl delegates to state-specific wiring strategy
  Future<void> install(ProjectContext ctx);
  Future<void> uninstall(ProjectContext ctx);
  Future<void> wireIntoDI(ProjectContext ctx, DIStrategy strategy);
  Future<void> generateTests(ProjectContext ctx);
}

/// Strategy pattern for DI wiring per state management
abstract class DIStrategy {
  Future<void> registerModule(String moduleName, ProjectContext ctx);
  Future<void> unregisterModule(String moduleName, ProjectContext ctx);
}

class GetItDIStrategy implements DIStrategy { ... }    // Cubit + MobX
class RiverpodDIStrategy implements DIStrategy { ... }  // Riverpod
```

### Module Installation Flow
```
add <module> → read agentic.yaml → check conflicts → add deps to pubspec 
→ copy template files (state-aware) → wire into DI → generate test stubs 
→ update agentic.yaml → flutter pub get → build_runner if needed
```

### Feature Template Structure (Cubit)
```
features/<name>/
├── data/
│   ├── models/<name>_model.dart           (freezed)
│   ├── sources/<name>_remote_source.dart
│   └── repositories/<name>_repository_impl.dart
├── domain/
│   ├── entities/<name>_entity.dart
│   ├── repositories/<name>_repository.dart (contract)
│   └── usecases/get_<name>.dart
├── presentation/
│   ├── cubit/<name>_cubit.dart
│   ├── cubit/<name>_state.dart            (freezed sealed)
│   ├── pages/<name>_page.dart
│   └── widgets/
├── <name>.spec.yaml
└── <name>.module.dart
```

## Related Code Files

### Files to Create (Tool)
- `lib/src/cli/commands/add_command.dart`
- `lib/src/cli/commands/remove_command.dart`
- `lib/src/cli/commands/feature_command.dart`
- `lib/src/generators/feature_generator.dart`
- `lib/src/generators/module_generator.dart`
- `lib/src/modules/base_module.dart` — abstract AgenticModule
- `lib/src/modules/module_registry.dart` — registry of all modules
- `lib/src/modules/core/analytics_module.dart`
- `lib/src/modules/core/crashlytics_module.dart`
- `lib/src/modules/core/auth_module.dart`
- `lib/src/modules/core/local_storage_module.dart`
- `lib/src/modules/core/connectivity_module.dart`
- `lib/src/modules/core/permissions_module.dart`
- `lib/src/modules/core/secure_storage_module.dart`
- `lib/src/modules/core/logging_module.dart`
- `lib/src/config/agentic_config.dart` — update with module tracking

### Mason Bricks to Create
- `bricks/agentic_feature/` — Cubit feature template (3-layer + flat)
- `bricks/modules/cubit/analytics/` — analytics module for Cubit
- `bricks/modules/cubit/crashlytics/`
- `bricks/modules/cubit/auth/`
- `bricks/modules/cubit/local_storage/`
- `bricks/modules/cubit/connectivity/`
- `bricks/modules/cubit/permissions/`
- `bricks/modules/cubit/secure_storage/`
- `bricks/modules/cubit/logging/`

### Tests
- `test/src/cli/commands/add_command_test.dart`
- `test/src/cli/commands/remove_command_test.dart`
- `test/src/cli/commands/feature_command_test.dart`
- `test/src/modules/module_registry_test.dart`

## Implementation Steps

### Step 1: Config System
1. Update `agentic_config.dart` to read/write `.info/agentic.yaml`
2. Track: tool_version, project_name, org, state_management, platforms, flavors, modules[], flutter_version, dart_version, timestamps
3. Add version compatibility check
4. Write tests

### Step 2: Feature Command + Brick
1. Create `bricks/agentic_feature/` with Cubit 3-layer template
2. Variables: feature_name, simple (bool)
3. Template generates: data/domain/presentation + spec.yaml + module.dart
4. Simple mode: flat structure (no domain layer)
5. Create `feature_command.dart` — reads agentic.yaml for state choice, generates feature
6. Create `feature_generator.dart` — loads brick, generates files
7. Write tests

### Step 3: Module Contract + Registry
1. Create `base_module.dart` — abstract AgenticModule class
2. Create `module_registry.dart` — maps module names to implementations
3. Add ProjectContext class (project path, state mgmt, installed modules)
4. Implement conflict checking logic

### Step 4: Core Modules (8)
For each module (analytics, crashlytics, auth, local_storage, connectivity, permissions, secure_storage, logging):
1. Create module class implementing AgenticModule
2. Create mason brick with template files:
   - Service contract (abstract class)
   - Service implementation (concrete)
   - DI module registration (@module)
   - Test stubs
3. Each module contract-based (SOLID: swappable implementations)
4. Example: crashlytics has `CrashReportingService` contract, `FirebaseCrashlyticsService` impl, `SentryCrashlyticsService` as documented alternative

### Step 5: Add Command
1. Create `add_command.dart` — parse module name, validate
2. Flow: check agentic.yaml → check conflicts → call module.install() → update config
3. Handle: pubspec.yaml modification, file copying, DI wiring
4. Display progress with spinners
5. Write tests

### Step 6: Remove Command
1. Create `remove_command.dart`
2. Flow: check module exists in config → call module.uninstall() → clean pubspec → update config
3. Handle: file deletion, pubspec cleanup, DI unwiring
4. Write tests

### Step 7: Integration Test
1. Test: create project → add analytics → add crashlytics → remove analytics
2. Verify: pubspec correct, DI config correct, agentic.yaml correct
3. Verify: `dart analyze` clean, `flutter test` pass after add/remove

## Todo List
- [ ] Config system (.info/agentic.yaml read/write + version compat)
- [ ] Feature command + brick (3-layer + flat)
- [ ] Module contract + registry + conflict checking
- [ ] Core module: analytics (firebase_analytics)
- [ ] Core module: crashlytics (firebase_crashlytics / sentry)
- [ ] Core module: auth (firebase_auth)
- [ ] Core module: local_storage (hive_ce)
- [ ] Core module: connectivity (connectivity_plus)
- [ ] Core module: permissions (permission_handler)
- [ ] Core module: secure_storage (flutter_secure_storage)
- [ ] Core module: logging (talker + talker_dio_logger)
- [ ] Add command
- [ ] Remove command
- [ ] Integration test (create → add → remove → verify)

## Success Criteria
- [ ] `agentic_base feature auth` generates 3-layer feature
- [ ] `agentic_base feature settings --simple` generates flat feature
- [ ] `agentic_base add analytics` installs + wires + updates config
- [ ] `agentic_base remove analytics` uninstalls cleanly
- [ ] Conflicting modules blocked (e.g., crashlytics vs sentry)
- [ ] .info/agentic.yaml correctly tracks all state
- [ ] Generated project compiles after add/remove operations
- [ ] All 8 core modules independently installable

## Risk Assessment
| Risk | Impact | Mitigation |
|------|--------|------------|
| pubspec.yaml manipulation errors | Broken deps | Use yaml package for safe YAML editing |
| DI wiring order matters | Runtime crash | Injectable handles order via annotation scan |
| Module removal leaves orphan imports | Compile error | Module.uninstall() cleans all references |

## Next Steps
→ Phase 3: Testing & Eval (depends on Phase 2)
