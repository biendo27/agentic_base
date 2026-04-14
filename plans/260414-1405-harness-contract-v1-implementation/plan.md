---
title: "Harness Contract V1 Implementation"
description: "Implement the harness contract, support-tier manifest, evidence outputs, and SDK policy in generator code, scripts, and tests."
status: completed
priority: P0
effort: 40-56h
branch: main
tags: [implementation, harness, generator, flutter, agents]
blockedBy: []
blocks: []
created: 2026-04-14
---

# Harness Contract V1 Implementation

## Overview

The design work is complete. The remaining work is implementation. `agentic_base` still does not enforce Harness Contract V1 in generator code, generated scripts, or regression tests. This plan turns the finished architecture/docs package into executable behavior.

## Cross-Plan Dependencies

None.

Completed context plans:

- [Harness Contract V1 and Flutter Support Tiers](../260414-1126-harness-contract-v1-and-flutter-support-tiers/plan.md)
- [Agent-Ready Repo Generator V2 Hard Plan](../260413-1238-agent-ready-repo-generator-v2-hard/plan.md)
- [Generator Contract Hardening and Full Scaffold Parity](../260410-1755-generator-contract-hardening-and-parity/plan.md)

## Scope Challenge

- Existing code already covers scaffold contract, thin adapters, deterministic script names, module seams, and basic verification.
- Minimum unfinished work is not "new architecture". It is implementation of the already-approved harness contract in config, generated surfaces, scripts, and tests.
- Complexity is real: this will touch more than 8 files and several generator/test surfaces. The scope should stay focused on the contract rollout and avoid speculative cross-stack work.
- Selected mode: HOLD SCOPE

## Phases

| Phase | Name | Status |
| --- | --- | --- |
| 1 | [Implement Harness Manifest And Contract Validators](./phase-01-implement-harness-manifest-and-contract-validators.md) | Completed |
| 2 | [Implement Support Profile Encoding And Generated Surface Sync](./phase-02-implement-support-profile-encoding-and-generated-surface-sync.md) | Completed |
| 3 | [Implement Eval Gates, Evidence Bundles, And Approval Outputs](./phase-03-implement-eval-gates-evidence-bundles-and-approval-outputs.md) | Completed |
| 4 | [Implement Flutter SDK Manager And Version Policy Enforcement](./phase-04-implement-flutter-sdk-manager-and-version-policy-enforcement.md) | Completed |
| 5 | [Add Regression Coverage, Fixture Updates, And Claim-Safe Rollout](./phase-05-add-regression-coverage-fixture-updates-and-claim-safe-rollout.md) | Completed |

## Dependencies

- Inputs:
  - [docs/08-harness-contract-v1.md](../../docs/08-harness-contract-v1.md)
  - [docs/09-support-tier-matrix.md](../../docs/09-support-tier-matrix.md)
  - [docs/10-manifest-schema.md](../../docs/10-manifest-schema.md)
  - [docs/11-eval-and-evidence-model.md](../../docs/11-eval-and-evidence-model.md)
  - [docs/12-approval-state-machine.md](../../docs/12-approval-state-machine.md)
  - [docs/13-flutter-adapter-boundaries.md](../../docs/13-flutter-adapter-boundaries.md)
  - [docs/14-sdk-and-version-policy.md](../../docs/14-sdk-and-version-policy.md)
  - [docs/05-project-roadmap.md](../../docs/05-project-roadmap.md)
- This plan is implemented.
- Follow-up work should focus on stabilization and future polish, not reopening the shipped contract without new contradictory evidence.
