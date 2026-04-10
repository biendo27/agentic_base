# Research Report: Slang `assets/i18n` + native-only `flutter_flavorizr`

**Timestamp:** 2026-04-10 08:56 Asia/Ho_Chi_Minh

## Executive Summary

The current generated-app contract is split and stale: the brick has already moved to `lib/app/` for runtime code, but the sample app still carries legacy root-level `lib/app.dart`, `lib/flavors.dart`, and `lib/pages/*` paths. Localization is even more fragmented: the repo and brick still store source translations under `l10n/`, while the runtime app hardcodes titles and flavor names.

The cleanest fix is to make Slang the single Dart-side localization contract, sourced from `assets/i18n/` and generated into `lib/app/i18n/`, while reducing `flutter_flavorizr` to native platform artifacts only. That keeps the generator stack simple: `flutter create` -> brick overlay -> `flutter pub get` -> `flutter_flavorizr` for native files -> `build_runner` for Slang + existing codegen -> analyze/test.

Recommended rank:
1. Move i18n source to `assets/i18n/` and generate `lib/app/i18n/strings.g.dart`; restrict flavorizr to native-only processors. Best fit.
2. Keep flavorizr as-is and layer Slang on top. Fastest, but leaves duplicate app-name ownership and more drift.
3. Remove flavorizr entirely and hand-maintain native flavors. Highest maintenance cost, not needed.

## Scope

- `README.md`
- `docs/03-code-standards.md`
- `docs/04-system-architecture.md`
- `lib/src/generators/project_generator.dart`
- `bricks/agentic_app/brick.yaml`
- `bricks/agentic_app/__brick__/...`
- `my_app/`

## Research Methodology

Sources consulted:
- Local codebase and generated sample app
- Slang official GitHub docs
- Slang pub.dev package docs
- Flutter Flavorizr pub.dev package docs
- Flutter Flavorizr GitHub README

Key claim coverage:
- Slang can read i18n files from `assets/i18n` and generate Dart to a configurable output directory.
- `build_runner` integration requires `build.yaml`.
- Flutter Flavorizr exposes Flutter processors like `flutter:app`, `flutter:pages`, `flutter:main`; those must be excluded if the tool is to stay native-only.

## Current State

### Generator

`ProjectGenerator.generate()` already does the right high-level order:

1. `flutter create`
2. Mason brick overlay
3. write `.info/agentic.yaml`
4. `flutter pub get`
5. `dart run flutter_flavorizr`
6. install modules
7. `dart run build_runner build --delete-conflicting-outputs`
8. `dart fix --apply`
9. analyze + test

That flow does **not** need a new orchestration layer for Slang if the brick contains the Slang config. The important part is that build_runner already exists in the create pipeline.

### Brick vs sample app mismatch

The brick is newer than the sample app:

- Brick runtime code lives under `lib/app/`
- Sample app still has legacy root-level `lib/app.dart` and `lib/pages/my_home_page.dart`
- Brick already has `l10n/strings_en.i18n.yaml`
- Sample app also has `l10n/strings_en.i18n.yaml`, but no `lib/app/i18n` contract

This is a red flag: the sample app is no longer a faithful reference for the brick.

### String ownership mismatch

Current app-name string ownership is duplicated:

- `lib/app/app.dart` hardcodes title
- `lib/features/home/presentation/pages/home_page.dart` hardcodes title
- `lib/app/flavors.dart` carries `appName`
- `lib/core/constants/app_constants.dart` carries `appName`
- `flavorizr.yaml` also carries native app names

The UI should not depend on flavor config for visible strings once Slang is added.

## Target Contract

### Source

- Move the current Slang input from `l10n/strings_en.i18n.yaml` to `assets/i18n/strings_en.i18n.yaml`
- Keep the current key shape:
  - `app_name`
  - `home.title`
  - `home.error`
  - `home.retry`
  - `home.empty`

### Generated Dart

- Generate into `lib/app/i18n/`
- Preferred output file: `strings.g.dart`
- Runtime access pattern: `t.appName`, `t.home.title`, `t.home.retry`, etc.

### App wiring

- `MaterialApp.router` should use the Slang locale bridge:
  - `TranslationProvider`
  - `TranslationProvider.of(context).flutterLocale`
  - `AppLocaleUtils.supportedLocales`
  - Flutter localizations delegates

Inference: because Slang reads the source files at build time through `build_runner`, the YAML files do not need to be declared as runtime Flutter assets unless you intentionally want to ship the raw source files.

### Flavor boundary

`flutter_flavorizr` should be restricted to native outputs only:

- Android flavor gradle wiring
- Android manifest / application ID / launcher label
- iOS xcconfig / bundle IDs / schemes / launch screens / icons
- macOS equivalents if the template keeps them

Do **not** let flavorizr generate:

- `lib/app.dart`
- `lib/pages/*`
- `lib/main.dart`
- other Flutter-side runtime app strings

The Flutter-side app title and page copy should come from Slang instead.

## File / Flow Impact

### Generator

`lib/src/generators/project_generator.dart`

- Keep the existing `build_runner` step
- Keep the `flutter_flavorizr` step, but only if the template config is narrowed to native processors
- Update comments/docs around the create flow so build_runner is described as covering Slang as well as existing builders
- Optional hardening: create an integration assertion that generated `lib/app/i18n/strings.g.dart` exists after `gen`

### Brick

`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/pubspec.yaml`

- Add `slang`
- Add `slang_flutter`
- Add `slang_build_runner` to dev_dependencies
- Keep `flutter_localizations`
- Keep `intl` only if runtime formatting still uses it

`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/build.yaml`

- Add a `slang_build_runner` builder config
- Point `input_directory` at `assets/i18n`
- Point `output_directory` at `lib/app/i18n`

`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/l10n/strings_en.i18n.yaml`

- Move to `assets/i18n/strings_en.i18n.yaml`

`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/app.dart`

- Read translations from Slang
- Set locale / supportedLocales / delegates correctly
- Replace hardcoded title string with `t.appName`

`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/presentation/pages/home_page.dart`

- Replace hardcoded app bar title with `t.home.title`
- Replace `Retry` with `t.home.retry`
- Use the error/empty keys instead of literal strings

`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/flavors.dart`

- Remove `appName` from Dart flavor config unless there is a non-UI runtime need
- Keep only runtime values that Dart truly needs, such as API base URL

`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/flavorizr.yaml`

- Add an explicit instruction list that excludes Flutter processors like `flutter:app`, `flutter:pages`, and `flutter:main`
- Keep only native processors

`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`
`AGENTS.md`
`CLAUDE.md`
`docs/*.md`

- Replace `l10n/` references with `assets/i18n/`
- Document the generated `lib/app/i18n/` contract
- Update setup/gen instructions to mention Slang in the build_runner pipeline

### Sample app

`my_app/`

- Mirror the brick changes exactly
- Treat the legacy root-level `lib/app.dart`, `lib/flavors.dart`, and `lib/pages/my_home_page.dart` as obsolete
- Update `README.md`, `AGENTS.md`, `CLAUDE.md`, and `docs/*` so the sample app matches the canonical brick

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| build_runner config drift | Slang files do not generate, or generate in the wrong place | Keep `slang_build_runner` in `build.yaml`; use the existing `make gen` / `tools/gen.sh` path |
| flavorizr keeps Flutter processors | Recreates legacy root Dart files and reintroduces duplicate string ownership | Add explicit native-only instructions and remove Flutter processors |
| docs drift | Repo/docs keep promising `l10n/` or legacy root app files | Update root README, brick README, sample app docs, and agent instructions together |
| locale sync confusion | iOS locale metadata lags behind the Dart translations | Use Slang's `configure` flow for locale metadata if/when multiple locales are added, not flavorizr |
| sample app stale reference | Brick and sample app disagree about the canonical app structure | Align `my_app/` to the brick or clearly mark legacy files as transitional only |

## Trade-off Matrix

| Option | Performance | Complexity | Maintenance | Fit |
|---|---|---|---|---|
| A. Keep current mixed ownership | Good now, poor over time | Low short-term | High long-term drift | Poor |
| B. Slang in `assets/i18n`, generated `lib/app/i18n`, native-only flavorizr | Good | Moderate | Lowest ongoing | Best |
| C. Remove flavorizr and hand-roll native flavors | Good | High upfront | Medium/high | Not needed |

Ranked recommendation: **B**.

## Phased Plan

### Phase 1: Contract freeze

Goal: lock the exact source and output paths.

Acceptance criteria:
- `assets/i18n/strings_en.i18n.yaml` is the agreed source path
- `lib/app/i18n/strings.g.dart` is the agreed generated path
- Flavorizr instruction scope is documented as native-only

### Phase 2: Brick rewrite

Goal: make the brick the source of truth.

Acceptance criteria:
- Brick pubspec has Slang packages
- Brick build.yaml has `slang_build_runner`
- Brick runtime app reads translations from Slang
- Brick home page strings are translated
- Brick flavorizr config excludes Flutter processors

### Phase 3: Sample app alignment

Goal: make `my_app` match the brick and stop carrying legacy scaffolding.

Acceptance criteria:
- `my_app` uses the same i18n path and generated contract
- Root-level legacy app files are removed or explicitly deprecated
- `my_app` README / AGENTS / CLAUDE / docs no longer mention `l10n/`

### Phase 4: Verification and docs

Goal: make the contract hard to regress.

Acceptance criteria:
- `dart run build_runner build --delete-conflicting-outputs` succeeds
- `dart analyze` succeeds
- `flutter test` succeeds
- At least one test accesses the translation contract directly
- Docs describe the new source/output split and the flavor boundary

## Recommended Next Step

Write the brick changes first, then mirror them into `my_app`, then update docs last. The generator code itself should only need light verification or wording updates unless the brick scope or flavorizr invocation changes.

## References

Local:
- [/Users/biendh/base/README.md](/Users/biendh/base/README.md)
- [/Users/biendh/base/docs/03-code-standards.md](/Users/biendh/base/docs/03-code-standards.md)
- [/Users/biendh/base/docs/04-system-architecture.md](/Users/biendh/base/docs/04-system-architecture.md)
- [/Users/biendh/base/lib/src/generators/project_generator.dart](/Users/biendh/base/lib/src/generators/project_generator.dart)
- [/Users/biendh/base/bricks/agentic_app/brick.yaml](/Users/biendh/base/bricks/agentic_app/brick.yaml)
- [/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/pubspec.yaml](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/pubspec.yaml)
- [/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/build.yaml](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/build.yaml)
- [/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/flavorizr.yaml](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/flavorizr.yaml)
- [/Users/biendh/base/my_app/pubspec.yaml](/Users/biendh/base/my_app/pubspec.yaml)
- [/Users/biendh/base/my_app/build.yaml](/Users/biendh/base/my_app/build.yaml)
- [/Users/biendh/base/my_app/README.md](/Users/biendh/base/my_app/README.md)
- [/Users/biendh/base/my_app/lib/app/app.dart](/Users/biendh/base/my_app/lib/app/app.dart)
- [/Users/biendh/base/my_app/lib/features/home/presentation/pages/home_page.dart](/Users/biendh/base/my_app/lib/features/home/presentation/pages/home_page.dart)
- [/Users/biendh/base/my_app/lib/app/flavors.dart](/Users/biendh/base/my_app/lib/app/flavors.dart)
- [/Users/biendh/base/my_app/lib/core/constants/app_constants.dart](/Users/biendh/base/my_app/lib/core/constants/app_constants.dart)
- [/Users/biendh/base/my_app/l10n/strings_en.i18n.yaml](/Users/biendh/base/my_app/l10n/strings_en.i18n.yaml)

Official docs:
- https://github.com/slang-i18n/slang
- https://pub.dev/packages/slang
- https://pub.dev/packages/slang_build_runner
- https://pub.dev/packages/flutter_flavorizr
- https://github.com/AngeloAvv/flutter_flavorizr

## Unresolved Questions

- Should the legacy root-level `lib/app.dart` / `lib/pages/my_home_page.dart` in `my_app` be deleted outright, or kept temporarily as compatibility shims?
- Do we want to run `dart run slang configure` as part of setup/CI for locale metadata sync, or keep that as a manual one-off step when locales change?
- Should `AppConstants.appName` survive as a launcher-label constant, or be removed once UI strings are fully Slang-owned?
