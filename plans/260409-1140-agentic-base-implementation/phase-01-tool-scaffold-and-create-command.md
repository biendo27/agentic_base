# Phase 1 — Tool Scaffold & Create Command (v0.1.0)

## Context Links
- [Architecture Report](../reports/brainstorm-260409-1103-agentic-base-architecture.md)
- [Flutter CLI Landscape](../reports/researcher-260409-1103-flutter-cli-landscape.md)
- [Agentic Patterns](../reports/researcher-260409-1103-agentic-coding-patterns.md)

## Overview
- **Priority**: P1 (Critical — everything depends on this)
- **Status**: Completed
- **Effort**: 30h

Build the Dart CLI tool itself (`agentic_base`) + the `create` command + `gen` command + `doctor` command. The `create` command generates a full Flutter project with Cubit state management (default), complete M3 theme, routing, network, DI, error handling, i18n, assets, flavors, analysis, AGENTS.md, CLAUDE.md, tools/ scripts, Makefile, and build.yaml.

## Key Insights
- Mason `mason` package used as library (not CLI dependency)
- Bricks bundled in tool package (offline generation, no registry fetch)
- `very_good_cli` architecture as reference but not a fork
- Generated project must compile + pass `dart analyze` + pass `flutter test` on first run

## Requirements

### Functional
- `agentic_base create <app_name>` generates complete Flutter project
- Flags: `--org`, `--platforms`, `--flavors`, `--state`, `--primary-color`
- `agentic_base gen` runs daily code-gen pipeline (build_runner + slang + flutter_gen)
- `agentic_base doctor` checks environment health
- Generated project has: bootstrap, DI, routing, network, theme, error handling, i18n, responsive, flavors, analysis, env config, AGENTS.md, CLAUDE.md, Makefile, tools/, build.yaml, .info/agentic.yaml

### Non-Functional
- `create` completes in <60 seconds
- Generated project: 0 analyzer warnings
- Generated project: all default tests pass
- Tool: 0 `dart analyze` warnings
- Files: <200 LOC each

## Architecture

### Tool Package Structure
```
agentic_base/
├── bin/agentic_base.dart                    # CLI entry point
├── lib/
│   ├── agentic_base.dart                    # Public API barrel
│   └── src/
│       ├── cli/
│       │   ├── cli_runner.dart              # CommandRunner setup
│       │   └── commands/
│       │       ├── create_command.dart       # create <app_name>
│       │       ├── gen_command.dart          # gen (build_runner)
│       │       └── doctor_command.dart       # doctor
│       ├── generators/
│       │   └── project_generator.dart       # Orchestrates mason brick generation
│       ├── config/
│       │   └── agentic_config.dart          # .info/agentic.yaml read/write
│       └── tui/
│           ├── agentic_logger.dart          # mason_logger wrapper with custom styling
│           └── prompts.dart                 # User input prompts
├── bricks/
│   └── agentic_app/                         # Main project brick
│       ├── brick.yaml
│       ├── __brick__/                       # Template files (Mustache)
│       │   ├── {{project_name.snakeCase()}}/
│       │   │   ├── lib/
│       │   │   │   ├── app/
│       │   │   │   │   ├── app.dart
│       │   │   │   │   ├── bootstrap.dart
│       │   │   │   │   ├── flavors.dart
│       │   │   │   │   └── observers/app_bloc_observer.dart
│       │   │   │   ├── core/
│       │   │   │   │   ├── di/injection.dart
│       │   │   │   │   ├── error/failures.dart
│       │   │   │   │   ├── error/error_handler.dart
│       │   │   │   │   ├── network/api_client.dart
│       │   │   │   │   ├── network/interceptors/auth_interceptor.dart
│       │   │   │   │   ├── network/interceptors/error_interceptor.dart
│       │   │   │   │   ├── network/interceptors/logging_interceptor.dart
│       │   │   │   │   ├── router/app_router.dart
│       │   │   │   │   ├── router/guards/auth_guard.dart
│       │   │   │   │   ├── theme/app_theme.dart
│       │   │   │   │   ├── theme/color_schemes.dart
│       │   │   │   │   ├── theme/typography.dart
│       │   │   │   │   ├── theme/component_themes.dart
│       │   │   │   │   ├── theme/spacing.dart
│       │   │   │   │   ├── theme/radius.dart
│       │   │   │   │   ├── theme/extensions/theme_extensions.dart
│       │   │   │   │   ├── responsive/screen_util_init.dart
│       │   │   │   │   ├── constants/app_constants.dart
│       │   │   │   │   ├── constants/api_constants.dart
│       │   │   │   │   └── extensions/context_extensions.dart
│       │   │   │   ├── features/home/ (full 3-layer example)
│       │   │   │   ├── shared/widgets/
│       │   │   │   ├── shared/utils/
│       │   │   │   └── l10n/strings_en.i18n.yaml
│       │   │   ├── test/ (helpers + home feature tests)
│       │   │   ├── docs/ (6 numbered docs)
│       │   │   ├── tools/ (9 scripts + _common.sh)
│       │   │   ├── env/ (.env.example files)
│       │   │   ├── .github/workflows/ (ci.yml placeholder)
│       │   │   ├── .info/agentic.yaml
│       │   │   ├── AGENTS.md
│       │   │   ├── CLAUDE.md
│       │   │   ├── Makefile
│       │   │   ├── build.yaml
│       │   │   ├── flavorizr.yaml
│       │   │   ├── slang.yaml
│       │   │   ├── analysis_options.yaml
│       │   │   ├── pubspec.yaml
│       │   │   └── README.md
│       │   └── ...
│       └── hooks/
│           ├── pre_gen.dart                 # Validate variables
│           └── post_gen.dart                # Run flutter pub get + gen
├── test/
│   ├── src/
│   │   ├── cli/commands/create_command_test.dart
│   │   ├── cli/commands/gen_command_test.dart
│   │   ├── cli/commands/doctor_command_test.dart
│   │   └── generators/project_generator_test.dart
│   └── helpers/
├── pubspec.yaml
├── analysis_options.yaml
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Related Code Files

### Files to Create (Tool)
- `bin/agentic_base.dart` — CLI entry
- `lib/agentic_base.dart` — barrel export
- `lib/src/cli/cli_runner.dart` — CommandRunner
- `lib/src/cli/commands/create_command.dart`
- `lib/src/cli/commands/gen_command.dart`
- `lib/src/cli/commands/doctor_command.dart`
- `lib/src/generators/project_generator.dart`
- `lib/src/config/agentic_config.dart`
- `lib/src/tui/agentic_logger.dart`
- `lib/src/tui/prompts.dart`
- `pubspec.yaml` — tool dependencies
- `analysis_options.yaml`
- `README.md`, `CHANGELOG.md`, `LICENSE`

### Files to Create (Mason Brick — agentic_app)
- `bricks/agentic_app/brick.yaml`
- `bricks/agentic_app/hooks/pre_gen.dart`
- `bricks/agentic_app/hooks/post_gen.dart`
- All `__brick__/` template files (~60 files, see Architecture section)

### Files to Create (Tests)
- `test/src/cli/commands/create_command_test.dart`
- `test/src/cli/commands/gen_command_test.dart`
- `test/src/cli/commands/doctor_command_test.dart`
- `test/src/generators/project_generator_test.dart`
- `test/helpers/` — test utilities

## Implementation Steps

### Step 1: Tool Package Setup
1. Run `dart create -t package agentic_base` or manually create pubspec.yaml
2. Configure pubspec.yaml with dependencies:
   ```yaml
   dependencies:
     args: ^2.x
     mason: ^0.x
     mason_logger: ^0.x
     mason: ^0.x
     yaml_edit: ^2.x
     path: ^1.x
     pub_updater: ^0.x
   dev_dependencies:
     test: ^1.x
     mocktail: ^1.x
     very_good_analysis: ^6.x
   ```
3. Create `bin/agentic_base.dart` with CLI entry point
4. Create `lib/src/cli/cli_runner.dart` extending `CommandRunner`
5. Create `lib/src/tui/agentic_logger.dart` wrapping `mason_logger`
6. Verify: `dart run bin/agentic_base.dart --help` works

### Step 2: Doctor Command
1. Create `doctor_command.dart` — checks Flutter SDK, Dart SDK, FVM, build_runner
2. Use `Process.run` to verify each tool
3. Display colored health report (green ✓, yellow ⚠, red ✗)
4. Write test for doctor command
5. Verify: `dart run bin/agentic_base.dart doctor` works

### Step 3: Mason Brick — Core App Template
1. Create `bricks/agentic_app/brick.yaml` with variables:
   - `project_name`, `org`, `platforms`, `flavors`, `state_management`, `primary_color`
2. Create `__brick__/` directory structure (see Architecture)
3. Write template files for `lib/app/`:
   - `app.dart` — MaterialApp.router with auto_route
   - `bootstrap.dart` — 7-step runZonedGuarded
   - `flavors.dart` — Flavor enum + config
   - `observers/app_bloc_observer.dart`
4. Write template files for `lib/core/di/`:
   - `injection.dart` — @InjectableInit setup
5. Write template files for `lib/core/error/`:
   - `failures.dart` — Freezed sealed Failure hierarchy
   - `error_handler.dart` — Global handler
6. Write template files for `lib/core/network/`:
   - `api_client.dart` — Dio factory with interceptor toggle
   - `interceptors/auth_interceptor.dart`
   - `interceptors/error_interceptor.dart`
   - `interceptors/logging_interceptor.dart`

### Step 4: Mason Brick — Router & Theme
1. Write `lib/core/router/app_router.dart` — auto_route config
2. Write `lib/core/router/guards/auth_guard.dart`
3. Write full M3 theme:
   - `theme/app_theme.dart` — ThemeData factory (light+dark)
   - `theme/color_schemes.dart` — Full ColorScheme with seed color support
   - `theme/typography.dart` — Complete M3 TextTheme (15 styles)
   - `theme/component_themes.dart` — ALL component themes
   - `theme/spacing.dart` — 4/8/12/16/24/32/48/64
   - `theme/radius.dart` — sm/md/lg/xl
   - `theme/extensions/theme_extensions.dart` — Custom ThemeExtension
4. Write `lib/core/responsive/screen_util_init.dart`

### Step 5: Mason Brick — Home Feature (Reference Implementation)
1. Create full 3-layer home feature:
   - `data/models/home_item.dart` (freezed DTO)
   - `data/repositories/home_repository_impl.dart`
   - `domain/entities/home_item.dart`
   - `domain/repositories/home_repository.dart` (abstract contract)
   - `domain/usecases/get_home_items.dart`
   - `presentation/cubit/home_cubit.dart`
   - `presentation/cubit/home_state.dart` (freezed sealed)
   - `presentation/pages/home_page.dart`
   - `presentation/widgets/home_item_card.dart`
   - `home.spec.yaml`
   - `home.module.dart` (DI registration)
2. Create test files:
   - `test/features/home/home_cubit_test.dart`
   - `test/helpers/pump_app.dart`
   - `test/helpers/mock_helpers.dart`

### Step 6: Mason Brick — Config & DevOps Files
1. Write `pubspec.yaml` template (all core dependencies, build.yaml, analysis_options.yaml)
2. Write `build.yaml` (7 generators)
3. Write `flavorizr.yaml`, `slang.yaml`
4. Write `analysis_options.yaml` (very_good_analysis)
5. Write env/ files: `dev.env.example`, `staging.env.example`, `prod.env.example`
6. Write `.info/agentic.yaml` template
7. Write `AGENTS.md` (extended: 5 sections + hooks + code examples)
8. Write `CLAUDE.md` (hooks + conventions + boundaries)
9. Write `Makefile` (delegates to tools/)
10. Write `tools/` scripts: `_common.sh`, `gen.sh`, `test.sh`, `build.sh`, `clean.sh`, `setup.sh`, `format.sh`, `lint.sh`, `release.sh`, `ci-check.sh`
11. Write `docs/` numbered files (6)
12. Write `README.md`
13. Write `l10n/strings_en.i18n.yaml`
14. Write `main_dev.dart`, `main_staging.dart`, `main_prod.dart` (per flavor entries)

### Step 7: Create Command
1. Create `create_command.dart`:
   - Parse args (app_name, --org, --platforms, --flavors, --state, --primary-color)
   - Validate inputs
   - Call `ProjectGenerator.generate()`
2. Create `project_generator.dart`:
   - Load bundled brick
   - Set Mason variables from args
   - Generate via `mason`
   - Run post-gen: `flutter pub get`, `dart run build_runner build`
3. Write tests for create command

### Step 8: Gen Command
1. Create `gen_command.dart`:
   - Read `.info/agentic.yaml` to know project state
   - Run sequential: `dart run build_runner build --delete-conflicting-outputs`
   - Run `dart format lib test`
   - Display progress with spinners
2. Write tests

### Step 9: Bundle & Verify
1. Bundle mason brick: `mason bundle bricks/agentic_app -t dart`
2. Copy bundle to `lib/src/generators/bundles/`
3. Test full flow: `dart run bin/agentic_base.dart create test_app --org com.test`
4. Verify generated project:
   - `cd test_app && flutter pub get`
   - `dart analyze` → 0 warnings
   - `flutter test` → all pass
   - `dart run build_runner build` → no errors
5. Run tool tests: `dart test`

## Todo List

- [x] Step 1: Tool package setup (pubspec, CLI entry, CommandRunner)
- [x] Step 2: Doctor command
- [x] Step 3: Mason brick — core app (bootstrap, DI, error, network)
- [x] Step 4: Mason brick — router + full M3 theme
- [x] Step 5: Mason brick — home feature (reference implementation)
- [x] Step 6: Mason brick — config & DevOps (build.yaml, env, AGENTS.md, tools/, docs/)
- [x] Step 7: Create command (args, generator, post-gen)
- [x] Step 8: Gen command (build_runner wrapper)
- [x] Step 9: Bundle, integration test, verify generated project

## Success Criteria

- [x] `dart run bin/agentic_base.dart doctor` reports environment health
- [x] `dart run bin/agentic_base.dart create my_app --org com.test` generates project
- [x] Generated project: `dart analyze` → 0 warnings
- [x] Generated project: `flutter test` → all pass
- [x] Generated project: `dart run build_runner build` → no errors
- [x] Generated project has: AGENTS.md, CLAUDE.md, Makefile, tools/, docs/, build.yaml, .info/
- [x] Generated project theme: full M3 (light+dark, all component themes)
- [x] Generated project home feature: full 3-layer clean architecture
- [x] Tool: `dart analyze` → 0 warnings
- [x] Tool: `dart test` → all pass
- [x] All files <200 LOC

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Mason brick template syntax errors | Build fails | Test brick generation in CI |
| Package version conflicts in generated pubspec | flutter pub get fails | Pin exact versions, test with latest Flutter stable |
| build_runner chain breaks | Generated code-gen fails | Test each generator individually |
| M3 theme API changes | Theme compilation errors | Pin flutter_sdk version in pubspec |
| Post-gen hooks fail silently | Incomplete project | Check exit codes, log errors |

## Security Considerations
- No secrets in generated templates (env/ files are .example only)
- .gitignore includes env/, .env*, build/, *.g.dart
- AGENTS.md boundaries: never commit secrets

## Next Steps
→ Phase 2: Feature & Module System (depends on Phase 1 completion)
