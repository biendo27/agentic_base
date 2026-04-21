---
title: "Generator Contract, Firebase, DI, and Layout Hardening"
description: "Resolve generated app runtime failures and align run scripts, dependency freshness, Firebase setup, DI startup, and service layout with the harness contract."
status: completed
priority: P1
effort: 26h
issue:
branch: feature/generator-contract-firebase-di-layout-hardening
tags: [feature, refactor, flutter, generator, firebase, harness]
blockedBy: []
blocks: []
created: 2026-04-21
---

# Generator Contract, Firebase, DI, and Layout Hardening

## Overview

This plan updates `agentic_base` so newly generated Flutter apps run across `dev/staging/prod`, remain bootable without credentials, use a cleaner DI/startup boundary, support explicit Firebase setup, keep service folders legible, and use latest verified dependency constraints. Progress: 6/6 phases complete; package validation and Android native smoke passed.

## Cross-Plan Dependencies

| Relationship | Plan | Status |
| --- | --- | --- |
| None | No active pending/in-progress overlapping plan found. | N/A |

## Decisions

- Canonical flavors: `dev`, `staging`, `prod`; `stg` is only a `tools/run.sh` alias.
- Generated run command: `./tools/run.sh [dev|staging|stg|prod]`; remove `run-dev.sh`.
- Dependency policy: newest stable compatible verified by release evidence; no unverified live pub.dev resolution during normal install.
- Firebase setup: explicit post-create command/script, never automatic inside non-interactive `create`.
- GetIt DI: injectable is source of truth; generated startup file owns init order only.
- New module services live under `lib/services`, while `lib/core` stays app-shell/infrastructure.
- Implementation branch starts from `develop`; no direct feature work on `main`.

## Phase Ownership And Sequencing Gates

- Phase 02 owns dependency catalog refresh and `uni_links` removal. Phase 05 may only add regression tests for that removal.
- Phase 03 owns service path migration, scanner, and startup policy.
- Phase 04 owns Firebase setup command, generated Firebase option paths, `flavorizr.yaml`, and setup tests only.
- Phase 05 owns runtime crash hardening: ads metadata, Firebase no-op services, bootstrap zone, lint cleanup.
- No phase may modify another phase's owned files except for import-path updates explicitly listed in that phase.

## Backwards Compatibility

- Fresh `create`: emit only the new contract.
- `upgrade`: replace generator-owned `tools/run-dev.sh` with `tools/run.sh` and print a breaking-change warning; no permanent wrapper.
- `init`: do not delete user-owned Firebase/native config; migrate only generator-owned files.
- Existing `lib/firebase_options.dart` receives a compatibility import or explicit migration warning.

## Phases

| Phase | Name | Status |
| --- | --- | --- |
| 1 | [Run Contract And Flavor Policy](./phase-01-run-contract-and-flavor-policy.md) | Complete |
| 2 | [Dependency Freshness And Module Catalog](./phase-02-dependency-freshness-and-module-catalog.md) | Complete |
| 3 | [Service Layout And DI Startup Split](./phase-03-service-layout-and-di-startup-split.md) | Complete |
| 4 | [Firebase Multi-Flavor Setup Harness](./phase-04-firebase-multi-flavor-setup-harness.md) | Complete |
| 5 | [Default Module Runtime Safety](./phase-05-default-module-runtime-safety.md) | Complete |
| 6 | [Validation, Docs, And Release Evidence](./phase-06-validation-docs-and-release-evidence.md) | Complete |

## Validation Evidence

- `dart pub get`, `dart format --set-exit-if-changed lib bin test tool`, and `dart analyze --fatal-infos` passed.
- Unit chunks passed: `97` config/docs/deploy/observability/tui, `106` modules/generators, `76` CLI.
- Slow generated-app canary passed after the final DI constructor fix.
- Android-only create and generated verify passed after platform-aware native validation/readiness fixes.
- Android native launch passed on `R58M35FT1NR`; evidence log `/Users/biendh/base/plans/reports/native-260421-1104-android-launch-log.txt`; no `FATAL EXCEPTION`, `Zone mismatch`, or `MobileAdsInitProvider` match.

## Dependencies

- Official Dart pub behavior: `dart pub add` selects latest stable compatible by default.
- Official Firebase/FlutterFire setup and `flutterfire configure` behavior.
- `flutter_flavorizr` Firebase config support.
- Existing generated-app smoke tests and contract validator.
- Android native launch smoke is blocking for completion when this plan claims runtime crash fixes.

## Open Questions
- None.
