---
title: "Harness Contract V1 and Flutter Support Tiers"
description: "Define the harness-first contract, support-tier model, and migration roadmap before implementing the next generator evolution."
status: completed
priority: P1
effort: 32-44h
branch: main
tags: [architecture, harness, generator, flutter, agents]
blockedBy: []
blocks: []
created: 2026-04-14
---

# Harness Contract V1 and Flutter Support Tiers

## Overview

Define the next product contract for `agentic_base` before implementation. The repo already has an agent-ready scaffold contract; this plan formalizes the stronger harness-first contract, tiered support model, manifest shape, eval/evidence model, and migration path needed for reliable agent execution.

## Cross-Plan Dependencies

None.

## Phases

| Phase | Name | Status |
| --- | --- | --- |
| 1 | [Define Harness Contract V1](./phase-01-define-harness-contract-v1.md) | Completed |
| 2 | [Define Support Tier Matrix And Manifest Schema](./phase-02-define-support-tier-matrix-and-manifest-schema.md) | Completed |
| 3 | [Design Eval, Evidence, And Approval Model](./phase-03-design-eval-evidence-and-approval-model.md) | Completed |
| 4 | [Design Flutter Adapter Boundaries And Versioning Policy](./phase-04-design-flutter-adapter-boundaries-and-versioning-policy.md) | Completed |
| 5 | [Create Implementation Roadmap And Migration Gates](./phase-05-create-implementation-roadmap-and-migration-gates.md) | Completed |

## Dependencies

- Inputs:
  - [brainstorm-260414-1119-harness-first-flutter-agentic-base-direction.md](../reports/brainstorm-260414-1119-harness-first-flutter-agentic-base-direction.md)
  - [docs/03-code-standards.md](../../docs/03-code-standards.md)
  - [docs/04-system-architecture.md](../../docs/04-system-architecture.md)
- This plan does not implement code.
- This plan should finish before any larger repo-wide generator redesign or new product claims.

## Outputs

- [`docs/08-harness-contract-v1.md`](../../docs/08-harness-contract-v1.md)
- [`docs/09-support-tier-matrix.md`](../../docs/09-support-tier-matrix.md)
- [`docs/10-manifest-schema.md`](../../docs/10-manifest-schema.md)
- [`docs/11-eval-and-evidence-model.md`](../../docs/11-eval-and-evidence-model.md)
- [`docs/12-approval-state-machine.md`](../../docs/12-approval-state-machine.md)
- [`docs/13-flutter-adapter-boundaries.md`](../../docs/13-flutter-adapter-boundaries.md)
- [`docs/14-sdk-and-version-policy.md`](../../docs/14-sdk-and-version-policy.md)
- [`reports/scout-report.md`](./reports/scout-report.md)
- [`reports/red-team-review.md`](./reports/red-team-review.md)
- [`research/research-summary.md`](./research/research-summary.md)

## Validation Log

### Session 1 — 2026-04-14
**Trigger:** User validation interview after initial hard-mode plan creation  
**Questions asked:** 4

#### Questions & Answers

1. **[Scope]** How should this new plan relate to the existing trust-repair plan?
   - Options: Keep them parallel; trust-repair can continue independently | Let trust-repair continue for narrow honesty fixes, but block broader vNext redesign/product claims on this new plan | Block trust-repair entirely until this new plan completes
   - **Answer:** Custom input
   - **Custom input:** Delete the old plan because it is unrelated to the current goal.
   - **Rationale:** The new harness-contract planning track should stand on its own and should not carry a dependency on a stale, no-longer-relevant proposed plan.

2. **[Architecture]** Where should the v1 harness schema live?
   - Options: Extend `.info/agentic.yaml` and keep one machine-readable source of truth (Recommended) | Split into `.info/agentic.yaml` plus a second schema file now | Keep schema only in docs for now, delay config changes
   - **Answer:** Extend `.info/agentic.yaml` and keep one machine-readable source of truth
   - **Rationale:** The harness model should stay mechanically legible and centralized instead of creating a second config surface too early.

3. **[Tradeoffs]** How should quality be represented in v1?
   - Options: One public scalar score | Multiple internal dimensions such as correctness, release-readiness, observability, UX confidence (Recommended) | No quality model at all in v1
   - **Answer:** Multiple internal dimensions such as correctness, release-readiness, observability, UX confidence
   - **Rationale:** Multi-dimensional quality is more honest and avoids fake precision while the harness model is still being defined.

4. **[Scope]** What should tier-2 profiles guarantee in v1?
   - Options: Same required gates as tier-1 | Core required gates only, with extra profile-specific checks documented as non-guaranteed/advisory (Recommended) | No formal guarantees; documentation only
   - **Answer:** Core required gates only, with extra profile-specific checks documented as non-guaranteed/advisory
   - **Rationale:** Tier-2 should stay truthful and useful without inheriting guarantees that the implementation cannot back yet.

#### Confirmed Decisions

- Old unrelated proposed plan: remove it and remove all dependencies on it
- Machine-readable source of truth: keep it in `.info/agentic.yaml`
- Quality model: use multiple internal dimensions in v1
- Tier-2 support: require core gates only; treat extra checks as advisory

#### Action Items

- [x] Remove the obsolete trust-repair plan and its references
- [x] Update phase files to reflect the single-source-of-truth decision
- [x] Update phase files to reflect the multi-dimensional quality model
- [x] Update phase files to reflect the tier-2 core-gates-only decision

#### Impact on Phases

- Phase 01: remove obsolete-plan dependency and formalize `.info/agentic.yaml` as the single machine-readable source of truth
- Phase 02: make tier-2 guarantees core-only and keep manifest evolution inside `.info/agentic.yaml`
- Phase 03: define quality as multiple internal dimensions, not one public scalar
- Phase 05: update roadmap and migration sequencing without the deleted proposed plan

### Session 2 — 2026-04-14
**Trigger:** Auto execution of the approved planning lane  
**Questions asked:** 0

#### Completed Outputs

- Harness contract defined and documented
- support tier matrix and additive manifest schema documented
- eval/evidence model and approval state machine documented
- Flutter adapter boundaries and SDK/version policy documented
- roadmap updated with implementation waves and migration gates

#### Remaining Work

- Implement the contract in generator code and tests in a follow-up execution plan
