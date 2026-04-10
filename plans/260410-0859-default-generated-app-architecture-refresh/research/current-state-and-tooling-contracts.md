# Current State And Tooling Contracts

## Summary

- Repo docs confirm intended generated layout is `lib/app`, `lib/core`, `lib/features`, `lib/shared`, but current sample app still has duplicate root shell files.
- `my_app` currently passes `flutter analyze` and `flutter test`; this is useful because the refresh is architectural cleanup, not rescue from a broken baseline.
- Current l10n is one YAML file in `l10n/` with no Slang wiring and no generated `lib/app/i18n`.
- Current `build.yaml` only configures `json_serializable`.
- Current generator overlays the brick, then runs `flutter_flavorizr`, which explains why tool-generated Flutter-layer files can reappear.
- Current `flavorizr.yaml` already has per-flavor app names; the real bugs are sparse config and invalid rendered app ids.
- `.vscode` is absent. `.idea` contains local-only files plus one run config, so ownership is currently undefined.

## Approved Architecture Decisions

- Use the balanced rewrite direction.
- Use Slang with `build_runner` via `build.yaml` only. No `slang.yaml`.
- Keep translation sources centralized under `assets/i18n` and split by module.
- Generate localization code under `lib/app/i18n`.
- Do not colocate translations deep inside features.
- Limit `flutter_flavorizr` to native flavor artifacts only.
- Let the brick own Flutter-layer files including `lib/app/*`, `lib/main*.dart`, `.vscode`, and shared `.idea` run configs.
- Ship a real starter app, not a skeleton.

## Tooling Notes

- Slang docs support builder-based generation through `build.yaml`, which matches the approved no-`slang.yaml` rule.
- Slang output/input paths are configurable enough to support `assets/i18n` sources and `lib/app/i18n` generated output.
- `flutter_flavorizr` docs expose instruction-based control, which is the mechanism needed to stop it from generating Flutter-layer Dart/UI files.

## Sources

- Repo files:
  - `README.md`
  - `docs/02-codebase-summary.md`
  - `docs/03-code-standards.md`
  - `docs/04-system-architecture.md`
  - `docs/07-design-guidelines.md`
  - `lib/src/generators/project_generator.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/**`
  - `my_app/**`
- Official package docs:
  - https://pub.dev/documentation/slang/latest/
  - https://pub.dev/documentation/flutter_flavorizr/latest/

## Unresolved Questions

- None. User-approved decisions are sufficient for implementation planning.
