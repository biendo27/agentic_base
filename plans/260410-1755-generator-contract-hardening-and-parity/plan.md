---
title: "Generator Contract Hardening and Full Scaffold Parity"
description: "Harden create/init/module flows so the public generator contract is honest, reproducible, transactional, and state-complete."
status: completed
priority: P1
effort: 34h
branch: main
tags: [hardening, generator, scaffold, state-management, modules]
created: 2026-04-10
blockedBy: []
blocks: []
---

# Generator Contract Hardening and Full Scaffold Parity

## Overview

Follow-up to completed generator/app-contract work. This plan is now complete: typed metadata/provenance, safe `init` analysis setup, transactional module journaling, multi-state parity, working module seams, analytics integration, and expanded verification are all implemented.

## Inputs

- [Multi-State Scaffold Parity Research](../reports/researcher-260410-1743-multi-state-scaffold-parity.md)
- [Init / Module Contract Hardening Research](../reports/researcher-260410-1744-init-module-contract-hardening.md)
- Completed context plans:
  - [260409-1140-agentic-base-implementation](../260409-1140-agentic-base-implementation/plan.md)
  - [260410-0859-default-generated-app-architecture-refresh](../260410-0859-default-generated-app-architecture-refresh/plan.md)
  - [260410-1026-dual-github-gitlab-cicd-selection](../260410-1026-dual-github-gitlab-cicd-selection/plan.md)

## Locked Decisions

- Keep current user-facing commands and flags. No surface reduction.
- Keep one app brick and one feature brick; branch via internal state profiles and Mason conditionals, not three brick families.
- `init` may persist defaults only when evidence is missing, but every such value must record provenance. No fabricated inference.
- `analysis_options.yaml` must be self-contained unless its external include dependency/setup contract already exists.
- Module install/remove work must be journaled. Config is committed only after file/pubspec/bootstrap mutations succeed.
- Execution mode is sequential. Shared hot files make parallel edits unsafe until Phase 2 is complete.

## Dependency Graph

- Phase 01 blocks everything else.
- Phase 02 depends on Phase 01.
- Phase 03 depends on Phases 01-02.
- Phase 04 depends on Phases 01-02.
- Phase 05 depends on Phases 01-03.
- Phase 06 depends on Phases 01-05.

## Phases

| Phase | Name | Status | Depends on |
| --- | --- | --- | --- |
| 1 | [Lock Canonical Contract Model](./phase-01-lock-canonical-contract-model.md) | Completed | None |
| 2 | [Add Transactional Project Mutations](./phase-02-add-transactional-project-mutations.md) | Completed | Phase 01 |
| 3 | [Implement Full Multi-State Scaffold Parity](./phase-03-implement-full-multi-state-scaffold-parity.md) | Completed | Phases 01-02 |
| 4 | [Make Init Honest And Safe](./phase-04-make-init-honest-and-safe.md) | Completed | Phases 01-02 |
| 5 | [Turn Modules Into Working Integrations](./phase-05-turn-modules-into-working-integrations.md) | Completed | Phases 01-03 |
| 6 | [Close The Loop With Verification And Docs](./phase-06-close-the-loop-with-verification-and-docs.md) | Completed | Phases 01-05 |

## Success Gates

- `create` for each supported state now yields analyzable, testable apps that match state-specific contract expectations.
- Injected module failure during `create`, `add`, or `remove` now rolls back cleanly with no partial config, half-written bootstrap hooks, or stale module files.
- `init` retrofit fixtures now persist provenance-backed metadata and avoid unsafe analyzer includes.
- Installed modules now alter live bootstrap/DI seams and remain removable without orphaned registrations.
- CI keeps provider coverage, state coverage, and native validation separate to avoid a noisy matrix explosion.

## Verification

- Expanded automated coverage now spans config/provenance, init retrofit, add/remove journaling, state parity, feature parity, analytics wiring, and generated-app smoke tests.
- Verification covered cubit, riverpod, and mobx scaffold paths plus module integration behavior.

## Residual Risks

- Future state branches must keep the generated contract and smoke checks updated.
- Any new mutation class must be added to the journal before commit.
- Legacy `.info/agentic.yaml` readers still need to honor the typed schema path.
- Future docs or roadmap changes must stay aligned with the generated contract.
