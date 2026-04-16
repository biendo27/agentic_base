# Generated App Architecture Review

## Theme

- Current theme foundation is stronger than before, but still one-family only.
- `AppThemeController` only owns `ThemeMode`.
- `AppTheme` only exposes `light` and `dark`.
- `color_schemes.dart` and `typography.dart` are static singleton sources.
- `component_themes.dart` is becoming a catch-all file again.

## Locale

- `AppLocaleContract` is intentionally outside `lib/app/i18n/**`.
- This is structurally correct because generated i18n output is deleted/regenerated.
- The contract needs stronger documentation and tests so future refactors do not “simplify” it into the generated tree.

## Flavor

- `FlavorConfig` is correct enough, but verbose.
- The same env keys are resolved per flavor with repeated declarations.
- It can be represented as smaller data plus flavor defaults more cleanly.

## Contracts And Errors

- `AppFailure` is already a sealed family, but not `freezed`.
- `AppResponse` and pagination types are plain immutable containers.
- Migrating everything to `freezed` would increase codegen and noise without guaranteed payoff.

## Modularization

- The real modularization issue is large files:
  - `home_page.dart`
  - `component_themes.dart`
- Broad `library/part` adoption for repositories/pages/services/modules would create tighter coupling, not cleaner boundaries.

## Recommendation

- introduce theme families, not just more color constants
- keep locale wrapper outside generated i18n
- simplify flavor config
- migrate `AppFailure` first
- split large files instead of adding `part` to normal runtime code

## Open Questions

- should v1 multi-theme architecture expose only default family or include a second starter family?
- should `AppResponse` and pagination stay plain immutable classes?
