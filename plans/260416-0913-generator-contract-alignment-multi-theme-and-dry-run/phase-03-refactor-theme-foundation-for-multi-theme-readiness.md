# Phase 03 — Refactor Theme Foundation For Multi-Theme Readiness

## Context Links

- [plan.md](./plan.md)
- [generated-app-architecture-review](./research/generated-app-architecture-review.md)
- [App Theme](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/app_theme.dart>)
- [Color Schemes](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/color_schemes.dart>)
- [Theming Guide](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/05-theming-guide.md>)

## Overview

- Priority: P0
- Status: Pending
- Goal: convert the starter theme from one static light/dark pair into a clean theme-family architecture that can support multiple branded theme sets later without rewiring the app shell.

## Key Insights

- current theme layer supports only one palette family with `ThemeMode`.
- component theming is centralized but too monolithic.
- theme docs claim a stable foundation, but the implementation is still family-singleton.
<!-- Updated: Validation Session 1 - v1 ships one default family only, but the architecture must be family-ready -->

## Requirements

- Keep the default Material 3 family.
- Introduce theme-family identity without requiring a theme marketplace or user-configured packs.
- Preserve light/dark/system switching.
- Keep adaptive-native layout strategy.
- Do not bundle a second starter family in this wave.

## Architecture

- Introduce a theme family bundle:
  - family id
  - light/dark `ColorScheme`
  - theme extensions
  - typography set
  - component-theme composer
- `AppThemeController` owns:
  - `ThemeMode`
  - selected family id
- `AppTheme` becomes a builder/factory over bundles instead of two static getters only.
- Split large component theme definitions into smaller files grouped by concern if needed.

## Related Code Files

- Modify:
  - [App Theme](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/app_theme.dart>)
  - [Color Schemes](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/color_schemes.dart>)
  - [Component Themes](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/component_themes.dart>)
  - [Typography](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/typography.dart>)
  - [Theme Extensions](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/extensions/theme_extensions.dart>)
  - [App Theme Controller](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/theme/app_theme_controller.dart>)
  - [App Theme Scope](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/theme/app_theme_scope.dart>)
  - [Generated Theming Guide](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/05-theming-guide.md>)
- Add:
  - theme family bundle/registry files
  - tests for family selection and fallback

## Implementation Steps

1. Define the minimal theme-family domain model and starter default family.
2. Replace static two-getter theme assembly with family-based theme creation.
3. Extend controller/scope APIs to track family id plus mode.
4. Split component theme composition into smaller concern-based units if file size still exceeds standards.
5. Update starter settings screen and docs only as needed to explain the active default family honestly, without turning the starter into a multi-family demo.
6. Add tests for family lookup, fallback, and theme assembly invariants.

## Todo List

- [ ] define theme family bundle model
- [ ] refactor theme assembly
- [ ] extend controller to track family id
- [ ] split large theme files where needed
- [ ] update starter settings/theme docs without bundling a second family
- [ ] add theme invariants tests

## Success Criteria

- theme layer supports more than one family structurally
- no app-shell rewrite would be needed to add a second family later
- component theme code is smaller and more modular
- docs explain family vs mode clearly

## Risk Assessment

- over-designing theme families now could add complexity without immediate value
- exposing family switching in starter UI may make the starter feel less neutral

## Security Considerations

- none beyond standard asset/config handling

## Next Steps

- Hand off family-aware theme APIs to Phase 04 for flavor/settings/runtime cleanup.
