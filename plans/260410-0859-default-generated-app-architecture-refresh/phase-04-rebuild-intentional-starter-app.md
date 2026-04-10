# Phase 04 - Rebuild Intentional Starter App

## Context Links

- Current starter runtime: `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/app.dart`, `lib/app/bootstrap.dart`, `lib/core/router/app_router.dart`, `lib/features/home/**`
- Drifted fixture: `my_app/lib/app.dart`, `my_app/lib/flavors.dart`, `my_app/lib/pages/my_home_page.dart`
- Design guardrails: `docs/07-design-guidelines.md`
- Research: `./research/current-state-and-tooling-contracts.md`

## Overview

- Priority: P1
- Status: completed
- Effort: 6h
- Blocked by: phases 02-03
- File ownership for this phase:
  - Brick Flutter-layer app shell, router, starter home feature, and mirrored sample app refresh

## Key Insights

- The current generated app works, but it does not teach the intended architecture. It teaches two architectures at once.
- Default starter app must be a real baseline project, not a half-cleaned template plus leftover flavor scaffolding.
- The best starter is simple: one app shell, one router, one starter home feature, clear use of theme, flavor config, and localization.
- `my_app` should be refreshed as generated verification fixture output, not hand-maintained demo code.

## Requirements

- Boot through brick-owned `lib/main*.dart` and `lib/app/*` only.
- Starter UI must exercise the real contracts: typed localization, flavor/app name, env-driven API base URL, router, theme.
- Remove placeholder root app files and dead starter pages.
- Keep the starter small; avoid demo-only complexity or extra features.

## Architecture

### Data Flow

- Input:
  - `main_<flavor>.dart` selects flavor and env file
  - `bootstrap()` wires DI and observers
  - `App` creates router and localization-aware shell
- Transform:
  1. Router lands on starter home route.
  2. Home feature reads generated translations and `FlavorConfig`.
  3. UI renders intentional starter state, not placeholder scaffold leftovers.
- Output: starter app that demonstrates the approved architecture in real code.

### Starter-App Contract

- Keep one `App` class under `lib/app/app.dart`.
- Keep one flavor source under `lib/app/flavors.dart`.
- Home feature owns starter screen content; no `lib/pages/my_home_page.dart`.
- Generated README and AI guides must point new contributors to the same files the runtime uses.

## Related Code Files

- Modify:
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/app.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/bootstrap.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/router/app_router.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/**`
  - generated sample app counterparts under `my_app/lib/**`
- Delete:
  - `my_app/lib/app.dart`
  - `my_app/lib/flavors.dart`
  - `my_app/lib/pages/my_home_page.dart`
  - any matching stale outputs from refreshed generated apps

## Implementation Steps

1. Refactor starter home flow so it lives entirely inside the brick-owned app shell and feature tree.
2. Replace placeholder page behavior with a small intentional screen that shows app name, flavor, and starter localization content.
3. Surface only non-sensitive runtime diagnostics such as example API base URL and current flavor.
4. Regenerate and refresh `my_app` so the fixture mirrors the final starter output and no longer carries the duplicate root shell files.

## Todo List

- [ ] Remove duplicate root starter files
- [ ] Tighten starter home feature to one intentional flow
- [ ] Use final i18n + flavor contracts in UI
- [ ] Refresh `my_app` fixture from the generated output

## Success Criteria

- Generated app and refreshed `my_app` each have one app shell and one flavor system.
- Starter screen uses router, theme, generated i18n, and env-driven config.
- No stale `lib/pages/` placeholder content remains.
- Starter app still feels minimal and easy to extend.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Starter UI becomes overbuilt | Low | Medium | Keep one route and one small home feature only |
| Cleanup breaks router or bootstrap flow | Medium | High | Change one contract at a time and verify after each deletion |
| Fixture drifts again after future template edits | Medium | Medium | Refresh `my_app` via phase-5 deterministic smoke workflow |

## Security Considerations

- Do not expose secrets or private endpoints in starter diagnostics.
- Keep starter home content safe for screenshots and public repos.
- Avoid adding debug-only screens that would survive into production templates.

## Rollback

- Revert only starter runtime files if UI cleanup blocks generation.
- Keep i18n and flavor contract changes from earlier phases intact if already verified.

## Next Steps

- Phase 05 verifies `my_app` plus a fresh generated app and syncs all docs.
