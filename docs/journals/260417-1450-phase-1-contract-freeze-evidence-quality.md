---
title: Phase 1 Contract Freeze: Evidence Quality and Default App Matrix
date: 2026-04-17 14:50
severity: Medium
component: Harness contract, generated-project validation, manifest parsing
status: Resolved
---

## Context

Phase 1 of the contract-freeze slice locked the default-app service matrix and tightened the contract vocabulary around the thin-base vs golden-path split. The goal was to stop drift across docs, code, tests, and template evidence surfaces before the next rollout wave.

## What Happened

Added `docs/15-default-app-service-matrix.md`, renamed `observability` to `evidence_quality` across the contract surfaces, and synchronized the roadmap, changelog, and phase status. The generated-project validator now enforces canonical quality dimensions and rejects secret-like values in approvals and SDK policy inputs. Manifest parsing also normalizes stale dimensions at load time so old data does not leak through as a fresh contract shape.

## Reflection

The work was necessary because the contract was already starting to fork in small ways. That is exactly how generator systems rot: one stale name in a template, one permissive parser, and suddenly downstream output looks valid while being semantically wrong. The annoying part is that this was not a hard technical problem; it was discipline. We should have frozen the vocabulary earlier.

## Decisions

Kept the public surface strict instead of adding compatibility aliases for `observability`. Rejected letting manifest parse-time drift pass through untouched, because that just pushes the bug downstream. Chose to normalize stale dimensions at the boundary and fail validation on noncanonical quality input, even though that is less forgiving for old or sloppy callers.

## Next

Targeted `dart analyze --fatal-infos` and the focused generator/config tests passed. The full `dart test` run was blocked by disk exhaustion on this machine, so the remaining work is to rerun the full suite in a less constrained environment and keep the phase-1 freeze from regressing.

Unresolved questions: none.
