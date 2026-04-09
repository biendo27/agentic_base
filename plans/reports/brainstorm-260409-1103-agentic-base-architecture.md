# agentic_base — Architecture Brainstorm Report

**Date**: 2026-04-09 | **Status**: Final  
**Scope**: Dart CLI tool generating Flutter Agentic Codebases  
**Distribution**: pub.dev (MIT license)

---

## 1. Problem Statement

Need a Dart CLI tool (`agentic_base`) that generates production-ready Flutter codebases optimized for AI-agent-driven development. Human = 5% architect/reviewer, AI agent = 95% builder. Generated codebase must be self-describing so AI agents (Claude Code, Copilot, Cursor, Codex) can navigate and modify it with minimal guidance.

**Core differentiator vs existing tools (very_good_cli, mason, stacked_cli):**
- AI-agent-friendly architecture (self-describing code + AGENTS.md + eval contracts)
- Integrated code-gen (build_runner pre-configured, not manual)
- CI/CD scaffolding (GitHub Actions + Fastlane generated)
- Hybrid module system (built-in auto-wired + mason community bricks)
- Full Material 3 theme generated (not just seed color)
- Multi-state-management support (Cubit default + Riverpod + others)

---

## 2. Architecture Decisions

### 2.1 Tool Stack (the CLI itself)
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Language | Dart | Native pub.dev distribution, Flutter ecosystem natural fit |
| Template engine | Mason (mason_api) | Battle-tested, community bricks compatible, Mustache syntax |
| CLI framework | args + mason_logger | Standard Dart CLI stack, colored output, progress indicators |
| TUI level | Basic (colors + progress + spinners) | Pragmatic — ship features, not fancy UI. No TUI framework needed |
| Distribution | `dart pub global activate agentic_base` | Standard pub.dev workflow |

### 2.2 Generated Project Architecture
| Decision | Choice | Rationale |
|----------|--------|-----------|
| Structure | Single app (not monorepo) | 90% use case. Simpler, faster to scaffold |
| Feature arch | Pragmatic Clean Architecture | 3 layers (data/domain/presentation) per feature. Skip domain for simple features |
| State mgmt (default) | Cubit + flutter_bloc + freezed sealed states | Most production-tested. VGV standard |
| State options | Cubit (default), Riverpod, MobX, Signals | See Section 3 for compatibility matrix |
| DI | get_it + injectable (Cubit/MobX), riverpod_annotation (Riverpod) | Adapts per state choice |
| Error handling | fpdart TaskEither everywhere | Typed errors, no exceptions escape domain layer |
| Router | auto_route | Type-safe, code-gen, deep link support |
| Network | dio + retrofit | Code-gen endpoints, interceptor pipeline |
| Models | freezed + json_annotation | Immutable models, no equatable needed |
| i18n | slang | Type-safe, code-gen, YAML-based translations |
| Assets | flutter_gen | Type-safe asset access |
| Analysis | very_good_analysis | Strict linting rules, industry standard |
| Responsive | flutter_screenutil | Mobile-primary, design-size based scaling |
| Env config | --dart-define-from-file | No envied dependency. env/ folder with .env.example templates |
| Obfuscation | ALL flavors | --obfuscate --split-debug-info in all builds |
| Flavors | flutter_flavorizr | dev, staging, prod by default |
| CI/CD | GitHub Actions + Fastlane | Auto-generated workflows |
| Agent config | AGENTS.md + CLAUDE.md | Vendor-neutral + Claude-specific hooks |
| Backend | Agnostic | Contract-based. User implements Firebase/Supabase/custom |
| Testing | alchemist + mocktail + bloc_test + patrol | Golden + unit + widget + integration |
| Bootstrap | runZonedGuarded | 3-layer error capture (zone, bloc observer, framework) |

### 2.3 Agent Config Strategy (AGENTS.md)
Minimum effective config — 5 sections solving 80% of agent inference:
1. **Stack versions** — Flutter/Dart version, key package versions
2. **Commands** — build, test, gen, lint, deploy commands
3. **Architecture with examples** — one real code snippet per pattern
4. **Folder structure** — explicit directory mapping
5. **Boundaries** — always/ask-first/never rules

CLAUDE.md adds: Claude-specific hooks (pre-commit, post-merge), Claude Code skill references.

---

## 3. State Management Compatibility Matrix

**Core principle**: State management choice affects DI, routing, and testing patterns. Not all combinations are compatible.

| State Mgmt | DI System | Router | Testing | Compatible? |
|------------|-----------|--------|---------|-------------|
| **Cubit** (default) | get_it + injectable | auto_route | bloc_test + mocktail | Full |
| **Riverpod** | riverpod_annotation (own DI) | auto_route | riverpod test + mocktail | Full (no get_it) |
| **MobX** | get_it + injectable | auto_route | mobx test + mocktail | Full |
| **Signals** | get_it + injectable | auto_route | standard test + mocktail | Full |
| ~~**GetX**~~ | ~~GetX bindings~~ | ~~GetX routing~~ | ~~GetX test~~ | **INCOMPATIBLE** |

**GetX excluded**: GetX replaces routing (conflicts auto_route), DI (conflicts get_it), network patterns. Supporting GetX = entirely different project template = separate tool. Not worth the complexity.

**v1 supported**: Cubit (default) + Riverpod + MobX  
**v2 consideration**: Signals (once ecosystem matures)

### Template Strategy per State
Separate mason brick sets per state management:
```
bricks/
  app_base/                    # core app (shared across all)
  features/
    cubit_feature/             # Cubit feature template
    riverpod_feature/          # Riverpod feature template  
    mobx_feature/              # MobX feature template
  modules/
    cubit/                     # Module wiring for Cubit (get_it)
    riverpod/                  # Module wiring for Riverpod
    mobx/                      # Module wiring for MobX (get_it)
```

---

## 4. CLI Commands

```
agentic_base create <app_name>          # Create new project
  --org <com.example>                   # Organization identifier
  --platforms <ios,android>             # Target platforms
  --flavors <dev,staging,prod>          # Build flavors
  --state <cubit|riverpod|mobx>         # State management (default: cubit)
  --primary-color <#hex>                # Theme seed color (optional)
  
agentic_base add <module>               # Add built-in module
agentic_base remove <module>            # Remove built-in module (files + pubspec + DI + config)
  # notifications, analytics, crashlytics, auth, local_storage,
  # connectivity, permissions, secure_storage, logging,
  # deep_link, in_app_review, share, social_login,
  # ads, payments, remote_config, feature_flags,
  # image_picker, camera, video_player, qr_scanner,
  # location, maps, biometric, file_manager,
  # app_update, webview, onboarding

agentic_base feature <name>             # Scaffold new feature module
  --simple                              # Skip domain layer (flat structure)

agentic_base gen                        # Run all code generation
  # build_runner + slang + flutter_gen + flavorizr

agentic_base eval [feature]             # Run tests for feature or all
  --coverage                            # Generate coverage report

agentic_base brick <add|remove|list>    # Manage community mason bricks

agentic_base deploy <dev|staging|prod>  # Trigger GitHub Actions deploy

agentic_base upgrade                    # Upgrade Flutter SDK + packages

agentic_base doctor                     # Check environment health

agentic_base init                       # Add agentic_base to existing project
```

---

## 5. Generated Project Structure

```
my_app/
├── lib/
│   ├── app/
│   │   ├── app.dart                     # MaterialApp with auto_route
│   │   ├── bootstrap.dart               # runZonedGuarded + DI init + error capture
│   │   ├── flavors.dart                 # Flavor enum + per-flavor config
│   │   └── observers/
│   │       └── app_bloc_observer.dart   # Global Cubit/Bloc observer
│   │
│   ├── core/
│   │   ├── di/
│   │   │   ├── injection.dart           # get_it setup (injectable)
│   │   │   └── injection.config.dart    # generated
│   │   ├── error/
│   │   │   ├── failures.dart            # Failure sealed class hierarchy
│   │   │   └── error_handler.dart       # Global error handling
│   │   ├── network/
│   │   │   ├── api_client.dart          # Dio instance factory
│   │   │   ├── interceptors/
│   │   │   │   ├── auth_interceptor.dart
│   │   │   │   ├── error_interceptor.dart
│   │   │   │   └── logging_interceptor.dart
│   │   │   └── endpoints/               # Retrofit endpoint interfaces
│   │   ├── router/
│   │   │   ├── app_router.dart          # auto_route config
│   │   │   ├── app_router.gr.dart       # generated
│   │   │   └── guards/                  # Route guards (auth, etc.)
│   │   ├── theme/
│   │   │   ├── app_theme.dart           # ThemeData factory
│   │   │   ├── color_schemes.dart       # Light + dark ColorScheme
│   │   │   ├── typography.dart          # M3 TextTheme
│   │   │   ├── component_themes.dart    # AppBar, Card, Button, Input, etc.
│   │   │   ├── spacing.dart             # Spacing constants
│   │   │   ├── radius.dart              # Border radius constants
│   │   │   └── extensions/
│   │   │       └── theme_extensions.dart # Custom ThemeExtension
│   │   ├── responsive/
│   │   │   └── screen_util_init.dart    # ScreenUtil initialization
│   │   ├── constants/
│   │   │   ├── app_constants.dart       # App-wide constants
│   │   │   └── api_constants.dart       # API endpoints
│   │   └── extensions/
│   │       ├── context_extensions.dart  # BuildContext extensions
│   │       ├── string_extensions.dart
│   │       └── date_extensions.dart
│   │
│   ├── features/
│   │   └── home/                        # Default feature (example)
│   │       ├── data/
│   │       │   ├── models/              # Freezed DTOs
│   │       │   ├── sources/             # Remote/local data sources
│   │       │   └── repositories/        # Repository implementations
│   │       ├── domain/
│   │       │   ├── entities/            # Domain models
│   │       │   ├── repositories/        # Abstract contracts
│   │       │   └── usecases/            # Business logic
│   │       ├── presentation/
│   │       │   ├── cubit/               # HomeCubit + HomeState
│   │       │   ├── pages/               # HomeScreen
│   │       │   └── widgets/             # Feature-specific widgets
│   │       ├── home.spec.yaml           # Acceptance criteria
│   │       └── home.module.dart         # DI registration for this feature
│   │
│   ├── shared/
│   │   ├── widgets/                     # Shared reusable widgets
│   │   └── utils/                       # Shared utilities
│   │
│   └── l10n/                            # slang i18n
│       ├── strings_en.i18n.yaml
│       └── strings_vi.i18n.yaml         # Vietnamese default
│
├── test/
│   ├── features/
│   │   └── home/
│   │       ├── home_cubit_test.dart
│   │       ├── home_screen_test.dart
│   │       └── home_flow_test.dart
│   ├── helpers/
│   │   ├── pump_app.dart                # Test helper: pump with all providers
│   │   ├── mock_helpers.dart            # Common mocks
│   │   └── golden_helper.dart           # Alchemist golden test config
│   └── goldens/                         # Golden test snapshots
│
├── integration_test/
│   └── app_test.dart                    # Patrol integration tests
│
├── docs/                                # Project documentation (source of truth)
│   ├── 01-architecture.md              # Architecture overview
│   ├── 02-code-standards.md            # Coding conventions
│   ├── 03-features.md                  # Feature catalog (auto-updated)
│   ├── 04-deployment.md                # Deploy guide
│   ├── 05-api-contracts.md             # API endpoint contracts
│   └── 06-testing-guide.md             # Testing guide + spec.yaml format
│
├── tools/                               # Custom scripts
│   ├── gen.sh                           # build_runner + slang + flutter_gen
│   ├── clean.sh                         # Clean build artifacts
│   └── setup.sh                         # First-time project setup
│
├── .github/
│   └── workflows/
│       ├── ci.yml                       # PR: lint + test + build
│       ├── cd-dev.yml                   # Deploy to dev environment
│       ├── cd-staging.yml               # Deploy to staging
│       ├── cd-prod.yml                  # Deploy to production
│       └── release.yml                  # Fastlane store release
│
├── .info/                               # agentic_base tool metadata
│   └── agentic.yaml                     # Project config (state choice, modules installed, etc.)
│
├── fastlane/
│   ├── Appfile
│   ├── Fastfile
│   └── Matchfile                        # iOS code signing
│
├── env/                                 # Per-flavor env files
│   ├── dev.env                          # Actual (gitignored)
│   ├── staging.env
│   ├── prod.env
│   ├── dev.env.example                  # Template (committed)
│   ├── staging.env.example
│   └── prod.env.example
│
├── AGENTS.md                            # AI agent instructions (vendor-neutral)
├── CLAUDE.md                            # Claude-specific hooks + config
├── Makefile                             # make gen, make test, make build, etc.
├── build.yaml                           # build_runner config
├── flavorizr.yaml                       # Flavor config
├── slang.yaml                           # i18n config
├── analysis_options.yaml                # very_good_analysis
├── pubspec.yaml
└── README.md
```

---

## 6. Module System Architecture

### 6.1 Built-in Module Contract
Every built-in module follows this contract:
```dart
abstract class AgenticModule {
  String get name;
  List<String> get dependencies;        // pubspec dependencies
  List<String> get devDependencies;      // pubspec dev_dependencies
  List<String> get assets;              // assets to copy
  List<String> get conflictsWith;       // incompatible modules
  
  Future<void> install(ProjectContext ctx);  // Add files + update configs
  Future<void> wireIntoDI(ProjectContext ctx); // Register in get_it/riverpod
  Future<void> generateTests(ProjectContext ctx); // Create test stubs
}
```

### 6.2 Module Categories (25 modules)

**Core Services (8):**
| Module | Package(s) | Description |
|--------|-----------|-------------|
| analytics | firebase_analytics | Event tracking, screen views |
| crashlytics | firebase_crashlytics / sentry_flutter | Crash reporting (swappable) |
| auth | firebase_auth | Auth contract + implementation |
| local_storage | hive_ce | Local key-value storage |
| connectivity | connectivity_plus | Network status monitoring |
| permissions | permission_handler | Centralized permission requests |
| secure_storage | flutter_secure_storage | Encrypted credential storage |
| logging | talker + talker_dio_logger | Structured app + network logging |

**Communication & Engagement (5):**
| Module | Package(s) | Description |
|--------|-----------|-------------|
| notifications | awesome_notifications | Push + local + scheduled |
| deep_link | app_links + uni_links | Universal/App Links handling |
| in_app_review | in_app_review | Smart review prompt |
| share | share_plus | Share content to other apps |
| social_login | google_sign_in, sign_in_with_apple | OAuth providers |

**Monetization (4):**
| Module | Package(s) | Description |
|--------|-----------|-------------|
| ads | google_mobile_ads | Banner, interstitial, rewarded + consent |
| payments | purchases_flutter (RevenueCat) | IAP + subscriptions |
| remote_config | firebase_remote_config | Remote configuration |
| feature_flags | custom | Local + remote feature flag system |

**Media (4):**
| Module | Package(s) | Description |
|--------|-----------|-------------|
| image_picker | image_picker + image_cropper | Pick, crop, compress images |
| camera | camerawesome | Camera + video recording |
| video_player | media_kit | Video playback |
| qr_scanner | mobile_scanner | QR/barcode scanning |

**Location & Maps (2):**
| Module | Package(s) | Description |
|--------|-----------|-------------|
| location | geolocator + geocoding | GPS + address resolution |
| maps | google_maps_flutter | Map display + markers + directions |

**Device & System (4):**
| Module | Package(s) | Description |
|--------|-----------|-------------|
| biometric | local_auth | Fingerprint + Face ID |
| file_manager | open_filex + path_provider | File downloads + management |
| app_update | upgrader | Force/optional update prompts |
| webview | flutter_inappwebview | In-app browser |

### 6.3 Module Installation Flow
```
agentic_base add notifications
  ├── 1. Check .info/agentic.yaml for current state mgmt choice
  ├── 2. Check conflicts with installed modules
  ├── 3. Add dependencies to pubspec.yaml
  ├── 4. Copy template files (adapted for state choice)
  ├── 5. Wire into DI (get_it or riverpod)
  ├── 6. Generate test stubs
  ├── 7. Update .info/agentic.yaml (mark module as installed)
  ├── 8. Run flutter pub get
  └── 9. Run build_runner if needed
```

### 6.4 Community Mason Bricks
Community modules via mason bricks use adapter pattern:
```
agentic_base brick add community_chat
  ├── 1. mason add community_chat (from BrickHub/GitHub)
  ├── 2. mason make community_chat --output-dir lib/features/
  └── 3. User manually wires into DI (adapter guide in README)
```

---

## 7. Theme System (Full M3)

Generated theme includes complete Material 3 implementation:

```dart
// core/theme/app_theme.dart
class AppTheme {
  static ThemeData light({Color? seedColor}) => ThemeData(
    useMaterial3: true,
    colorScheme: AppColorSchemes.light(seedColor),
    textTheme: AppTypography.textTheme,
    appBarTheme: AppComponentThemes.appBar(Brightness.light),
    cardTheme: AppComponentThemes.card,
    elevatedButtonTheme: AppComponentThemes.elevatedButton,
    outlinedButtonTheme: AppComponentThemes.outlinedButton,
    textButtonTheme: AppComponentThemes.textButton,
    inputDecorationTheme: AppComponentThemes.inputDecoration,
    floatingActionButtonTheme: AppComponentThemes.fab,
    bottomNavigationBarTheme: AppComponentThemes.bottomNav,
    chipTheme: AppComponentThemes.chip,
    dialogTheme: AppComponentThemes.dialog,
    snackBarTheme: AppComponentThemes.snackBar,
    extensions: [AppThemeExtension.light],
  );
  
  static ThemeData dark({Color? seedColor}) => ThemeData(
    useMaterial3: true,
    colorScheme: AppColorSchemes.dark(seedColor),
    // ... same component themes with dark variants
  );
}
```

**Files generated:**
- `app_theme.dart` — ThemeData factory (light + dark)
- `color_schemes.dart` — Full ColorScheme (light + dark), seed-based or custom
- `typography.dart` — Complete M3 TextTheme with all 15 styles
- `component_themes.dart` — Every component theme (AppBar, Button, Card, Input, Dialog, SnackBar, Chip, FAB, BottomNav, etc.)
- `spacing.dart` — 4/8/12/16/24/32/48/64 spacing system
- `radius.dart` — Border radius tokens (sm/md/lg/xl)
- `extensions/theme_extensions.dart` — Custom ThemeExtension for app-specific tokens

---

## 8. Eval-Driven Testing Strategy

### 8.1 Spec Files (Human-Written)
```yaml
# features/auth/auth.spec.yaml
feature: auth
description: User authentication flow
acceptance_criteria:
  - user can login with email and password
  - user sees validation error on empty fields
  - user sees error message on wrong credentials
  - session persists across app restart
  - user can logout and return to login screen
edge_cases:
  - network timeout during login attempt
  - account locked after 5 failed attempts
  - expired session token auto-refresh
  - concurrent login from another device
```

### 8.2 Test Generation
AI agent reads spec.yaml and generates:
- **Unit tests** (`auth_cubit_test.dart`) — Cubit state transitions
- **Widget tests** (`auth_screen_test.dart`) — UI rendering + interaction
- **Golden tests** (alchemist) — Visual regression snapshots
- **Integration tests** (`auth_flow_test.dart`) — Full flow with patrol

### 8.3 Eval Command
```bash
agentic_base eval auth          # Run all tests for auth feature
agentic_base eval --all         # Run all tests
agentic_base eval --coverage    # Run + coverage report
```

---

## 9. CI/CD Pipeline

### 9.1 GitHub Actions Workflows

**ci.yml** (on PR):
```
lint (very_good_analysis) → unit tests → widget tests → golden tests → build (all flavors)
```

**cd-dev.yml** (on merge to develop):
```
ci → build dev flavor → deploy to Firebase App Distribution → notify team
```

**cd-staging.yml** (manual trigger):
```
ci → build staging flavor → deploy to TestFlight/Internal Testing → ping human approval
```

**cd-prod.yml** (manual trigger, requires approval):
```
ci → build prod flavor → Fastlane release to stores → ping human
```

### 9.2 Fastlane
- iOS: match (code signing), gym (build), deliver (App Store)
- Android: gradle (build), supply (Play Store)
- Both: per-flavor configuration

---

## 10. Tool Internal Architecture

```
agentic_base/                            # pub.dev package
├── bin/
│   └── agentic_base.dart                # CLI entry point
│
├── lib/
│   ├── src/
│   │   ├── commands/                    # CLI commands (args-based)
│   │   │   ├── create_command.dart      # create <app_name>
│   │   │   ├── add_command.dart         # add <module>
│   │   │   ├── feature_command.dart     # feature <name>
│   │   │   ├── gen_command.dart         # gen (build_runner)
│   │   │   ├── eval_command.dart        # eval [feature]
│   │   │   ├── brick_command.dart       # brick <add|remove|list>
│   │   │   ├── deploy_command.dart      # deploy <env>
│   │   │   ├── upgrade_command.dart     # upgrade
│   │   │   ├── doctor_command.dart      # doctor
│   │   │   └── init_command.dart        # init (existing project)
│   │   │
│   │   ├── generators/                  # Code generation logic
│   │   │   ├── project_generator.dart   # Full project scaffold
│   │   │   ├── feature_generator.dart   # Feature module scaffold
│   │   │   ├── module_generator.dart    # Built-in module installer
│   │   │   └── theme_generator.dart     # M3 theme generation
│   │   │
│   │   ├── modules/                     # Built-in module definitions
│   │   │   ├── module_registry.dart     # Registry of all modules
│   │   │   ├── base_module.dart         # Abstract AgenticModule
│   │   │   ├── core/                    # Core service modules
│   │   │   ├── communication/           # Communication modules
│   │   │   ├── monetization/            # Monetization modules
│   │   │   ├── media/                   # Media modules
│   │   │   ├── location/                # Location modules
│   │   │   └── device/                  # Device modules
│   │   │
│   │   ├── config/                      # Tool configuration
│   │   │   ├── agentic_config.dart      # .info/agentic.yaml parser
│   │   │   └── state_config.dart        # State management config
│   │   │
│   │   └── tui/                         # Terminal UI components
│   │       ├── logger.dart              # mason_logger wrapper
│   │       ├── progress.dart            # Progress indicators
│   │       └── prompts.dart             # User prompts/questions
│   │
│   └── agentic_base.dart               # Public API
│
├── bricks/                              # Mason brick templates
│   ├── agentic_app/                     # Base app template
│   │   ├── __brick__/                   # Template files
│   │   ├── hooks/                       # Pre/post generation hooks
│   │   └── brick.yaml                   # Brick metadata
│   │
│   ├── features/                        # Feature templates (per state mgmt)
│   │   ├── cubit_feature/
│   │   ├── riverpod_feature/
│   │   └── mobx_feature/
│   │
│   └── modules/                         # Module templates (per state mgmt)
│       ├── cubit/                       # Module wiring for get_it
│       ├── riverpod/                    # Module wiring for riverpod
│       └── mobx/                        # Module wiring for get_it
│
├── test/                                # Tool tests
│   ├── commands/
│   ├── generators/
│   └── modules/
│
└── pubspec.yaml
```

---

## 11. Phased Release Strategy

### Phase 1 — Core Scaffold (v0.1.0)
- `create` command with Cubit default
- Generated: app structure, theme, routing, DI, network, error handling, i18n, assets, flavors, analysis
- AGENTS.md + CLAUDE.md generated
- Basic `gen` command (build_runner)
- `doctor` command

### Phase 2 — Feature & Module System (v0.2.0)
- `feature` command (scaffold new features)
- `add` command with core 8 modules (analytics, crashlytics, auth, local_storage, connectivity, permissions, secure_storage, logging)
- `.info/agentic.yaml` config system
- Module auto-wiring into DI

### Phase 3 — Testing & Eval (v0.3.0)
- `eval` command
- Spec.yaml parsing
- Test stub generation
- Coverage reporting
- Golden test setup (alchemist)

### Phase 4 — CI/CD & Deploy (v0.4.0)
- GitHub Actions workflow generation
- Fastlane setup
- `deploy` command
- Makefile generation

### Phase 5 — Extended Modules (v0.5.0)
- Remaining 17 modules (communication, monetization, media, location, device)
- Module conflict resolution
- Module dependency graph

### Phase 6 — Multi-State & Bricks (v0.6.0)
- Riverpod state management option
- MobX state management option
- `brick` command (community mason bricks)
- `init` command (existing projects)
- `upgrade` command

### Phase 7 — Polish & Publish (v1.0.0)
- Comprehensive tool tests
- pub.dev scoring optimization (140+ points)
- Documentation site
- Example projects (per state management)
- CHANGELOG.md
- CI/CD for the tool itself

---

## 12. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Package version conflicts (15+ packages) | Build failures | Pin versions, test matrix in CI |
| build_runner chain fragility | Slow/broken builds | Isolate code-gen steps, cache |
| Mason template complexity | Hard to maintain | Separate bricks per state, test each |
| Module DI wiring edge cases | Runtime crashes | Integration tests per module combination |
| pub.dev score requirements | Can't publish | Run `pana` in CI from Phase 1 |
| Dart TUI limitations | Poor UX | Keep TUI basic, invest in output quality |
| 3 state management variants | 3x templates | Phase: ship Cubit v1, add others incrementally |
| Community brick compatibility | Broken user projects | Adapter pattern + validation script |

---

## 13. Package Version Reference

### Generated Project Core Dependencies
```yaml
dependencies:
  # State Management
  flutter_bloc: ^9.x
  hydrated_bloc: ^10.x
  freezed_annotation: ^3.x
  json_annotation: ^4.x
  fpdart: ^2.x
  
  # DI
  get_it: ^8.x
  injectable: ^2.x
  
  # Routing
  auto_route: ^9.x
  
  # Network
  dio: ^5.x
  retrofit: ^4.x
  
  # i18n
  slang: ^4.x
  slang_flutter: ^4.x
  
  # Theme & UI
  flutter_screenutil: ^5.x
  
  # Assets
  flutter_gen: ^5.x
  
dev_dependencies:
  # Code Gen
  build_runner: ^2.x
  freezed: ^3.x
  json_serializable: ^6.x
  injectable_generator: ^2.x
  auto_route_generator: ^9.x
  retrofit_generator: ^9.x
  slang_build_runner: ^4.x
  flutter_gen_runner: ^5.x
  
  # Testing
  bloc_test: ^9.x
  mocktail: ^1.x
  alchemist: ^0.x
  patrol: ^3.x
  
  # Analysis
  very_good_analysis: ^6.x
  
  # Flavors
  flutter_flavorizr: ^2.x
```

---

## 14. Success Metrics

| Metric | Target |
|--------|--------|
| pub.dev score | 140+ points |
| `agentic_base create` → compilable app | < 60 seconds |
| Generated app `flutter test` | 100% pass on fresh scaffold |
| Generated app `dart analyze` | 0 warnings |
| Module install (`agentic_base add X`) | No manual wiring needed |
| AI agent (Claude Code) can add feature to generated project | Without reading docs, just AGENTS.md |

---

## 15. Resolved Questions

| # | Question | Decision | Rationale |
|---|----------|----------|-----------|
| 1 | Signals state management | **Defer to v2** | Ecosystem young. Cubit+Riverpod+MobX cover 95% devs |
| 2 | Onboarding module | **Custom template** | PageView-based, no extra dependency, full control |
| 3 | Feature flags | **Custom local + optional remote** | Local via SharedPrefs. Remote via firebase_remote_config if module installed |
| 4 | Patrol vs integration_test | **Both** | Vanilla for UI flows. Patrol for native (permissions, notifications) — generated when needed |
| 5 | Web/desktop responsive | **Mobile-only default** | flutter_screenutil for mobile. `agentic_base add responsive_web` for web/desktop later |
| 6 | Mason brick strategy | **Hybrid: bundle core + fetch community** | Core bricks bundled offline. Community bricks fetched from BrickHub/GitHub |
| 7 | Tool versioning | **Lockfile (.info/agentic.yaml)** | Records tool version, state choice, modules. Tool checks compat before modify |

---

## 16. Detailed Architecture Decisions

### 16.1 Bootstrap Flow
Order: Env → Logger → DI → Storage → HydratedBloc → BlocObserver → App
```dart
// main_dev.dart
void main() => bootstrap(flavor: Flavor.dev, builder: () => const App());

// bootstrap.dart
Future<void> bootstrap({required Flavor flavor, required Widget Function() builder}) async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await EnvConfig.load(flavor);           // 1. env
    await LogService.init();                 // 2. logging (talker)
    await configureDependencies(flavor);     // 3. DI (get_it)
    await StorageService.init();             // 4. local storage
    HydratedBloc.storage = await HydratedStorage.build(); // 5. hydrated
    Bloc.observer = AppBlocObserver();       // 6. observer
    runApp(builder());                       // 7. app
  }, (error, stack) => LogService.fatal(error, stack));
}
```

### 16.2 Error Hierarchy
Layered Failure types via freezed sealed class:
- Network: NetworkFailure, ServerFailure, TimeoutFailure, NoConnectionFailure
- Cache: CacheFailure
- Auth: UnauthorizedFailure, ForbiddenFailure
- Generic: UnexpectedFailure
- Features extend with own types (e.g., PaymentDeclinedFailure)

### 16.3 DI Registration Pattern (Injectable 3 Levels)
1. **Auto-register**: `@injectable` / `@LazySingleton(as: Interface)` on your classes → build_runner auto-generates registrations
2. **Module files**: `@module` abstract class for external packages (Dio, etc.) you can't annotate
3. **Per-environment**: `@dev` / `@prod` / `@staging` annotations → different impls per flavor

### 16.4 Network Interceptors
Order: Auth → Error → Logging. **All toggleable via env config, default ON.**
- AuthInterceptor: add Bearer token, auto-refresh expired token, retry, 401 → force logout
- ErrorInterceptor: map DioException → Failure types (4xx, 5xx, timeout, no connection)
- LoggingInterceptor: talker_dio_logger, detailed in dev, minimal in prod

### 16.5 Router Guards
AutoRoute guard pattern: AuthGuard checks token, redirects to LoginRoute if unauthorized.
Protected routes declare `guards: [AuthGuard]` in router config.

### 16.6 Code-Gen Pipeline (Split)
**Daily gen (`tools/gen.sh`):**
- `dart run build_runner build --delete-conflicting-outputs` (freezed + json + injectable + auto_route + retrofit + slang + flutter_gen + hive_ce + conditional riverpod/mobx)
- `dart format lib test`

**One-time gen (`tools/setup.sh`):**
- `dart run flutter_launcher_icons` (when icon config changes)
- `dart run flutter_native_splash:create` (when splash config changes)
- `dart run flutter_flavorizr` (when flavor config changes)

### 16.7 build.yaml
Full config with 7+ generators: freezed, json_serializable (explicit_to_json, snake_case), injectable_generator, auto_route_generator, retrofit_generator, slang_build_runner, flutter_gen_runner. Conditional: hive_ce_generator, riverpod_generator, mobx_codegen.

### 16.8 tools/ Scripts Architecture
Comprehensive set: gen.sh, test.sh, build.sh, clean.sh, setup.sh, format.sh, lint.sh, release.sh, ci-check.sh.
All source `tools/_common.sh` for shared functions (log_info, log_ok, log_warn, log_error, log_step, check_command). Consistent logging, colored output.
Makefile delegates to these scripts.

### 16.9 .info/agentic.yaml Schema
```yaml
tool_version: 0.3.0
project_name: my_app
org: com.example
state_management: cubit  # cubit|riverpod|mobx
platforms: [ios, android]
flavors: [dev, staging, prod]
modules: [analytics, crashlytics, auth, notifications]
flutter_version: 3.29.0
dart_version: 3.7.0
created_at: 2026-04-09T10:00:00Z
updated_at: 2026-04-09T14:30:00Z
```

### 16.10 Module Conflict Resolution
Warn + block. Tool checks `conflictsWith` list before install. User must `remove` conflicting module first.

### 16.11 AGENTS.md Content (Extended)
5 standard sections (Stack, Commands, Architecture, Structure, Boundaries) + real code examples + pre-commit hooks + testing patterns.

### 16.12 CLAUDE.md Content
Claude-specific: project context, Claude Code hooks (pre-commit lint+gen, post-file-edit analyze), conventions (feature workflow, gen workflow, state/error patterns), boundaries (no edit .g.dart, no commit env/).

### 16.13 Init Command (Existing Projects)
Non-destructive: scan project → detect existing packages → add missing pieces (core/, AGENTS.md, tools/, .info/) → list manual steps for migration.

### 16.14 Doctor Command
Comprehensive: Flutter SDK, Dart SDK, FVM, build_runner, pubspec deps, generated files freshness, agentic.yaml validity, env/ files, AGENTS.md, tools/ executability. Reports health score.

### 16.15 Deploy Command
Uses `gh workflow run` to trigger GitHub Actions. `deploy dev` auto-triggers. `deploy staging/prod` requires manual approval in GitHub.

### 16.16 Default Home Feature
Full example with 3 layers (data/domain/presentation), cubit, freezed sealed state, spec.yaml, module.dart, repository contract + impl, use case, page + widgets. Serves as reference implementation.

### 16.17 Env Files Location
`env/` folder: dev.env, staging.env, prod.env (gitignored) + .example templates (committed).
Standard env vars: API_BASE_URL, APP_NAME, BUNDLE_ID, LOG_LEVEL, ENABLE_MOCK, ANALYTICS_ENABLED.

### 16.18 Docs Architecture
6 numbered files in docs/: 01-architecture, 02-code-standards, 03-features, 04-deployment, 05-api-contracts, 06-testing-guide. Generated via /ck:docs --init integration.

---

## Research References
- [Flutter CLI Landscape Report](researcher-260409-1103-flutter-cli-landscape.md)
- [Agentic Coding Patterns Report](researcher-260409-1103-agentic-coding-patterns.md)
