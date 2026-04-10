---
title: "Default Generated App Architecture Refresh"
description: "Balanced rewrite of the generated Flutter starter so brick-owned Flutter files are the only source of truth and the output app is a real starter app."
status: completed
priority: P1
effort: 28h
branch: main
tags: [feature, flutter, cli, generator, architecture]
blockedBy: []
blocks: []
created: 2026-04-10
---

# Default Generated App Architecture Refresh

## Overview

Refresh the default generated Flutter app with the approved balanced-rewrite direction. Source translations move to `assets/i18n`, Slang runs only through `build.yaml`, generated i18n code lives in `lib/app/i18n`, `flutter_flavorizr` owns native flavor artifacts only, and the brick becomes the single source of truth for Flutter-layer files.

Current `my_app` is green on `flutter analyze` and `flutter test`, but its architecture drift is real: dual app shells, duplicate flavor systems, no Slang wiring, no IDE contract, and runtime URLs hardcoded in Dart. This plan fixes the contract without turning the starter into a heavy framework, and it treats `my_app` as a generated verification fixture rather than a second architecture source.

## Research

- [Current State And Tooling Contracts](./research/current-state-and-tooling-contracts.md)

## Cross-Plan Dependencies

None. [`260409-1140-agentic-base-implementation`](../260409-1140-agentic-base-implementation/plan.md) is completed.

## Phases

| Phase | Name | Status |
| --- | --- | --- |
| 1 | [Lock Generated App Ownership Boundary](./phase-01-lock-generated-app-ownership-boundary.md) | Completed |
| 2 | [Wire Slang And Assets I18n Contract](./phase-02-wire-slang-and-assets-i18n-contract.md) | Completed |
| 3 | [Fix Flavor Env And IDE Contracts](./phase-03-fix-flavor-env-and-ide-contracts.md) | Completed |
| 4 | [Rebuild Intentional Starter App](./phase-04-rebuild-intentional-starter-app.md) | Completed |
| 5 | [Verify Generator And Sync Docs](./phase-05-verify-generator-and-sync-docs.md) | Completed |

## Dependency Graph

- Execute phases strictly in order. Shared ownership around `project_generator.dart`, brick docs, and starter-app bootstrap makes parallel work unsafe.
- Phase 1 freezes file ownership and delete rules.
- Phase 2 depends on the phase-1 ownership contract.
- Phase 3 depends on phase 1 and consumes phase-2 i18n paths for IDE run configs.
- Phase 4 depends on phases 2-3 because starter UI must use final i18n and flavor contracts.
- Phase 5 runs last; it verifies all earlier contracts and updates docs.

## Compatibility And Rollback

- Backwards compatibility: keep `agentic_base create` flags, flavor names, and generated Clean Architecture layout stable; migrate docs and sample app to the new paths.
- Migration path: replace legacy `l10n/` with `assets/i18n`, remove duplicate root app files, move runtime config to env-driven flavor bootstrapping, then refresh `my_app`.
- Rollback rule: each phase lands in isolation; if a phase fails, revert only that phase's files and keep prior verified contracts intact.

## Success Gates

- Fresh generated app contains one Flutter app shell only: no `lib/app.dart`, no `lib/flavors.dart`, no `lib/pages/my_home_page.dart`.
- Slang runs via `dart run build_runner build --delete-conflicting-outputs` and outputs under `lib/app/i18n`.
- `flutter_flavorizr` stops generating Flutter-layer Dart files and emits valid native app ids.
- Brick ships `.vscode` plus shared `.idea/runConfigurations` only.
- Fresh temp app created through the real `create` flow passes codegen, layout assertions, `flutter analyze`, and `flutter test`.
- Refreshed `my_app` fixture passes the same smoke checks and is reproducibly regenerated from the brick/generator contract.

## Red Team Review

Accepted:
- Make critical generator steps blocking by contract. No warn-and-continue on flavor/codegen/layout/analyze/test failures.
- Add one mandatory end-to-end `create` smoke gate for a fresh temp app.
- Add a strict execution-surface run matrix so CLI, IDE, scripts, docs, and CI all launch the same contract.
- Reframe `my_app` as generated verification fixture, not a second architecture source.
- Add forbidden `.idea` guardrails and regression checks.
- Extend scope to `FeatureGenerator` + `agentic_feature` so new features can follow the `assets/i18n/<module>` contract.

Accepted with modification:
- App-id normalization stays in scope, but only as one explicit generator-owned helper with documented rules and fail-fast validation. No hidden Mason-only mutation.
- Doc sync stays in scope, but only for canonical surfaces and stale generated guides.

Rejected:
- Removing shared `.idea/runConfigurations` from scope. User explicitly requires IDE flavor/env launch support in both VS Code and JetBrains.
