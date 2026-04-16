# Research Summary

## Summary

The repo is close to the intended harness-first direction, but the generated Flutter base still has four real weaknesses: runtime/toolchain honesty is incomplete, shared app contracts are too thin, the theme/starter UX is still scaffold-grade, and verification is too smoke-heavy for the seams the generator claims to own.

## Local Code Findings

### 1. Toolchain honesty is still partial

- The manifest records `system` / `fvm` / `puro`, but several lifecycle commands still execute hard-coded `flutter` or `dart`.
- `create` and `init` can stamp a valid-looking harness contract before the selected manager is proven executable.
- `doctor` and `upgrade` detect drift later, which is too late for an "honest generated contract".
- Product decision update: the manager is now a preference, not a strict hard contract. The runtime should resolve the best available Flutter SDK, then persist both the preferred and resolved values for traceability.

Primary hotspots:

- `lib/src/cli/commands/create_command.dart`
- `lib/src/cli/commands/init_command.dart`
- `lib/src/cli/commands/add_command.dart`
- `lib/src/cli/commands/remove_command.dart`
- `lib/src/cli/commands/gen_command.dart`
- `lib/src/cli/commands/upgrade_command.dart`
- `lib/src/generators/project_generator.dart`
- `lib/src/config/flutter_sdk_contract.dart`

### 2. Generated app/base contracts are shallow

- The generated repository still leans on tuple-style result contracts such as `Future<(List<T>, Failure?)>`.
- `Failure` is sealed but not modeled as a richer generated contract, and core/config surfaces still do not consistently use a typed sealed/freezed approach.
- Base response, paginated response, and reusable locale/language contracts are missing.

Primary hotspots:

- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/error`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/network`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/flavors.dart`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/data`
- `bricks/agentic_feature/__brick__/.../domain/usecases`

### 3. Starter app and feature brick are underpowered

- The starter app is still basically one home screen with diagnostics cards.
- The router owns one route only.
- The home module is comment-only.
- `agentic_feature` scaffolds spec files and structure, but the feature flow is not fully wired into route registration and generated tests.

Primary hotspots:

- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/router/app_router.dart`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home`
- `lib/src/cli/commands/feature_command.dart`
- `lib/src/generators/feature_generator.dart`
- `lib/src/config/spec_parser.dart`
- `lib/src/generators/test_generator.dart`

### 4. Verification is broad but still shallow where it matters

- The generated app brick only ships app-shell smoke coverage and helpers.
- Service seams and default-module behavior are not unit-tested in the generated app.
- The repo integration suite is slow because it repeatedly runs the full generator pipeline and downstream verify flow.

Primary hotspots:

- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/test`
- `test/integration/generated_app_smoke_test.dart`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh`

## External Research

### Material 3 and theme direction

- Current theme implementation is still mostly `ColorScheme.fromSeed(...)` plus manual component overrides.
- That is acceptable as a baseline, but it is weak for a generator that claims a reusable, high-quality app shell.
- The refresh should move toward `ThemeData.from(colorScheme: ..., textTheme: ...)` plus targeted overrides, explicit semantic token ownership, and tighter doc/code parity.
- `AppScreenUtilInit` currently exists as scaffolding but is not wired into `App`; it should either be integrated intentionally or removed from the default base.
- Product decision update: the base scaffold should follow Flutter's adaptive-native approach first. Helper libraries can be evaluated, but ScreenUtil-style global scaling should not become the default foundation.

### `library` + `part`

- Effective Dart explicitly notes that many developers avoid `part` entirely because a single-file library model is easier to reason about.
- Recommendation: do not use `library` + `part` as a blanket cleanup pattern for feature folders.
- Safe use cases:
  - Freezed / JSON codegen companions, where `part` is already standard
- Unsafe default use cases:
  - repositories, use cases, pages, services, or whole Clean Architecture layers
  - anything where independent imports, test seams, and discoverability matter more than compactness
- Plan implication: keep `part` as a codegen-only tool unless implementation produces a very narrow, explicitly justified exception.

### Figma MCP

- The user-provided Figma URL is valid as planning input, but MCP retrieval did not yield variable-token payload directly.
- `get_design_context` requested an active selection; `get_metadata` and `get_screenshot` returned the Material 3 design-kit introduction page instead of a variable-set export.
- Plan implication: the theme refresh phase must explicitly start by resolving the exact selectable token node or fall back to official Material guidance plus the Figma screenshot/reference page, without pretending token extraction already succeeded.

## Recommendations

1. Fix runtime honesty first.
2. Replace tuple-style generated contracts with reusable `fpdart`-based boundary contracts before changing starter features broadly.
3. Use `library` + `part` selectively, not architecturally.
4. Refresh the theme foundation before redesigning the starter flow.
5. Treat test-speed work as a final architecture pass, not a first response.
6. End with docs sync only after generated surfaces and tests are stable.

## Resolution Note

No unresolved planning questions remain. Figma token extraction is still an implementation-time validation step, but the fallback policy is now defined and no longer blocks planning.
