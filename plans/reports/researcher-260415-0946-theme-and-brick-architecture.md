# Research Report: Theme System and Brick Architecture
Date: 2026-04-15

## Bottom Line
The current bricks are decent scaffolds for a starter app, but they are not ready for a hard-mode default as-is. The biggest risks are: overusing `library`/`part` beyond generated leaf files, a theme guide/code mismatch, tuple-based contracts instead of a real result model, and a starter flow that proves shell boot but not actual UX contracts.

## 1) `library` + `part`: where it helps, where it hurts

### Recommended boundary
- Use `part` only where Dart codegen requires it:
  - `freezed` state files
  - `json_serializable` model files
  - other generated leaf fragments
- Keep handwritten feature/core code as normal mini-libraries with explicit imports.

### Why
- Helps:
  - keeps generated boilerplate attached to one model/state file
  - fine for tightly coupled, single-purpose leaf types
- Hurts:
  - hidden coupling across feature/core layers
  - harder imports/tests/debugging
  - brittle if a large feature is split later
  - mixed handwritten + generated `part` trees make codegen and ownership unclear

### Brick-specific read
- Current app brick has only generated `part` use for Freezed/JSON in home models/states.
- No `library` directives exist.
- That is good. Do not expand this pattern into app/core or feature layers.

### Plan implication
- Keep `part` as a codegen-only tool.
- If a feature needs privacy boundaries, prefer small files and explicit imports, not a monolithic `library` file with many parts.

## 2) Theme-system quality and M3 gaps

### What is good
- `useMaterial3: true` is already set.
- `ColorScheme.fromSeed(...)` is the right starting point.
- Theme tokens are centralized under `lib/core/theme/`.

### Gaps
- Theme assembly uses `ThemeData(...)` directly, not `ThemeData.from(...)`.
- Typography is fully hand-authored around Roboto instead of using a Material 3 baseline and overriding only what is needed.
- `MaterialApp.router` does not expose a deliberate theme-mode or high-contrast contract.
- The theming docs are stale:
  - docs mention `AppTheme.lightTheme` / `darkTheme`, but code uses `AppTheme.light` / `dark`
  - docs mention `AppThemeExtension` / `context.appTheme`, but code defines `AppColors`
  - docs mention `AppRadius.full`, but code does not have it
  - docs mention `google_fonts`, but pubspec does not include it
- `AppScreenUtilInit` exists but is not wired into `App`, so responsive-sizing guidance is currently misleading.

### M3 direction that fits this brick
1. Keep seed-based color generation.
2. Move to `ThemeData.from(colorScheme: ..., textTheme: ...)` plus targeted `copyWith` overrides.
3. Reduce hand-rolled typography to a minimal override set; keep the default Material 3 baseline for the rest.
4. Keep `ThemeExtension` only for truly non-M3 semantic tokens like success/warning/info.
5. Fix docs to match actual code before adding more theme surface.

### Plan implication
- This brick should ship a clean M3 baseline, not a custom theme system masquerading as M3.
- Do not add theme toggles or user-preference plumbing until there is a real settings surface.

## 3) Missing base contracts

### Response/result
- Current code returns tuples like `(List<HomeItem>, Failure?)`.
- The network docs claim `Either<AppFailure, T>`, so docs and code already disagree.
- There is no shared typed result contract in the brick for success/failure at app or feature boundary.

### Pagination
- No page/request/result model exists.
- No cursor/page metadata, no `loadMore`, no page params.
- Every list API is currently “load all” only.

### Multilanguage
- App brick has Slang/i18n wiring and `app` + `home` namespaces.
- Feature brick still hardcodes copy in the page layer, including retry text and titles.
- Feature translation files are generated, but the brick does not teach or enforce their use.

### Error contract
- `Failure` is minimal: message + optional statusCode.
- `ErrorHandler` only covers a few Dio cases.
- No typed validation/unauthorized/not-found contract exists even though the docs imply a richer model.

### Plan implication
- Pick one shared boundary type and use it everywhere:
  - `Result`/`Either`-style contract for success/failure
  - `PageRequest`/`PageResult` only where paging exists
  - feature-local localization bindings for every generated feature, not just app/home

## 4) Starter-flow deficiencies

### What the starter currently proves
- bootstrap runs
- flavor config exists
- router lands on home
- generated translations exist
- evidence/verify plumbing exists

### What it does not prove
- real theme behavior
- localization rendering
- route depth beyond home
- actual data contract usage
- responsive wrapper wiring

### Honest starter-flow recommendation
1. Keep the home screen as a runtime diagnostics + checklist page.
2. Do not add fake onboarding/auth/settings flows just to look complete.
3. Replace demo async repository delays with clearly labeled demo-only paths or explicit TODO stubs.
4. Make the starter feature brick actually consume its generated translations.
5. Add widget/tests that verify locale + theme + shell rendering, not only `MaterialApp`/`Scaffold`.

## Ranked recommendation
1. **Best default:** keep `part` only for codegen leaf files; use normal mini-libraries everywhere else.
2. **Theme refresh:** move to `ThemeData.from` + seed-based `ColorScheme`, trim manual typography, fix docs/code drift.
3. **Contracts:** introduce one typed result boundary, then add pagination only where needed.
4. **Starter flow:** keep it minimal, honest, and test-backed; no extra fake screens.

## Affected files
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/app_theme.dart`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/color_schemes.dart`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/component_themes.dart`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/typography.dart`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/05-theming-guide.md`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/04-network-layer.md`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/**`
- `/Users/biendh/base/bricks/agentic_feature/__brick__/**`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/test/app_smoke_test.dart`
- `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`

## Sources
- Dart libraries and imports: https://dart.dev/language/libraries
- Dart package/library guidance: https://dart.dev/tools/pub/create-packages
- Flutter `ThemeData.from`: https://api.flutter.dev/flutter/material/ThemeData/ThemeData.from.html
- Flutter `ColorScheme.fromSeed`: https://api.flutter.dev/flutter/material/ColorScheme/ColorScheme.fromSeed.html
- Flutter `ThemeExtension`: https://api.flutter.dev/flutter/material/ThemeExtension-class.html
- Flutter `TextTheme`: https://api.flutter.dev/flutter/material/TextTheme/TextTheme.html
- Flutter `MaterialApp.router`: https://api.flutter.dev/flutter/material/MaterialApp/MaterialApp.router.html

## Resolution Note

The previously open planning questions are now closed:

- hard-mode defaults will standardize on `fpdart` at data/domain boundaries
- ScreenUtil-style global scaling is not the default foundation; the scaffold moves toward an internal adaptive-native layer
- feature outputs stay in scope and must become honestly wired rather than remain demo-only dead scaffolding
