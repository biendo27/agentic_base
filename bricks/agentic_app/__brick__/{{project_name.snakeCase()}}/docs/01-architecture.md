# Architecture Overview

## Canonical Context

- Machine source of truth: `.info/agentic.yaml`
- Harness Contract: `v1`
- Primary profile: `{{app_profile}}` ({{app_profile_label}})
- Support tier: `{{support_tier_label}}`
- Evidence directory: `{{{evidence_dir}}}`
- Human-readable context: `README.md` plus `docs/01-06`
- Thin adapters: `AGENTS.md`, `CLAUDE.md`
- If adapters drift, follow `README.md` and `docs/`

## Pattern

Dependencies flow inward:

```text
presentation -> domain <- data
```

## App Bootstrap

1. `FlavorConfig.init(flavor)` resolves shared build-time env keys against per-flavor defaults
2. `bootstrap(() => App())` initializes bindings, locale through `AppLocaleContract`, DI, and observers
3. `App` mounts `AppThemeScope`, `TranslationProvider`, and `MaterialApp.router`
4. `AppRouter` lands on the starter home route

## Starter Day-0 Flow

- `HomePage` is the starter dashboard and runtime diagnostics surface
- `StarterDetailPage` proves the ownership/localization/flavor checkpoints
- `StarterSettingsPage` is the default route for theme-mode and locale preview
- `StarterMonetizationPage` stays provider-neutral through `StarterMonetizationRepository`

## Ownership Boundary

- Brick-owned Flutter layer:
  - `lib/app/**`
  - `lib/main*.dart`
  - `assets/i18n/**`
  - `.vscode/**`
  - `.idea/runConfigurations/**`
- Tool-owned outputs:
  - native platform folders from `flutter create`
  - native flavor artifacts from `flutter_flavorizr`
  - generated router/DI/i18n code
- Forbidden leftovers:
  - `lib/app.dart`
  - `lib/flavors.dart`
  - `lib/pages/**`
  - `.idea/workspace.xml`
  - `.idea/modules.xml`
  - `.idea/libraries/**`

## Deterministic Entrypoints

- setup: `./tools/setup.sh`
- default run: `./tools/run-dev.sh`
- verify: `./tools/verify.sh`
- build: `./tools/build.sh <flavor> [artifact]`
- release preflight: `./tools/release-preflight.sh <flavor> <target>`
- release upload: `./tools/release.sh <flavor> <target>`

Meaningful verify and release-preflight runs emit named gate outputs under `{{{evidence_dir}}}`.

## Human Checkpoints

- humans own secrets, signing, and store credentials
- agents can prepare builds and uploads
- final production store publish remains human-approved

## Localization Contract

- Source translations live in `assets/i18n/<module>/<module>_<locale>.i18n.yaml`
- `build_runner` + Slang generate typed APIs into `lib/app/i18n/translations.g.dart`
- `lib/app/locale/app_locale_contract.dart` stays outside generated Slang output so runtime code keeps one stable wrapper even if generated tree layout changes
- Starter namespaces:
  - `app`
  - `home`

## Theme Contract

- `ThemeMode` remains the runtime preference surface
- `AppThemeController` also tracks a theme family id, but v1 ships one bundled family only: `material-default`
- `lib/core/theme/app_theme_family.dart` is the extension point for future branded families without rewriting `App`

## Shared Contracts

- `AppFailure`, `AppResponse`, and pagination models use `freezed` for value semantics and exhaustive handling
- `part` files stay scoped to those modeled leaf contracts instead of widening codegen across the app shell
