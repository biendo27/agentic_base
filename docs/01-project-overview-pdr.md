# 01. Project Overview PDR

## Overview

This repository is the `agentic_base` package root.

`agentic_base` is a Dart CLI that scaffolds Flutter codebases for AI-agent-heavy teams. Its job is to create opinionated project structure, apply Mason templates, manage installable modules, and keep project state in `.info/agentic.yaml`.

## Problem

Flutter teams keep rebuilding the same setup:

- project bootstrap
- feature folder structure
- state management wiring
- module integration
- agent instructions and docs
- repeated validate/analyze/test loops

Manual setup is slow, inconsistent, and hard for coding agents to navigate.

## Target Users

- Flutter teams starting greenfield apps
- teams retrofitting existing Flutter apps with agentic conventions via `init`
- maintainers extending a reusable starter with bricks and modules

## Product Goals

- generate a usable Flutter starter from one CLI command
- support multiple state-management choices: `cubit`, `riverpod`, `mobx`
- scaffold features from a standard brick
- add and remove installable modules without hand-editing `pubspec.yaml`
- preserve project state in `.info/agentic.yaml`
- keep generated projects analyzable and testable after generation

## Non-Goals

- provide runtime services for generated apps inside this package
- auto-provision Firebase, AdMob, maps, store, or platform secrets
- perform AST-aware refactors inside user projects
- provide end-to-end release automation for this repo today

## Functional Scope Today

| Area | Verified behavior |
| --- | --- |
| CLI runtime | `AgenticBaseCliRunner` registers 11 commands plus top-level `--version`. |
| Project creation | `create` runs `flutter create`, overlays the `agentic_app` brick, writes `.info/agentic.yaml`, optionally installs modules, then runs codegen, lint fixes, analyze, and tests. |
| Feature scaffolding | `feature` applies the `agentic_feature` brick into an initialized project. |
| Module management | `add` and `remove` use `ModuleRegistry` and `ModuleInstaller` to mutate `pubspec.yaml`, write files, and update `.info/agentic.yaml`. |
| Project maintenance | `gen`, `doctor`, `eval`, `upgrade`, `init`, and `deploy` wrap common lifecycle tasks. |
| Templates | App and feature bricks live under `bricks/`. |
| Repo CI | Current GitHub Actions CI runs analyze, format check, and tests for the package itself. |

## Non-Functional Requirements

- generated projects should pass `dart analyze` and `flutter test` after bootstrap
- commands should fail early on invalid args or missing project state
- `init` should be non-destructive for existing projects
- `create` should clean up partial output on failure
- YAML edits should preserve formatting via `yaml_edit`
- docs should explain the repo truthfully, including missing automation and current gaps

## Current Constraints And Gaps

- public README copy says "25" modules, but `ModuleRegistry` currently exposes 27 modules
- `deploy` expects `cd-<env>.yml` workflows in the target project, but no such workflows are checked into this repo
- several Dart files exceed the repo's 200 LOC target, mostly command and orchestration files
- package CI is present; release automation is not

## Success Criteria

- a new maintainer can find the product purpose, architecture, and workflow from `docs/`
- command, generator, brick, module, and test responsibilities are easy to locate
- deployment docs do not imply automation that is not actually present
- roadmap reflects both completed implementation phases and current hardening work

## References

- [`README.md`](../README.md)
- [`pubspec.yaml`](../pubspec.yaml)
- [`plans/260409-1140-agentic-base-implementation/plan.md`](../plans/260409-1140-agentic-base-implementation/plan.md)
- [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)
