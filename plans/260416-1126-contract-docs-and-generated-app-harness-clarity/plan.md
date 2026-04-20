---
title: "Contract Docs, Generated App Harness Clarity, and Agentic Core Gitflow"
description: "Remove remaining contract drift, prune redundant docs, clarify the generated harness workflow, tighten shared contract modeling in the app brick, and decide how generated agentic-core surfaces should carry Gitflow."
status: completed
priority: P0
effort: 26-38h
branch: develop
tags: [planning, docs, generator, flutter, contracts, harness]
blockedBy: []
blocks: []
created: 2026-04-16
---

# Contract Docs and Generated App Harness Clarity

## Overview

This plan closes the remaining gap between what `agentic_base` claims, what generated repos teach agents to do, and how shared contracts are shaped inside `agentic_app`. Scope includes root-doc truthfulness, generated-doc compression, manager-aware testing guidance, a clearer Harness Engineer development-flow narrative, a deliberate review of `lib/core/contracts` against the external `meup` references, alignment with the repo's new classic Gitflow guardrails, and an explicit decision on whether generated agentic-core surfaces should inherit that Gitflow model.

## Cross-Plan Dependencies

No active blockers. This plan follows completed work and fixes the remaining drift left after:

- [260416-0913-generator-contract-alignment-multi-theme-and-dry-run](../260416-0913-generator-contract-alignment-multi-theme-and-dry-run/plan.md)
- [260415-0946-generated-app-brick-hardening-and-theme-refresh](../260415-0946-generated-app-brick-hardening-and-theme-refresh/plan.md)

## Scope Challenge

- Do not treat docs cleanup as copy editing only; it must change the canonical context shape agents rely on.
- Do not cargo-cult `meup` request/response models. Borrow good patterns only when they fit the scaffold contract and remain runtime-agnostic.
- Do not spread `library` + `part` across normal app files; decide explicitly whether `lib/core/contracts` is cohesive enough to justify that packaging.
- Do not hide Harness Engineer flow across too many files. Generated repos need a finite path agents can follow end to end.
- Do not let doc cleanup drift away from the repo's real Gitflow automation and PR-routing guardrails.
- Do not silently project repo-specific Gitflow policy onto downstream generated repos without locking whether that policy is universal, recommended, or optional.
- Selected mode: HARD, CONTRACT-TRUTH FIRST.

## Inputs

- [research-summary.md](./research/research-summary.md)
- [scout-report.md](./reports/scout-report.md)
- [red-team-review.md](./reports/red-team-review.md)
- review findings from the current thread

## Phases

| Phase | Name | Status |
| --- | --- | --- |
| 1 | [Rationalize Root Contract Docs and Remove Redundant Canonical Surface](./phase-01-rationalize-root-contract-docs-and-remove-redundant-canonical-surface.md) | Completed |
| 2 | [Re-layer Generated App Docs for Agentic Harness Workflow Clarity](./phase-02-re-layer-generated-app-docs-for-agentic-harness-workflow-clarity.md) | Completed |
| 3 | [Rework Shared Contract Modeling with Meup-Informed Boundaries](./phase-03-rework-shared-contract-modeling-with-meup-informed-boundaries.md) | Completed |
| 4 | [Propagate Contract and Command Guidance Across the Generated Surface](./phase-04-propagate-contract-and-command-guidance-across-the-generated-surface.md) | Completed |
| 5 | [Add Drift Guards, Verification, and Final Docs Sync](./phase-05-add-drift-guards-verification-and-final-docs-sync.md) | Completed |

## Dependency Graph

- Phase 01 and Phase 02 can start from the same research package but should land together.
- Phase 03 must lock the contract-package policy before Phase 04 rewires docs/examples/tests around it.
- Phase 05 validates all earlier phases and becomes the release gate.

## Success Criteria

- Root `README.md` and `docs/08-13` tell one truthful, non-future-tense contract story.
- Generated `README.md` and `docs/` become smaller, less repetitive, and explicitly teach the harness development flow.
- Generated testing docs stop teaching bare `flutter test` when manager-aware surfaces exist.
- `lib/core/contracts` has a documented, tested policy for model shape, request/response scope, and method-vs-extension placement.
- The final repo can honestly claim that agents have one finite canonical context for both repo-level and generated-app-level work.
- Root docs stay aligned with the actual Gitflow workflows and guardrails checked into `.github/workflows/`.
- Generated agentic-core docs/adapters either inherit Gitflow deliberately or stay explicitly repo-agnostic; no half-implied branch policy remains.

## Validation Log

- 2026-04-16
- Keep [`docs/02-codebase-summary.md`](../../docs/02-codebase-summary.md) in the canonical surface for now.
- Keep `lib/core/contracts` file-per-contract for now; only move to `base.dart` + `part` if the final package proves cohesive enough.
- Keep any base multi-language model runtime-agnostic; locale-aware selection must live in an extension or service outside raw core contracts.
- Add a dedicated generated-app workflow doc for the Harness Engineer development loop and point generated entrypoints toward it.
- Downstream Gitflow is a recommended default workflow, not a universal harness law.
- Downstream Gitflow lives in human-readable docs and thin adapters only, not `.info/agentic.yaml`.
- If downstream Gitflow automation lands in this wave, implement it for GitHub-generated repos only; GitLab stays docs-only for now.
- `AGENTS.md` and `CLAUDE.md` should carry a brief Gitflow summary plus a pointer to the dedicated workflow doc.
- Root docs were rewritten to remove future-wave wording and keep the canonical surface finite and truthful.
- Generated app docs now point agents toward `docs/07-agentic-development-flow.md`, manager-aware test wrappers, and recommended-default Gitflow guidance.
- Generated shared contracts now include richer response, pagination, and runtime-agnostic localized text models with dedicated regression tests.
- Added drift guards in generator validation, smoke assertions, and root-doc tests for command guidance and Gitflow wording.
- `dart analyze --fatal-infos` passed.
- Targeted regressions passed: `test/src/config/agentic_config_test.dart`, `test/src/generators/project_generator_test.dart`, `test/src/docs/harness_contract_documentation_test.dart`, `test/integration/generated_app_smoke_test.dart`.
- Full `dart test -r compact` passed.
