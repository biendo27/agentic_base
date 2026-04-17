---
title: "Contract Truthfulness, Shared Contract Modeling, and Smoke Reliability"
description: "Freeze the now-correct contract docs/testing surface, realign generated shared contracts with their published rule, and make smoke verification faster without weakening harness honesty."
status: complete
priority: P0
effort: 24-34h
branch: develop
tags: [planning, generator, docs, flutter, contracts, testing]
blockedBy: []
blocks: []
created: 2026-04-17
---

# Contract Truthfulness, Shared Contract Modeling, and Smoke Reliability

## Overview

This plan closes the remaining gap between what `agentic_base` now claims, what generated shared contracts teach, and how comfortably the repo can prove those claims in CI. Two historical review findings are already fixed in the current tree, so this wave treats them as regression-proofing work only. The real implementation focus is the generated contract package and the heavy smoke lane, with validation now locked toward an extension-oriented shared-contract policy and a two-lane smoke strategy.

## Inputs

- [Research Summary](./research/research-summary.md)
- [Scout Report](./reports/scout-report.md)
- [Red Team Review](./reports/red-team-review.md)
- [Docs and Contract Drift Report](../reports/researcher-260417-0912-docs-and-contract-drift.md)
- [Smoke Verification Reliability Report](../reports/researcher-260417-0912-smoke-verification-reliability.md)

## Cross-Plan Dependencies

No active blockers. This plan is a focused follow-up to completed generator hardening waves:

- [260416-1126-contract-docs-and-generated-app-harness-clarity](../260416-1126-contract-docs-and-generated-app-harness-clarity/plan.md)
- [260416-0913-generator-contract-alignment-multi-theme-and-dry-run](../260416-0913-generator-contract-alignment-multi-theme-and-dry-run/plan.md)

## Scope Challenge

- Existing code: root docs truthfulness tests and generated-doc validators already cover the old findings; shared contract files and tests already exist; smoke tests already prove real end-to-end generation.
- Minimum change set: keep findings 1-2 closed with stronger guards, change the published rule explicitly if the current extension-oriented contract package remains the chosen model, and trim smoke cost by removing duplication plus splitting an internal fast lane from one honest slow canary. Do not broaden this into a `core/contracts` package redesign or a wide `tools/verify.sh` rewrite.
- Complexity: about 10-14 files, no new product surface, at most one small shared smoke-test helper. Selected mode: HOLD SCOPE.

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | [Freeze Truthful Contract and Test Surfaces](./phase-01-freeze-truthful-contract-and-test-surfaces.md) | Complete |
| 2 | [Realign Shared Contract Modeling](./phase-02-realign-shared-contract-modeling.md) | Complete |
| 3 | [Refactor Smoke Verification for Speed and Confidence](./phase-03-refactor-smoke-verification-for-speed-and-confidence.md) | Complete |
| 4 | [Final Verification and Drift Guard Sync](./phase-04-final-verification-and-drift-guard-sync.md) | Complete |

## Validation Log

### Validation Session 1 — 2026-04-17

1. Findings 1 and 2 remain in scope as regression-proofing only; no wide doc rewrite.
2. Shared-contract policy will keep intrinsic helpers in extensions unless targeted best-practice research proves a strong reason to reopen the decision. Docs and tests must be updated to make that rule explicit and consistent.
3. Smoke policy is two-lane:
   - fast lane always blocking
   - slow canary blocking only for harness, verify, evidence, or native-surface changes
4. Duplicate `app_smoke_test.dart` execution should be removed by excluding it from the generic `flutter test` pass while keeping it as an explicit named smoke gate.

### Validation Session 2 — 2026-04-17

1. Implementation and verification complete in tree.
2. Verification pack used:
   - `dart analyze --fatal-infos`
   - `dart test test/src/docs/harness_contract_documentation_test.dart`
   - `dart test test/src/generators/project_generator_test.dart`
   - `dart test test/src/cli/commands/create_command_test.dart`
   - `dart test test/integration/generated_app_smoke_test.dart --exclude-tags slow-canary`
   - `dart test test/integration/generated_app_smoke_test.dart --tags slow-canary`
3. Slow-canary policy is now the close-out rule:
   - fast smoke always blocks
   - slow canary blocks for harness, verify, evidence, or native-surface changes
4. Final state: docs, generated contract modeling, and smoke verification are aligned; no further plan scope remains.

## Success Criteria

- Root docs `08-13` and generated testing/workflow docs remain truthful and are enforced by tests instead of reviewer memory.
- Generated `lib/core/contracts` matches the final documented extension-oriented policy with updated tests and examples.
- The smoke lane keeps one honest end-to-end canary, removes obvious duplicate work, and finishes fast enough to be a practical completion gate while the blocking policy stays explicit.
- Final docs, tests, and generated-project validators agree on the same shipped behavior.
