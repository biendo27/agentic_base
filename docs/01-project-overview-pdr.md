# 01. Project Overview PDR

## Overview

This repository is the `agentic_base` package root.

`agentic_base` is a Dart CLI that generates agent-ready Flutter repositories. It creates opinionated project structure, applies Mason templates, manages installable modules, repairs project metadata, and keeps the generated repo contract in `.info/agentic.yaml`.

## Problem

Flutter teams keep rebuilding the same setup:

- project bootstrap
- feature folder structure
- state management wiring
- module integration
- agent instructions and docs
- repeated validate/analyze/test loops
- metadata repair after partial or legacy initialization

Manual setup is slow, inconsistent, and hard for coding agents to navigate.

## Target Users

- Flutter teams starting greenfield apps
- teams retrofitting existing Flutter apps with agent-ready conventions via `init`
- maintainers extending a reusable starter with bricks and modules

## Product Goals

- generate an agent-ready Flutter repo from one CLI command
- support multiple state-management choices: `cubit`, `riverpod`, `mobx` with scaffold parity
- scaffold features from a standard brick with matching runtime seams
- add and remove installable modules as live integrations, not inert file drops
- preserve project state in `.info/agentic.yaml` with provenance-backed repair
- keep generated repos analyzable, testable, and script-driven after generation

## Non-Goals

- provide an embedded LLM runtime or internal agent orchestrator
- auto-provision Firebase, AdMob, maps, store, or platform secrets
- perform AST-aware refactors inside user projects
- replace human approval for final store publish

## Functional Scope Today

| Area | Verified behavior |
| --- | --- |
| CLI runtime | `AgenticBaseCliRunner` registers 11 commands plus top-level `--version`. |
| Project creation | `create` runs `flutter create`, overlays the `agentic_app` brick, writes `.info/agentic.yaml`, optionally installs modules, then runs codegen, lint fixes, analyze, and tests. |
| Feature scaffolding | `feature` applies the `agentic_feature` brick into an initialized project using the selected state profile. |
| State parity | `cubit`, `riverpod`, and `mobx` all scaffold matching app and feature output with no foreign runtime leftovers. |
| Module management | `add` and `remove` use `ModuleRegistry`, `ModuleInstaller`, `ProjectMutationJournal`, and `ModuleIntegrationGenerator` to mutate `pubspec.yaml`, write files, refresh bootstrap/provider registries, and update `.info/agentic.yaml`. |
| Metadata repair | `init` infers project name, org, CI provider, platforms, flavors, and state management from project files when possible, then repairs or seeds `.info/agentic.yaml` with provenance. |
| Module integrations | `analytics` is a live integration that writes the service contract, Firebase implementation, and generated DI wiring verified by smoke tests. |
| Project maintenance | `gen`, `doctor`, `eval`, `upgrade`, `init`, and `deploy` wrap common lifecycle tasks plus generator-owned repo upgrades. |
| Templates | App and feature bricks live under `bricks/`. |
| Repo CI | Current GitHub Actions CI runs analyze, format check, package tests, generated-app smoke coverage, and a pinned macOS native gate. |

## Non-Functional Requirements

- generated projects should pass `dart analyze` and `flutter test` after bootstrap
- commands should fail early on invalid args or missing project state
- `init` should be non-destructive for existing projects and should not fabricate provenance when evidence is missing
- `create` should clean up partial output on failure
- YAML edits should preserve formatting via `yaml_edit`
- module mutations should roll back cleanly if any install/remove step fails
- docs should explain the repo truthfully, including the human approval boundary and current gaps

## Current Constraints And Gaps

- generated repos now ship shared setup/run/verify/build/release-preflight surfaces, but final production publish stays human-approved
- several Dart files exceed the repo's 200 LOC target, mostly command and orchestration files
- package CI is present; release automation is not
- docs and README must stay aligned as the module catalog and generator contract evolve

## Success Criteria

- a new maintainer can find the repo contract, architecture, and workflow from `docs/`
- command, generator, brick, module, metadata, and test responsibilities are easy to locate
- deployment docs do not imply automation that is not actually present
- roadmap reflects completed generator hardening and remaining delivery work

## References

- [`README.md`](../README.md)
- [`docs/codebase-summary.md`](./codebase-summary.md)
- [`pubspec.yaml`](../pubspec.yaml)
- [`plans/260409-1140-agentic-base-implementation/plan.md`](../plans/260409-1140-agentic-base-implementation/plan.md)
- [`plans/260410-1755-generator-contract-hardening-and-parity/plan.md`](../plans/260410-1755-generator-contract-hardening-and-parity/plan.md)
- [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)
