---
title: "agentic_base — Flutter Agentic Codebase Generator"
description: "Dart CLI tool on pub.dev generating production-ready Flutter codebases optimized for AI-agent-driven development"
status: completed
priority: P1
effort: 250-350h
branch: main
tags: [feature, dart, cli, flutter, pub-dev]
blockedBy: []
blocks: []
created: 2026-04-09
---

# agentic_base Implementation Plan

## Overview

Build `agentic_base` — a Dart CLI tool distributed via pub.dev that generates Flutter codebases optimized for AI coding agents. The tool uses Mason engine for templates, supports 3 state management options (Cubit/Riverpod/MobX), includes 25 built-in modules, and generates CI/CD pipelines.

**Architecture report:** [brainstorm-260409-1103-agentic-base-architecture.md](../reports/brainstorm-260409-1103-agentic-base-architecture.md)

## Cross-Plan Dependencies

None — first plan in this repo.

## Phases

| Phase | Name | Status | Effort |
|-------|------|--------|--------|
| 1 | [Tool Scaffold & Create Command](./phase-01-tool-scaffold-and-create-command.md) | Completed | 30h |
| 2 | [Feature & Module System](./phase-02-feature-and-module-system.md) | Completed | 25h |
| 3 | [Testing & Eval](./phase-03-testing-and-eval.md) | Completed | 15h |
| 4 | [CI/CD & Deploy](./phase-04-cicd-and-deploy.md) | Completed | 15h |
| 5 | [Extended Modules](./phase-05-extended-modules.md) | Completed | 15h |
| 6 | [Multi-State & Bricks](./phase-06-multi-state-and-bricks.md) | Completed | 15h |
| 7 | [Polish & Publish](./phase-07-polish-and-publish.md) | Completed | 10h |

## Dependencies

- Dart SDK 3.7+
- Flutter SDK 3.29+
- Mason CLI (for brick development/testing)
- GitHub account (for CI/CD testing)

## Key Constraints

- YAGNI/KISS/DRY — no speculative abstractions
- Each phase must produce a working tool (incremental delivery)
- Generated projects must `dart analyze` clean + `flutter test` pass
- pub.dev score target: 140+ / 160 points
- Files under 200 LOC each

## Red Team Corrections (2026-04-09)

Critical fixes applied from [red-team-review](./reports/red-team-review.md):

1. **Package fix**: Use `mason` package (MasonGenerator/MasonBundle), NOT `mason_api` (registry client)
2. **pubspec manipulation**: Use `yaml_edit` (preserves formatting), NOT `yaml` (destroys comments)
3. **State-agnostic module contract**: Design in Phase 2 to support Cubit/Riverpod/MobX without refactor
4. **Platform config strategy**: Document-only — module adds Dart code, user follows README for AndroidManifest/Info.plist
5. **Rollback on failure**: Clean up partial output if generation fails mid-process
6. **Add `--no-interactive` flag**: For CI/scripted usage from day 1
7. **Effort re-estimated**: 250-350h realistic (was 120h). User accepts full vision scope.
8. **Template testing**: Every brick needs generate-and-compile integration test in CI
