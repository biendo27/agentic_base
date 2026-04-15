---
title: "Generated App Brick Hardening And Theme Refresh"
description: "Repair end-to-end contract honesty, deepen agentic_app and agentic_feature foundations, refresh the Material 3 theme base, expand verification, and then update docs."
status: in_progress
priority: P0
effort: 64-88h
branch: main
tags: [planning, generator, flutter, bricks, theme, testing, docs]
blockedBy: []
blocks: []
created: 2026-04-15
---

# Generated App Brick Hardening And Theme Refresh

## Overview

This plan resolves the remaining gap between the repo's claimed generator contract and the actual generated Flutter app quality. Scope covers end-to-end SDK-manager honesty, generated app/base contracts, selective brick organization, Material 3 theme refresh, starter-flow uplift, service verification, test-speed optimization, and final docs sync.

## Cross-Plan Dependencies

None. Relevant prior plans are complete and become context only:

- [260414-1405-harness-contract-v1-implementation](../260414-1405-harness-contract-v1-implementation/plan.md)
- [260414-1126-harness-contract-v1-and-flutter-support-tiers](../260414-1126-harness-contract-v1-and-flutter-support-tiers/plan.md)
- [260410-1755-generator-contract-hardening-and-parity](../260410-1755-generator-contract-hardening-and-parity/plan.md)

## Scope Challenge

- Do not reopen the finished harness contract design unless code contradicts it.
- Keep generated output honest for mainstream Flutter product apps; do not turn the starter into a kitchen-sink demo.
- Do not blanket-apply `library` + `part`; use it only where cohesion is real and codegen demands it.
- Keep test-speed work last so optimization does not hide contract regressions.
- Selected mode: HOLD SCOPE, FIX HONESTY, THEN RAISE BASE QUALITY.

## Locked Decisions

- Flutter SDK manager semantics are preference-driven, not strict hard contracts.
- Persist both preferred and resolved Flutter toolchain values in manifest/runtime metadata.
- Toolchain fallback order is:
  1. preferred manager if executable
  2. repo-local inferred manager if executable
  3. system Flutter
  4. fail if no Flutter SDK is available
- Standardize generated app and feature boundaries on `fpdart` in data/domain layers only; presentation converts into normal UI states.
- Keep `feature.spec.yaml` and wire it into real route/test generation instead of leaving it as dead scaffolding.
- Keep `part` limited to codegen leaf files by default.
- Default responsive strategy is an internal adaptive-native layer built on Flutter constraints and breakpoints.
- Do not use ScreenUtil-style global scaling as the base scaffold foundation.
- Evaluate `custom_adaptive_scaffold` only if starter-shell navigation truly needs it; do not add `responsive_builder` as a default dependency.
- Starter day-0 flow must prove:
  - dashboard/runtime diagnostics
  - detail navigation
  - settings surface
  - provider-neutral monetization screen with repository/entitlement abstraction

## Inputs

- [research-summary](./research/research-summary.md)
- [scout-report](./reports/scout-report.md)
- [red-team-review](./reports/red-team-review.md)
- [generator-gap-analysis](../reports/researcher-260415-0946-generator-gap-analysis.md)
- [theme-and-brick-architecture](../reports/researcher-260415-0946-theme-and-brick-architecture.md)

## Phases

| Phase | Name | Status | Depends on |
| --- | --- | --- | --- |
| 1 | [Repair Runtime Honesty And Toolchain Contract](./phase-01-repair-runtime-honesty-and-toolchain-contract.md) | Completed | None |
| 2 | [Define Shared App Contracts And Selective Brick Organization](./phase-02-define-shared-app-contracts-and-selective-brick-organization.md) | Completed | 1 |
| 3 | [Refresh Material 3 Theme Foundations And Token Strategy](./phase-03-refresh-material-3-theme-foundations-and-token-strategy.md) | Completed | 2 |
| 4 | [Upgrade Starter Flow And Feature Brick Wiring](./phase-04-upgrade-starter-flow-and-feature-brick-wiring.md) | Pending | 2,3 |
| 5 | [Expand Service Coverage And Generator Verification](./phase-05-expand-service-coverage-and-generator-verification.md) | Pending | 1,2,4 |
| 6 | [Reduce Test Runtime Without Lowering Assurance](./phase-06-reduce-test-runtime-without-lowering-assurance.md) | Pending | 5 |
| 7 | [Refresh Generated Docs And Repo Docs](./phase-07-refresh-generated-docs-and-repo-docs.md) | Pending | 1,2,3,4,5,6 |

## Success Criteria

- The generated repo cannot claim an SDK manager or version it cannot actually execute.
- `agentic_app` ships stronger shared contracts, a real starter flow, and a cleaner M3 theme base.
- `agentic_feature` is either fully wired into spec/test/route flow or stripped of dead scaffolding.
- Generated app tests cover app shell, service seams, and module-default behavior beyond smoke-only boot checks.
- Test runtime drops materially without reducing contract coverage or native-readiness assurance.
- Generated docs and root docs match the shipped behavior.
- No unresolved product-decision blockers remain before implementation.

## Validation Log

Validation session: 2026-04-15

1. `agentic_feature` simple mode remains supported as a separate lightweight scaffold path.
   - Full spec-driven mode is still the primary architecture path.
   - Simple mode must stay clearly lighter-weight and not pretend to provide the same route/test integration depth.
2. The base monetization surface should look production-ready in UI while remaining backed by a demo/provider-neutral adapter.
   - Generated docs and architecture notes must keep that honesty explicit even if the UI is polished.
3. If Figma MCP cannot resolve a usable token/property payload from the supplied Material 3 link, implementation must stop and ask for a better node instead of silently falling back.
4. `preferred` vs `resolved` Flutter SDK manager values should live in manifest/runtime metadata for agent consumption only.
   - Generated README and downstream human docs should not foreground that distinction by default.

Validation result: proceed.

Execution update: 2026-04-15

- Phase 01 completed.
- Repo now resolves manager-aware Flutter/Dart commands through one fallback path and persists preferred-vs-resolved SDK metadata honestly.
- Full package validation passed after the Phase 01 implementation (`dart analyze --fatal-infos`, `dart test`).
- Phase 02 completed.
- Generated starter apps and generated features now share one typed `fpdart` boundary contract at data/domain edges, plus reusable response/pagination contracts and a stable locale wrapper outside the generated Slang output directory.
- Phase 02 closeout also hardened legacy full-feature generation with explicit host-contract validation and aligned generated transport error normalization with the documented `AppFailure` contract.
- Validation passed for package analysis, generator tests, and generated-app smoke coverage across cubit/GitHub, cubit/GitLab, riverpod, and mobx starter paths.
- Phase 03 completed.
- The app brick now builds its Material 3 theme from `ThemeData.from(...)`, keeps `primary_color` as the global seed source, aligns baseline typography and measurements to the Material 3 design kit, removes dead ScreenUtil scaffolding, and exposes native adaptive helpers through `BuildContextX`.
- Theme drift is now covered in `GeneratedProjectContract` plus generated-app smoke coverage so old responsive leftovers fail fast.

## Context Reminder

```text
/ck:cook /Users/biendh/base/plans/260415-0946-generated-app-brick-hardening-and-theme-refresh/plan.md
```
