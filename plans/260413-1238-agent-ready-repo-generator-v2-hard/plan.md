---
title: "Agent-Ready Repo Generator V2 Hard Plan"
description: "Reposition agentic_base into a generator for agent-ready repositories with canonical context, deterministic harnesses, and honest verify/release contracts."
status: completed
priority: P0
effort: 55-75h
branch: main
tags: [feature, architecture, generator, agents, infra]
blockedBy: []
blocks: []
created: 2026-04-13
---

# Agent-Ready Repo Generator V2 Hard Plan

## Overview

Reposition `agentic_base` away from "AI-flavored template generator" and into "generator for agent-ready repos". The output repo must let external agents understand context, execute deterministic workflows, verify correctness, and prepare releases with low ambiguity. Human stays on product decisions, credentials, and release approval.

## Inputs

- [Agent Engineering Patterns](./research/researcher-01-agent-engineering-patterns.md)
- [Current Repo Gap Analysis](./research/researcher-02-current-repo-gap-analysis.md)
- [Red Team Review](./reports/red-team-review.md)
- Supersedes [260413-1157-agent-ready-repo-generator-v2](../260413-1157-agent-ready-repo-generator-v2/plan.md), now cancelled.
- Completed context:
  - [260409-1140-agentic-base-implementation](../260409-1140-agentic-base-implementation/plan.md)
  - [260410-0859-default-generated-app-architecture-refresh](../260410-0859-default-generated-app-architecture-refresh/plan.md)
  - [260410-1026-dual-github-gitlab-cicd-selection](../260410-1026-dual-github-gitlab-cicd-selection/plan.md)
  - [260410-1755-generator-contract-hardening-and-parity](../260410-1755-generator-contract-hardening-and-parity/plan.md)

## Scope Challenge

- Existing code: generator core, `.info/agentic.yaml`, smoke tests, docs, CI-provider selection, and module registry already exist; do not rebuild them.
- Minimum change set: reset product contract, add canonical context + harness scripts, harden validation/runtime seams, then add migration + metrics.
- Complexity: hot files exceed 8 and cross CLI/generator/template/docs/test surfaces; a multi-phase plan is justified.
- Selected mode: HOLD SCOPE. No spec DSL, no embedded LLM runtime, no multi-agent product.

## Locked Decisions

- Keep existing command names: `create`, `init`, `feature`, `add/remove`, `gen`, `eval`, `deploy`, `upgrade`.
- `feature` stays scaffold-only. It is not the center of the product.
- Do not ship `feature --discover` or universal `feature --spec`.
- Do not embed an LLM runtime or internal agent orchestrator inside `agentic_base`.
- One canonical context source feeds thin vendor adapters.
- Deterministic local scripts and contract tests outrank richer prose.

## Phases

| Phase | Name | Status | Depends on |
| --- | --- | --- | --- |
| 1 | [Reset Product Contract And Canonical Repo Schema](./phase-01-reset-product-contract-and-canonical-repo-schema.md) | Completed | None |
| 2 | [Generate Canonical Agent Context And Thin Adapters](./phase-02-generate-canonical-agent-context-and-thin-adapters.md) | Completed | Phase 01 |
| 3 | [Ship Deterministic Execution Harness And Verify Ladder](./phase-03-ship-deterministic-execution-harness-and-verify-ladder.md) | Completed | Phases 01-02 |
| 4 | [Make CI Release And Runtime Integrations Honest](./phase-04-make-ci-release-and-runtime-integrations-honest.md) | Completed | Phases 01-03 |
| 5 | [Add Safe Upgrade Path And Success Metrics](./phase-05-add-safe-upgrade-path-and-success-metrics.md) | Completed | Phases 01-04 |

## Dependency Graph

- Phase 01 blocks all later work because the product promise and canonical schema define the rest.
- Phase 02 depends on Phase 01 because adapters cannot be generated before the canonical source exists.
- Phase 03 depends on Phases 01-02 because scripts and verify contracts consume the new schema and docs.
- Phase 04 depends on Phases 01-03 because CI/release/runtime hardening must wrap the final harness contract.
- Phase 05 runs last because upgrade safety and metrics need the stable v2 contract.

## Success Gates

- Generated repo has one canonical context contract plus thin vendor adapters.
- Generated repo ships deterministic `setup`, `run`, `verify`, `build`, and `release-preflight` entrypoints.
- CI templates and release surfaces are real and regression-tested, not placeholders.
- Firebase-backed modules are runnable by default or fail fast with explicit setup gaps.
- Existing generated apps can adopt v2 through `upgrade` without rewriting user-owned app logic.

## Non-Goals

- Universal feature generation from ambiguous prompts.
- Embedded agent runtime inside `agentic_base`.
- Replacing product discovery/human decision checkpoints or supporting every external agent surface in v1.

## Validation Log

### Session 1 — 2026-04-13
**Trigger:** User requested validate interview for the plan before implementation.
**Questions asked:** 4

#### Questions & Answers

1. **[Architecture]** Canonical source of truth cho generated agent context nên là gì?
   - Options: `.info/agentic.yaml` giữ machine-readable schema, generated `docs/` giữ canonical human-readable context, `AGENTS.md`/`CLAUDE.md` chỉ là thin adapters | `docs/` là source of truth chính, YAML chỉ là metadata phụ | `.info/agentic.yaml` là source of truth gần như toàn bộ, docs chỉ tóm tắt
   - **Answer:** Option A
   - **Rationale:** Khóa rõ boundary giữa machine-readable contract và human-readable context. Tránh nhồi toàn bộ repo knowledge vào YAML.

2. **[Scope]** V1 nên support adapter surfaces tới đâu?
   - Options: Chỉ `AGENTS.md` + `CLAUDE.md`, các surface khác để phase sau | Thêm luôn một adapter nữa như Copilot instructions trong v1 | Support rộng ngay nhiều surface từ đầu
   - **Answer:** Option A
   - **Rationale:** Giữ scope hẹp, giảm drift, giảm chi phí maintain cho v1.

3. **[Tradeoff]** Boundary đúng của release automation trong v1 là gì?
   - Options: `release-preflight` + build/upload plumbing + credential checks; human vẫn duyệt bước publish/store release cuối | Tự động hết cho dev/staging/internal beta, còn prod publish vẫn manual | Tự động toàn bộ kể cả prod publish
   - **Answer:** Option A
   - **Rationale:** Giữ execution agent-owned nhưng không vượt qua boundary approval và compliance của store release.

4. **[Risk]** `upgrade` được phép rewrite tới mức nào?
   - Options: Chỉ generator-owned files: docs, scripts, metadata, CI/release surfaces; app code không tự động rewrite | Ngoài các file trên, cho phép rewrite cả bootstrap/module integration nếu contract đổi | Full sync với template mới, kể cả app-layer files
   - **Answer:** Option A
   - **Rationale:** Giữ migration an toàn. Tránh phá user-owned app logic trong các repo đã generate trước đó.

#### Confirmed Decisions

- Canonical context split: `.info/agentic.yaml` machine-readable, generated `docs/` canonical human-readable, `AGENTS.md`/`CLAUDE.md` thin adapters.
- Adapter scope v1: chỉ `AGENTS.md` và `CLAUDE.md`.
- Release boundary v1: agent chuẩn bị preflight/build/upload plumbing; human giữ approval publish/store release cuối.
- Upgrade boundary v1: chỉ rewrite generator-owned files.

#### Action Items

- [x] Phase 01 khóa schema split YAML/docs/adapters thật rõ.
- [x] Phase 02 giới hạn adapter scope v1 ở `AGENTS.md` và `CLAUDE.md`.
- [x] Phase 04 ghi rõ release boundary human approval ở final publish/store release.
- [x] Phase 05 khóa upgrade boundary ở generator-owned files only.

### Session 2 — 2026-04-13
**Trigger:** Implementation, validation, and sync-back completed.

#### Outcome

- All five phases implemented in the package and app brick.
- Local repo verification passed: `dart analyze`, targeted upgrade regression test, and full `dart test`.
- `my_app` refreshed through the real `upgrade` path, then `./tools/verify.sh` passed through codegen, analyze, tests, and iOS simulator build.
- Found and fixed one late regression: upgrade sync dropped executable bits on `tools/*.sh`.

#### Notes

- External tester/reviewer subagents could not complete because the session hit the platform usage limit.
- Final validation was completed locally instead.

#### Impact on Phases

- Phase 01: cập nhật Requirements và Architecture để xác nhận split canonical context.
- Phase 02: giới hạn scope adapter v1 và cấm mở rộng surface sớm.
- Phase 04: siết release boundary ở mức preflight/build/upload plumbing, không auto publish cuối.
- Phase 05: siết rewrite boundary của `upgrade`.
