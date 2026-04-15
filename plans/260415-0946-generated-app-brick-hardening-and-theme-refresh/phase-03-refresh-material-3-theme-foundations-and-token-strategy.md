# Phase 03: Refresh Material 3 Theme Foundations And Token Strategy

## Context Links

- [Plan overview](./plan.md)
- [Research summary](./research/research-summary.md)
- [Design guidelines](../../docs/07-design-guidelines.md)
- User Figma input: [Material 3 Design Kit](https://www.figma.com/design/90waz2y641iaYfxdPvVC8R/Material-3-Design-Kit--Variables---Properties---Community-?node-id=11-1833&p=f&view=variables&var-set-id=54796-1935&m=dev)

## Overview

- Priority: P1
- Status: Completed
- Goal: upgrade the generated base theme from seed-plus-overrides into a stronger, explicit Material 3 foundation without breaking the public `primary_color` seed contract.

## Key Insights

- current theme quality is acceptable for a basic scaffold but not for a reusable high-quality generator base
- the Variables-view URL was not enough for direct MCP token extraction, but the Figma plugin API exposed the local collections and text styles needed for honest token resolution
- theme work should improve semantic roles and component defaults, not just visual decoration
- `ThemeData.from(...)` is a better baseline than the current direct `ThemeData(...)` assembly
- `AppScreenUtilInit` is currently dead weight unless the starter app actually uses it

## Requirements

- use Figma MCP or plugin API during implementation to resolve the actual usable theme/token source
- define clearer color, typography, spacing, radius, and extension ownership
- keep the output adaptable across support tiers without hardcoding profile-specific visuals
- prefer an internal adaptive-native layer by default
- evaluate `custom_adaptive_scaffold` only if starter-shell navigation genuinely needs it

## Architecture

- promote a token-first theme structure with explicit semantic roles and a `ThemeData.from(...)` baseline
- keep app-specific theme extensions for feedback/status values only where Material roles are insufficient
- avoid expanding `part` into theme files unless codegen requires it; normal explicit files remain the default
- prefer Flutter-native adaptive layout primitives first
- define an internal breakpoint/adaptive helper layer in the scaffold
- avoid `responsive_builder` and ScreenUtil as default dependencies because the base scaffold should not encourage device-type branching or global scaling

## Related Code Files

- Modify:
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/app_theme.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/color_schemes.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/component_themes.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/typography.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/extensions/theme_extensions.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/radius.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/spacing.dart`
- Create:
  - any additional token files or theme guides required by the final structure
- Delete:
  - redundant or misleading theme surfaces superseded by the new structure

## Implementation Steps

1. Resolve the exact Figma/Material token inputs to use.
   - completed via the Figma plugin API after the Variables-view URL resolved to onboarding canvas metadata instead of token data
2. Define the target token map and theme ownership model.
   - kept `primary_color` as the global seed source while aligning typography, spacing, and radius to the Material 3 kit
3. Refresh color roles, typography, spacing, and component theme defaults.
4. Replace dead responsive scaffolding with an internal adaptive-native layer.
5. Validate the generated starter surfaces against the new theme contract.
6. Update generated theming guidance to match the shipped base.

## Todo List

- [x] Resolve Figma token source honestly
- [x] Define explicit theme token ownership
- [x] Refresh component theme defaults
- [x] Re-evaluate theme extensions and typography
- [x] Replace dead responsive scaffolding with internal adaptive helpers
- [x] Sync generated theming docs

## Success Criteria

- generated theme files read as an intentional M3 foundation, not a pile of ad hoc overrides
- theme surfaces are clear enough for agents to extend safely
- theme docs match the shipped token structure
- validator and smoke coverage fail if ScreenUtil-era leftovers return

## Risk Assessment

- Risk: theme refresh becomes cosmetic and disconnected from actual starter usage
- Mitigation: Phase 04 will apply the adaptive helpers and refreshed defaults more visibly in starter-flow screens

## Security Considerations

- none beyond normal asset and dependency hygiene

## Next Steps

- Phase 04 applies the refreshed contracts and theme to the starter app flow and feature brick.

## Completion Notes

- Resolved Material 3 collections and text styles through the Figma plugin API after direct variable extraction from the supplied URL failed.
- Kept `primary_color` as the scaffold's public theme seed while upgrading the base assembly to `ThemeData.from(...)`.
- Corrected the Material 3 `bodySmall` typography token, aligned radius/spacing ownership to the design kit, and removed dead `flutter_screenutil` scaffolding.
- Added generator-side validation plus smoke assertions so theme regressions fail fast instead of drifting silently.
