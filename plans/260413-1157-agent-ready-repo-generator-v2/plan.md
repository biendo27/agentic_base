---
title: "Agent-Ready Repo Generator V2"
description: "Reposition agentic_base from a Flutter scaffold generator with agentic branding into a generator for agent-ready repositories."
status: cancelled
priority: P0
effort: 40-60h
branch: main
tags: [proposal, architecture, generator, agents]
created: 2026-04-13
blockedBy: []
blocks: []
---

# Agent-Ready Repo Generator V2

## Overview

Pivot `agentic_base` from "template generator with agentic claims" to "generator for agent-ready repos". The core product is not feature-spec generation or embedded AI orchestration. The core product is a repo that external agents can understand, execute, verify, and release with low ambiguity and high trust.

Superseded by the harder, research-backed rewrite in [260413-1238-agent-ready-repo-generator-v2-hard](../260413-1238-agent-ready-repo-generator-v2-hard/plan.md).

## Why This Pivot

- Real product work is ambiguous; universal feature-spec generation is brittle.
- The current repo already proves create/init/module scaffolding works, but the public contract overclaims agent readiness.
- The main gaps are contract gaps: broken CI template rendering, placeholder release flows, partial runtime integrations, and weak verify semantics.
- Current best practice converges on the same direction: humans steer, agents execute; repos need harnesses, docs, tools, and eval loops.

## Locked Decisions

- Keep `create`, `init`, `feature`, `add/remove`, `gen`, `eval`, and `deploy`.
- Keep `feature` as scaffold convenience, not the center of the product.
- Do not embed an LLM runtime in `agentic_base`.
- Optimize for compatibility with Codex, Copilot, Cursor, Claude Code, Aider, and MCP-based agents.
- Prefer deterministic scripts and machine-readable contracts over natural-language magic.

## Phases

| Phase | Name | Status | Outcome |
| --- | --- | --- | --- |
| 1 | [Reset Product Contract And Command Surface](./phase-01-reset-product-contract-and-command-surface.md) | Proposed | Honest product positioning and one canonical repo contract |
| 2 | [Generate Agent Context And Execution Harness](./phase-02-generate-agent-context-and-execution-harness.md) | Proposed | Repos ship clear docs, scripts, machine-readable metadata, and vendor adapters |
| 3 | [Turn Verification And Release Into First-Class Contracts](./phase-03-turn-verification-and-release-into-first-class-contracts.md) | Proposed | Verify ladder and real release automation for Firebase/TestFlight/Play/App Store |
| 4 | [Close The Loop With Compatibility, Migration, And Metrics](./phase-04-close-the-loop-with-compatibility-migration-and-metrics.md) | Proposed | Upgrade path, external-agent compatibility, and measurable success criteria |

## Dependency Graph

- Phase 1 blocks everything else.
- Phase 2 depends on Phase 1.
- Phase 3 depends on Phases 1-2.
- Phase 4 depends on Phases 1-3.
- Sequential execution is preferred; these phases all touch the same CLI, templates, docs, and generated-project contract.

## Success Gates

- Generated repo has one canonical agent context source plus vendor-specific thin adapters.
- Generated repo ships deterministic setup/run/verify/build/release entrypoints that agents can call directly.
- Generated CI and release surfaces are real contracts, not TODO placeholders.
- Generated module integrations are runnable by default or fail fast with explicit missing config.
- A fresh generated app can be taken from zero to local verify and pre-release validation without human code edits.
- Human responsibilities are explicit and narrow: product decisions, secrets, app-store approval, and release approval.

## Non-Goals

- Universal feature generation from ambiguous prompts.
- Built-in multi-agent orchestration runtime inside `agentic_base`.
- Replacing product discovery, UX direction, or business-rule ownership.
- Covering every possible app architecture in v2.

## References

- [`README.md`](../../README.md)
- [`docs/04-system-architecture.md`](../../docs/04-system-architecture.md)
- [`docs/05-project-roadmap.md`](../../docs/05-project-roadmap.md)
- [`plans/260410-1755-generator-contract-hardening-and-parity/plan.md`](../260410-1755-generator-contract-hardening-and-parity/plan.md)
