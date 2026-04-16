---
title: "Generator Contract Alignment, Multi-Theme, And Dry-Run Command Surface"
description: "Close the remaining honesty gaps across docs, command execution, generated app architecture, theme extensibility, and dry-run behavior."
status: complete
priority: P0
effort: 48-68h
branch: main
tags: [planning, generator, flutter, docs, theme, cli, refactor]
blockedBy: []
blocks: []
created: 2026-04-16
---

# Generator Contract Alignment, Multi-Theme, And Dry-Run Command Surface

## Overview

This plan resolves the remaining mismatch between what `agentic_base` claims, what its commands actually do, and what the generated Flutter starter is structurally ready to support. Scope includes root/generated docs compression, README cleanup, manager-aware `eval` and `doctor`, `--dry-run` support across the command surface, a true multi-theme-ready theme foundation, selective generated-app refactors, and stronger drift-proof verification.

Implemented so far: preview-only dry-run commands, manager-aware toolchain selection, Freezed-backed shared contracts, the theme-family controller split, and regression tests for the new command behavior.

## Cross-Plan Dependencies

No active blockers. This plan follows completed generator waves and uses them as context only:

- [260415-0946-generated-app-brick-hardening-and-theme-refresh](../260415-0946-generated-app-brick-hardening-and-theme-refresh/plan.md)
- [260414-1405-harness-contract-v1-implementation](../260414-1405-harness-contract-v1-implementation/plan.md)
- [260414-1126-harness-contract-v1-and-flutter-support-tiers](../260414-1126-harness-contract-v1-and-flutter-support-tiers/plan.md)

## Scope Challenge

- Do not reopen support-tier or harness-contract product decisions unless current code contradicts them.
- Do not solve documentation noise by deleting technical truth needed by agents; compress and re-layer instead.
- Do not spread `library` + `part` across normal app files; use modular file splits first.
- Do not over-design multi-theme around user-defined theme packs in v1; first make one starter ready for multiple theme families cleanly.
- Do not add `--dry-run` as fake logging only. Every command must expose a truthful no-side-effect execution path.
- Selected mode: HOLD CONTRACT, REMOVE DRIFT, RAISE EXTENSIBILITY.

## Inputs

- [research-summary](./research/research-summary.md)
- [docs-and-command-contract-review](./research/docs-and-command-contract-review.md)
- [generated-app-architecture-review](./research/generated-app-architecture-review.md)
- [scout-report](./reports/scout-report.md)
- [red-team-review](./reports/red-team-review.md)

## Phases

| Phase | Name | Status | Depends on |
| --- | --- | --- | --- |
| 1 | [Rationalize Root And Generated Documentation Surface](./phase-01-rationalize-root-and-generated-documentation-surface.md) | Completed | None |
| 2 | [Implement Dry-Run And End-To-End Toolchain Honesty](./phase-02-implement-dry-run-and-end-to-end-toolchain-honesty.md) | Completed | 1 |
| 3 | [Refactor Theme Foundation For Multi-Theme Readiness](./phase-03-refactor-theme-foundation-for-multi-theme-readiness.md) | Completed | 1 |
| 4 | [Clean Generated App Architecture And Contract Modeling](./phase-04-clean-generated-app-architecture-and-contract-modeling.md) | Completed | 2,3 |
| 5 | [Strengthen Drift Guards, Verification, And Final Docs Sync](./phase-05-strengthen-drift-guards-verification-and-final-docs-sync.md) | Completed | 1,2,3,4 |

## Success Criteria

- Root docs and generated app docs become smaller, role-based, and free of contradictory “future” language where implementation already exists.
- Root `README.md` becomes a concise landing page instead of a mixed landing page plus full contract spec.
- Generated app README becomes a thin operator entrypoint, with detail delegated to `docs/01-06`.
- `eval` and `doctor` become manager-aware and honest under `system`, `fvm`, and `puro`.
- Every CLI command exposes a truthful `--dry-run` mode with zero side effects and predictable output semantics.
- Generated theme architecture supports more than one theme family without rewriting the starter app structure.
- `app_locale_contract` placement is either retained with explicit rationale or moved with a mechanically safer contract; no ambiguous half-state remains.
- `FlavorConfig` is simplified so flavor defaults and env overrides are readable and non-redundant.
- Shared modeled contracts gain a consistent `freezed`-backed surface where technically possible.
- Verification catches docs drift, command drift, and generated app contract drift before release.

## Validation Log

### Session 1 — 2026-04-16
**Trigger:** Validate the remediation plan after drafting the docs/command/theme/contract alignment wave.  
**Questions asked:** 4

#### Questions & Answers

1. **[Assumptions]** How should `--dry-run` behave for read-only commands like `doctor`, `eval`, and `brick list`?
   - Options: A. Print plan only | B. Run safe reads | C. Mutating only
   - **Answer:** A
   - **Rationale:** Dry-run must mean zero execution everywhere. A preview-only contract is stricter, easier to test, and avoids ambiguity about whether read-only commands may still trigger costly or environment-dependent work.

2. **[Scope]** What should the multi-theme rollout ship in v1?
   - Options: A. Architecture only | B. Two starter families | C. Preset-ready surface
   - **Answer:** A
   - **Rationale:** The wave should make the starter structurally ready for multiple families without turning it into a theme-demo product.

3. **[Architecture]** How far should this wave apply `freezed` across shared contracts?
   - Options: A. Failures only | B. Failures plus data contracts | C. Broad consistency
   - **Answer:** C
   - **Rationale:** The shared contract layer should converge on one modeling style where technically possible, even if that broadens codegen usage beyond the original minimal recommendation.

4. **[Scope]** How should `docs/codebase-summary.md` and snapshot-style docs be handled?
   - Options: A. Keep as supporting artifact | B. Keep canonical | C. Delete after merge
   - **Answer:** C
   - **Rationale:** Snapshot-style docs do not belong in the canonical evergreen docs surface once any durable facts have been merged into the right reference docs.

#### Confirmed Decisions

- Dry-run semantics: preview-only, zero execution for read-only and mutating commands alike.
- Multi-theme v1: architecture-ready only, with one bundled default family.
- `freezed` scope: broad consistency across shared contracts where technically possible.
- Snapshot docs: merge useful facts, then delete from canonical root docs.

#### Action Items

- [x] lock preview-only dry-run semantics in command design and tests
- [x] keep theme rollout limited to family-ready architecture, not multiple bundled families
- [x] broaden shared-contract modeling work beyond failures only
- [x] remove `docs/codebase-summary.md` after content merge and reference cleanup

#### Impact on Phases

- Phase 01: merge durable facts out of snapshot docs, then delete snapshot docs from `docs/`.
- Phase 02: implement preview-only dry-run semantics for all commands, including read-only ones.
- Phase 03: stop at theme-family-ready architecture with the default family only.
- Phase 04: broaden `freezed` adoption across shared modeled contracts where technically possible.
- Phase 05: add drift guards for dry-run semantics and absence of deleted snapshot docs.

## Context Reminder

```text
/ck:cook /Users/biendh/base/plans/260416-0913-generator-contract-alignment-multi-theme-and-dry-run/plan.md
```
