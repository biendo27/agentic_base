---
title: "Red Team Review - Agent-Ready Repo Generator V2 Hard Plan"
date: 2026-04-13
status: final
---

# Red Team Review - Agent-Ready Repo Generator V2 Hard Plan

## Summary

The direction is sound. Main risk is overbuilding adapter and release infrastructure before tightening the core contract.

## Findings

1. Biggest trap: building too many vendor-specific instruction files too early.
   - Fix: one canonical source first, thin adapters only for currently supported surfaces.
2. Biggest scope bomb: full store automation can swallow the plan.
   - Fix: separate `release-preflight` from `release-execute`; human approval and credentials stay outside repo automation.
3. Biggest migration risk: `upgrade` rewriting user-owned code.
   - Fix: v1 upgrade must only touch generator-owned docs, scripts, metadata, and CI/release surfaces.
4. Biggest credibility risk: marketing pivot without contract tests.
   - Fix: every new promise in docs must map to a contract assertion or smoke test.
5. Biggest architecture risk: turning `agentic_base` into an agent platform.
   - Fix: keep it a generator package; external agents remain outside the product boundary.

## Corrections Applied To Plan

1. Keep `feature` scaffold-only.
2. Split execution harness from release execution.
3. Put migration safety in a dedicated late phase.
4. Make contract-test coverage explicit in every phase.

## Recommendation

Proceed. Scope is acceptable if sequence stays strict and vendor-specific expansion is limited.

## Unresolved Questions

None.
