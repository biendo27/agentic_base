---
title: "CI Test Speed And Generated App Hardening"
description: "Make package CI faster while fixing generated CI/CD truthfulness and native runtime regressions."
status: completed
priority: P0
effort: 34h
issue:
branch: develop
tags: [infra, testing, cicd, generator, flutter]
blockedBy: []
blocks: []
created: 2026-04-21
---

# CI Test Speed And Generated App Hardening

## Overview

Resolve the remaining issues found after publishing and device testing: slow duplicated generator tests, missing interactive CI provider prompt, broken rendered workflow tokens, generated PR CI building prod without prod env, iOS AdMob plist crash, unclear native gate policy, and generated-app strict lint ambiguity.

## Inputs

- [Research: CI/Test Speed](./research/researcher-01-ci-test-speed-best-practices.md)
- [Research: Generated CI/CD And Native Runtime](./research/researcher-02-generated-cicd-native-runtime-report.md)
- [Scout Report](./reports/scout-report.md)
- [Red Team Review](./reports/red-team-review.md)
- Completed context: [Generator Contract, Firebase, DI, and Layout Hardening](../260421-1012-generator-contract-firebase-di-layout-hardening/plan.md)

## Scope Challenge

- Existing code: `dart_test.yaml`, generated-app smoke tests, `runVerify`, `AGENTIC_VERIFY_FAST`, generated CI templates, generated scripts, `GeneratedProjectContract`, and Ads module mutation already exist.
- Minimum changes: split test lanes, add explicit verify mode, fix generated CI rendering/build policy, prompt CI provider, repair iOS AdMob metadata, add contract/native regressions.
- Complexity: touches more than 8 files but the files are already the contract owners. No new service layer needed. Selected mode: HOLD SCOPE.

## Cross-Plan Dependencies

| Relationship | Plan | Status |
| --- | --- | --- |
| Context only | [260421-1012](../260421-1012-generator-contract-firebase-di-layout-hardening/plan.md) | Completed |

## Phases

| Phase | Name | Status |
| --- | --- | --- |
| 1 | [Root Test Taxonomy And Fast CI Baseline](./phase-01-root-test-taxonomy-and-fast-ci-baseline.md) | Completed |
| 2 | [Verification Mode And Runtime Budget](./phase-02-verification-mode-and-runtime-budget.md) | Completed |
| 3 | [Generated CI/CD Contract Hardening](./phase-03-generated-cicd-contract-hardening.md) | Completed |
| 4 | [Native iOS Runtime And Strict Lint Hardening](./phase-04-native-ios-runtime-and-strict-lint-hardening.md) | Completed |
| 5 | [Validation Docs And Rollout Evidence](./phase-05-validation-docs-and-rollout-evidence.md) | Completed |

## Dependencies

- Official `package:test` tags and `dart_test.yaml`
- GitHub Actions concurrency/caching/check semantics
- GitLab manual/protected environment semantics
- Flutter/AdMob/Firebase native setup requirements
- Current Gitflow: feature branch from `develop`, merge back to `develop`

## Success Criteria

- Root PR fast lane no longer executes generated-app smoke implicitly.
- Heavy generated/native gates run only when justified, but failures still fail the aggregate required CI status.
- Fresh generated GitHub workflows contain no unresolved Mason tokens and do not build prod in credentialless PR CI.
- Interactive `agentic_base create` asks for CI provider; non-interactive default remains `github`.
- Fresh generated app with ads module runs on iOS simulator without `GADInvalidInitializationException`.
- Generated app strict lint policy is explicit and mechanically tested.

## Validation

- [Validation Results](./reports/validation-results.md)

## Open Questions

None.
