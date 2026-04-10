# Architecture Overview

## Pattern

Dependencies flow inward:

```text
presentation -> domain <- data
```

## App Bootstrap

1. `FlavorConfig.init(flavor)` resolves env-driven runtime values
2. `bootstrap(() => App())` initializes bindings, locale, DI, and observers
3. `App` mounts `TranslationProvider` and `MaterialApp.router`
4. `AppRouter` lands on the starter home route

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

## Localization Contract

- Source translations live in `assets/i18n/<module>/<module>_<locale>.i18n.yaml`
- `build_runner` + Slang generate typed APIs into `lib/app/i18n/translations.g.dart`
- Starter namespaces:
  - `app`
  - `home`
