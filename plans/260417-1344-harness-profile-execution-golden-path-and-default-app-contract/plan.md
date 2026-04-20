---
title: "Harness Profile Execution, Golden Path, and Default App Contract"
description: "Turn profile metadata into executable generator behavior, lock the subscription-commerce golden path, harden the default app service matrix, and align UI, gates, docs, and tests."
status: complete
priority: P0
effort: 56-76h
branch: feature/harness-profile-execution-golden-path-plan
tags: [planning, generator, flutter, harness, profiles, monetization, ui]
blockedBy: []
blocks: []
created: 2026-04-17
---

# Harness Profile Execution, Golden Path, and Default App Contract

## Overview

This plan resolves the remaining contract gap in `agentic_base`: profile and support-tier claims are now strong in docs and manifest, but still too weak in generated starter behavior and verify execution. Scope also locks the default V1 product lane as `subscription-commerce-app`, defines the thin-base vs golden-path service matrix, renames `observability` to `evidence_quality`, and refreshes the default app UI so the emitted starter is mainstream, trustworthy, and accessibility-friendly.

## Cross-Plan Dependencies

No active blockers. Relevant prior plans are complete and become context only:

- [260414-1126-harness-contract-v1-and-flutter-support-tiers](../260414-1126-harness-contract-v1-and-flutter-support-tiers/plan.md)
- [260414-1405-harness-contract-v1-implementation](../260414-1405-harness-contract-v1-implementation/plan.md)
- [260416-1126-contract-docs-and-generated-app-harness-clarity](../260416-1126-contract-docs-and-generated-app-harness-clarity/plan.md)
- [260417-0912-contract-truthfulness-contract-modeling-and-smoke-reliability](../260417-0912-contract-truthfulness-contract-modeling-and-smoke-reliability/plan.md)

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | [Freeze Product Contract And Service Matrix](./phase-01-freeze-product-contract-and-service-matrix.md) | Complete |
| 2 | [Implement Profile Presets And Default Module Resolution](./phase-02-implement-profile-presets-and-default-module-resolution.md) | Complete |
| 3 | [Implement Golden Path Runtime Seams And Profile-Aware Gates](./phase-03-implement-golden-path-runtime-seams-and-profile-aware-gates.md) | Complete |
| 4 | [Refresh Default App UI System And Starter Surfaces](./phase-04-refresh-default-app-ui-system-and-starter-surfaces.md) | Complete |
| 5 | [Lock Tests Docs Migration And Gitflow Delivery](./phase-05-lock-tests-docs-migration-and-gitflow-delivery.md) | Complete |

## Criteria Coverage

| Criterion | Status | Phase Owner | Residual Risk |
|-----------|--------|-------------|---------------|
| Context contract | Covered | 01, 05 | Root docs and generated docs can drift unless doc tests stay strict |
| Architecture contract | Covered | 01, 02, 03 | Seams may regress if profile behavior leaks into ad hoc template logic |
| Execution contract | Covered | 02, 03, 05 | Shell and Dart policy can diverge if one source of truth is not enforced |
| Capability contract | Covered | 01, 02, 03 | Default-on vs opt-in can blur if new services bypass the frozen matrix |
| Eval contract | Covered | 03, 05 | Tier 1 gate promises may outrun deterministic CI coverage |
| Evidence contract | Covered | 01, 03, 05 | Evidence can overgrow or leak semantics if redaction and schema are loose |
| Approval contract | Maintained and synced | 03, 05 | Approval flow is not redesigned here, only kept coherent with new gates |
| Evidence-quality contract | Covered | 01, 03, 05 | Full-suite reruns are still worth doing in roomier environments even though the contract surfaces are now locked |

## Validation Log

### Validation Session 1 - 2026-04-17

- Phase 1 completed and synced
  - `dart analyze --fatal-infos` passed.
  - `dart test test/src/config/project_metadata_test.dart test/src/generators/project_generator_test.dart` passed.
  - Full `dart test` could not complete in this environment because of disk exhaustion.

- Ads policy: accepted `A`
  - Generate seam, provider runtime, and starter surface in the golden path.
  - Keep ads safe and inactive until consent and config gates are satisfied.
- Payments lane: accepted `A`
  - Treat `subscription-commerce-app` as digital subscription by default.
  - Harden default payment runtime around `in_app_purchase`.
  - Keep external checkout opt-in only.
- Evidence vocabulary: accepted `A`
  - Rename `observability` to `evidence_quality` across docs, schema, code, and tests in this wave.
- Migration: accepted `A`
  - Ship migration guide, manual checklist, and verification steps.
  - Do not build an auto-migrator in this wave.

### Validation Session 2 - 2026-04-17

- Phases 02-05 completed and synced
  - `dart analyze --fatal-infos` passed.
  - `dart test test/src/docs/harness_contract_documentation_test.dart` passed.
  - `dart test test/src/config/profile_preset_test.dart test/src/config/project_metadata_test.dart test/src/cli/commands/create_command_test.dart test/src/generators/profile_gate_contract_test.dart test/src/generators/project_generator_test.dart` passed.
  - `bash -n bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/_common.sh bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release-preflight.sh` passed.
  - `dart test test/integration/generated_app_smoke_test.dart` passed.
  - `dart test` passed.

- Slow-canary hardening: accepted `A`
  - Keep the package smoke canary fast by running generated `verify.sh` in `AGENTIC_VERIFY_FAST=1` mode and leaving real native readiness to the dedicated CI native gate.
  - Stream verify output directly from the integration helper so long-running gates do not look silent.
  - Keep app-shell smoke honest but cheap by skipping module startup hooks and draining the fake home-data timer before teardown.

## Dependencies

- subscription-commerce stays the default V1 profile and the most heavily hardened path
- thin base remains separate from profile-owned default-on capability presets
- generated contract, docs, starter runtime, and verify gates must move together
- implementation should follow Gitflow from `develop` using focused `feature/*` work and conventional commits

## Context Links

- [Thin-But-Hard Harness Criteria And Repo Checklist](../reports/brainstorm-260417-1145-thin-but-hard-harness-criteria-and-repo-checklist.md)
- [Harness-First Flutter Agentic Base Direction](../reports/brainstorm-260414-1119-harness-first-flutter-agentic-base-direction.md)
- [README](../../README.md)
- [Support Tier Matrix](../../docs/09-support-tier-matrix.md)
- [Eval And Evidence Model](../../docs/11-eval-and-evidence-model.md)
