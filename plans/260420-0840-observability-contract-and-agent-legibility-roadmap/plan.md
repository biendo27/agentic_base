---
title: "Observability Contract And Agent Legibility Roadmap"
description: "Finish the remaining observability gap with a repo-scoped runtime baseline, inspectable telemetry exports, and agent-legible operator surfaces."
status: completed
priority: P1
effort: 84-112h
branch: develop
tags: [feature, observability, runtime, infra, tech-debt]
blockedBy: []
blocks: []
created: 2026-04-20
---

# Observability Contract And Agent Legibility Roadmap

## Overview

This umbrella plan closes the last major contract gap left after the `subscription-commerce-app` golden-path wave: true observability. Scope is repo-scoped and local-first. It covers generated-repo runtime observability, inspectable telemetry exports, and agent-legible operator/report surfaces. It does not pretend this package is a hosted observability platform.

## Scope Challenge

- Existing code: evidence bundles, `summary.json`, `commands.ndjson`, `AgenticLogger`, generated harness scripts, logging/crashlytics seams, approval-state outputs.
- Minimum changes: add runtime signals, export/query surfaces, and local operator inspection without widening into a SaaS backend.
- Complexity: touches generator, manifest, CLI, generated brick, docs, and tests. Five phases are justified.
- Selected mode: HOLD SCOPE.

## Cross-Plan Dependencies

No active blockers. Relevant completed plans are context only:

- [260417-1344-harness-profile-execution-golden-path-and-default-app-contract](../260417-1344-harness-profile-execution-golden-path-and-default-app-contract/plan.md)
- [260417-0912-contract-truthfulness-contract-modeling-and-smoke-reliability](../260417-0912-contract-truthfulness-contract-modeling-and-smoke-reliability/plan.md)
- [260416-1126-contract-docs-and-generated-app-harness-clarity](../260416-1126-contract-docs-and-generated-app-harness-clarity/plan.md)

## Phases

| Phase | Name | Status |
|-------|------|--------|
| 1 | [Freeze Observability Contract And Support Envelope](./phase-01-freeze-observability-contract-and-support-envelope.md) | Completed |
| 2 | [Add Runtime Observability Baseline To Generated Repos](./phase-02-add-runtime-observability-baseline-to-generated-repos.md) | Completed |
| 3 | [Add Telemetry Export And Inspection Surfaces](./phase-03-add-telemetry-export-and-inspection-surfaces.md) | Completed |
| 4 | [Add Agent-Legible Operator Reports And Approval Traces](./phase-04-add-agent-legible-operator-reports-and-approval-traces.md) | Completed |
| 5 | [Lock Tests Docs Migration And Rollout](./phase-05-lock-tests-docs-migration-and-rollout.md) | Completed |

## Dependencies

- keep `evidence_quality` stable as the quality dimension for run evidence
- define observability as a new contract layer, not a rename reversal
- keep all observability surfaces local-first and repo-scoped in this wave
- generated repo contract, package CLI, docs, and tests must evolve together

## Out Of Scope

- multi-tenant hosted telemetry backend
- persistent remote operator dashboard
- cross-stack extraction beyond contract-friendly surfaces proven in Flutter first

## Context Links

- [Official Guidance Note](./research/official-observability-guidance.md)
- [README](../../README.md)
- [System Architecture](../../docs/04-system-architecture.md)
- [Harness Contract V1](../../docs/08-harness-contract-v1.md)
- [Manifest Schema](../../docs/10-manifest-schema.md)
- [Eval And Evidence Model](../../docs/11-eval-and-evidence-model.md)
- [Approval State Machine](../../docs/12-approval-state-machine.md)
- [Flutter Adapter Boundaries](../../docs/13-flutter-adapter-boundaries.md)
