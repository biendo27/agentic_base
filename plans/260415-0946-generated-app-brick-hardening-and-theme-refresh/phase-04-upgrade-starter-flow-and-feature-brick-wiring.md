# Phase 04: Upgrade Starter Flow And Feature Brick Wiring

## Context Links

- [Plan overview](./plan.md)
- [Research summary](./research/research-summary.md)
- [Generator gap analysis](../reports/researcher-260415-0946-generator-gap-analysis.md)

## Overview

- Priority: P1
- Status: Completed
- Goal: replace the one-screen boilerplate starter with a stronger base flow and make `agentic_feature` honest about what it generates and wires.

## Key Insights

- the current starter proves boot, routing, flavor diagnostics, and localization, but little else
- the current feature flow emits spec files and structure that are not fully consumed
- the base app should prove one coherent starter journey, not every app profile at once

## Requirements

- ship a better base starter flow that proves shell, navigation, localization, diagnostics, detail flow, settings, and a provider-neutral monetization surface
- keep starter scope generic and reusable across supported profiles
- wire feature specs/tests/routes into production flow
- keep generated structure easy for agents to understand
<!-- Updated: Validation Session 1 - keep simple feature mode as a distinct lightweight path; monetization UI may look production-ready while adapter stays demo/provider-neutral -->

## Architecture

- the starter flow should span more than one route and intentionally demonstrate:
  - dashboard/runtime diagnostics
  - detail navigation
  - settings for locale/theme-related behavior
  - provider-neutral monetization/paywall surface
- the feature brick should become genuinely spec-driven
- `agentic_feature --simple` remains a supported lightweight path and should stay clearly distinct from the full spec-driven mode
- the monetization screen may look production-ready in UI, but its repository and entitlement adapter stay provider-neutral and demo-backed
- generated docs should explain what the starter proves on day 0

## Related Code Files

- Modify:
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/app.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/router/app_router.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/...`
  - `/Users/biendh/base/bricks/agentic_feature/__brick__/...`
  - `/Users/biendh/base/lib/src/cli/commands/feature_command.dart`
  - `/Users/biendh/base/lib/src/generators/feature_generator.dart`
  - `/Users/biendh/base/lib/src/config/spec_parser.dart`
  - `/Users/biendh/base/lib/src/generators/test_generator.dart`
- Create:
  - starter routes/pages/widgets as needed
  - feature-generation support files if spec/test wiring is retained
- Delete:
  - dead starter or feature scaffolding that cannot be made honest

## Implementation Steps

1. Define the day-0 starter journey and route map.
2. Refactor home/base flow into a real starter surface.
3. Wire `feature.spec.yaml` into route and generated test flow.
4. Add provider-neutral monetization repository and entitlement seam with demo adapter.
5. Preserve `--simple` as a lightweight feature path without overpromising full-mode guarantees.
6. Update generated README/docs to describe the real starter and feature contract.

## Todo List

- [x] Define a coherent starter journey
- [x] Add route-level starter flow proof
- [x] Wire feature specs into real generation
- [x] Add provider-neutral monetization seam and screen
- [x] Keep `--simple` as an honest lightweight feature mode
- [x] Sync starter/feature docs

## Execution Notes

- completed in repo state as of 2026-04-15
- starter flow now proves dashboard, detail, settings, and provider-neutral monetization inside the generated home journey
- full `agentic_feature` generation now wires routes, emits spec-contract tests, and renders spec-derived overview/criteria/edge-case copy in the generated page
- `--simple` remains the lighter leaf scaffold without full spec-driven guarantees

## Success Criteria

- the generated app feels like a real base app, not a one-screen placeholder
- `agentic_feature` spec files actively drive generated outputs the repo uses
- route and starter behavior are reflected in tests and docs

## Risk Assessment

- Risk: starter scope balloons into app-profile-specific product logic
- Mitigation: keep only shell, diagnostics, localization, theme, and one feature seam in the base app

## Security Considerations

- route or starter additions must not introduce fake auth/security claims

## Next Steps

- Phase 05 expands service coverage and generator verification for the new contracts and starter flow.
