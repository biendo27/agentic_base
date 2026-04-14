---
title: "Agent-Ready Repo Generator Trust Repair"
description: "Close the post-v2 trust gaps so init/create outputs, release surfaces, runtime integrations, and public claims all match executable reality."
status: proposed
priority: P0
effort: 24-36h
branch: main
tags: [hardening, generator, agents, release, runtime]
blockedBy: []
blocks: []
created: 2026-04-13
---

# Agent-Ready Repo Generator Trust Repair

## Overview

Follow-up repair plan for the already-shipped v2 contract. The current repo still overclaims agent-readiness in `init`, GitLab deploy, dependency determinism, and some runtime module integrations. This plan closes those gaps so the product promise is backed by generated output, local scripts, and regression tests.

## Inputs

- [Review findings snapshot](./reports/agent-ready-review-findings.md)
- [Agent-Ready Repo Generator V2 Hard Plan](../260413-1238-agent-ready-repo-generator-v2-hard/plan.md)
- [`README.md`](../../README.md)
- [`docs/04-system-architecture.md`](../../docs/04-system-architecture.md)
- [`docs/05-project-roadmap.md`](../../docs/05-project-roadmap.md)

## Scope Challenge

- This is not another repo-generator redesign. It is a trust repair pass on claims that were already shipped.
- Fix only what blocks honest agent-readiness: contract truth, deterministic execution, real runtime seams, and evidence-backed docs.
- Do not add new adapter surfaces, speculative agent features, or app-layer auto-rewrites.

## Locked Decisions

- `init` must land on an honest agent-ready contract; no false `.info/agentic.yaml` claims.
- Generated release wrappers must call real provider jobs and local scripts, not synthetic names.
- Module install output must be deterministic across time.
- Runtime modules must either wire fully into bootstrap or fail through explicit preflight/setup checks.
- Public docs may only claim behavior that is proven by code, templates, scripts, or tests.

## Phases

| Phase | Name | Status | Depends on |
| --- | --- | --- | --- |
| 1 | [Repair Init Contract Truth And Canonical Context](./phase-01-repair-init-contract-truth-and-canonical-context.md) | Proposed | None |
| 2 | [Fix GitLab Release Contract And Provider Entrypoints](./phase-02-fix-gitlab-release-contract-and-provider-entrypoints.md) | Proposed | Phase 01 |
| 3 | [Make Module Installation Deterministic And Versioned](./phase-03-make-module-installation-deterministic-and-versioned.md) | Proposed | Phase 01 |
| 4 | [Finish Runtime Bootstrap Integrations And Firebase Seams](./phase-04-finish-runtime-bootstrap-integrations-and-firebase-seams.md) | Proposed | Phases 01-03 |
| 5 | [Add Regression Gates And Resync Product Docs](./phase-05-add-regression-gates-and-resync-product-docs.md) | Proposed | Phases 01-04 |

## Dependency Graph

- Phase 01 is first because every later fix depends on a truthful canonical contract.
- Phase 02 and Phase 03 can proceed after Phase 01 because both consume the repaired contract but touch different risk areas.
- Phase 04 depends on the earlier phases because runtime wiring must respect the final contract and deterministic dependency policy.
- Phase 05 closes the loop with proof and docs only after code behavior is stable.

## Success Gates

- `init` and `create` both produce repos whose `.info/agentic.yaml` matches real files and scripts.
- GitLab deploy paths resolve to real generated jobs and stay covered by regression tests.
- `add` never writes `any`; dependency constraints come from a repo-owned version source.
- Firebase-backed and startup-bound modules become working integrations or explicit preflight failures.
- README, docs, CLI help, metadata, and tests agree on the same product boundary.

## Non-Goals

- Adding Copilot or other new adapter surfaces in v1.
- Shipping embedded LLM orchestration or fuzzy feature synthesis.
- Letting `upgrade` rewrite user-owned app logic automatically.

## Risks

- A shallow fix could narrow docs without fixing runtime reality.
- Runtime hook work can sprawl if module seams stay implicit.
- Tests can still miss drift if they assert strings instead of generated behavior.

## Exit Condition

The repo can only be called an "agent-ready repo generator" after these five phases pass locally, in package CI, and on fresh generated output.
