# Phase 04 - Refresh Default App UI System And Starter Surfaces

## Context Links

- [Phase 03](./phase-03-implement-golden-path-runtime-seams-and-profile-aware-gates.md)
- [Design Guidelines](../../docs/07-design-guidelines.md)
- [Generated App Brick Hardening And Theme Refresh](../260415-0946-generated-app-brick-hardening-and-theme-refresh/plan.md)

## Overview

- Priority: P1
- Current status: Complete
- Brief description: Refresh the generated starter UI so the default subscription-commerce app looks mainstream, trustworthy, and accessible while making the golden-path seams visible on day 0.

## Key Insights

- The first design-system query leaned too luxury and too glass-heavy.
- The better fit for broad users is a clear, trustworthy, high-readability commerce UI.
- The UI should prove the starter contract, not act like a fake production design.

## Requirements

### Functional Requirements

- Choose one default design direction suitable for most users.
- Make starter routes visibly exercise:
  - entitlement state
  - remote config and feature flags
  - analytics/crash-safe starter points
  - payment and ads seams without pretending live commerce
- Keep the default starter polished but honest.

### Non-Functional Requirements

- Accessibility first
- Strong readability
- Safe light and dark behavior
- No fragile luxury-only styling

## Architecture

- Use a “trustworthy accessible commerce” visual system:
  - bright neutral background
  - blue primary
  - orange CTA accent
  - readable slate text
  - Material 3 base
  - restrained motion
- Typography:
  - heading: Lexend
  - body: Source Sans 3
- Avoid:
  - heavy glass
  - luxury serif direction
  - AI-purple gradients
  - overly editorial oversized hero styles

<!-- Updated: Validation Session 2 - trustworthy-commerce theme family and profile-aware starter cards now ship in the brick -->

## Related Code Files

### Files To Modify

- [docs/07-design-guidelines.md](/Users/biendh/base/docs/07-design-guidelines.md)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/05-theming-guide.md](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/05-theming-guide.md)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/app_theme.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/app_theme.dart)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/app_theme_family.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/app_theme_family.dart)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/typography.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/typography.dart)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/presentation/pages/home_page.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/presentation/pages/home_page.dart)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/presentation/pages/starter_monetization_page.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/presentation/pages/starter_monetization_page.dart)

### Files To Create

- profile-aware starter widgets or cards as needed under the generated app brick

### Files To Delete

- none expected

## Implementation Steps

1. Freeze the visual direction from the UI skill outputs.
2. Update theme tokens and typography defaults.
3. Refresh starter cards and monetization surfaces so they explain the golden-path seams honestly.
4. Keep accessibility and clarity above novelty.
5. Add widget tests for the new starter presentation where needed.

## Todo List

- [x] Freeze trustworthy-accessible-commerce theme direction
- [x] Update typography and color tokens
- [x] Refresh starter surfaces to show golden-path seams
- [x] Keep motion restrained and accessibility-first
- [x] Add widget coverage for changed starter surfaces

## Success Criteria

- Default generated app feels mainstream and trustworthy, not luxury or gimmicky.
- The starter visibly explains subscription-commerce seams without faking a production paywall.
- The design direction stays readable for broad audiences.

Status: met.

## Risk Assessment

- Risk: over-designing the starter into a marketing demo.
- Mitigation: keep the starter educational, not ornamental.

## Security Considerations

- No starter copy should imply live payment or live ads are active without setup.
- Consent-sensitive surfaces should stay explicit.

## Next Steps

- Completed in Phase 05: docs, tests, migration notes, and delivery guidance are now locked to the shipped contract.
