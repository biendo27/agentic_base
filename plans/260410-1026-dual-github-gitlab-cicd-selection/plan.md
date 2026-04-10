---
title: "Dual GitHub/GitLab CI/CD Selection"
description: "Add a single-provider CI/CD contract for generated projects while keeping deploy flow stable."
status: completed
priority: P2
effort: 12h
branch: main
tags: [cicd, github, gitlab, generator]
created: 2026-04-10
blockedBy: []
blocks: []
---

# Dual GitHub/GitLab CI/CD Selection

## Scope
- Add one persisted `ci_provider` contract for generated and initialized projects.
- Let app scaffolding emit exactly one CI provider: `github` or `gitlab`.
- Keep `agentic_base deploy <dev|staging|prod>` as the user-facing deploy entrypoint.
- Add an explicit macOS-native validation gate so iOS flavor regressions are enforced in CI, not only locally.
- Update docs and tests so provider choice and native validation requirements are explicit and verifiable.

## Recommended Approach
- Store provider choice in `.info/agentic.yaml` as `ci_provider`.
- Add `--ci-provider github|gitlab` to `create` and `init`, default `github`.
- Make the app brick emit provider-exclusive CI files: existing `.github/workflows/*.yml` or root `.gitlab-ci.yml` plus included files under `.gitlab/ci/*.yml`, never both.
- Refactor `deploy` into provider-aware execution behind the same CLI contract: `gh workflow run cd-<env>.yml` for GitHub, GitLab CLI pipeline trigger for GitLab.
- Reuse existing generated-project `tools/*.sh` scripts inside both provider templates to avoid two build/deploy contracts.
- Organize GitLab CI with root `.gitlab-ci.yml` as the bootstrap entrypoint and `include: local` files under `.gitlab/ci/*.yml`, mirroring `.github/workflows/` while keeping the generated project self-bootstrapping.
- GitHub remains the repo automation host for `agentic_base`, but root CI must add a required pinned macOS job that fresh-generates an app and runs `./tools/ci-check.sh`.
- GitLab-generated projects must ship a macOS-native validation contract that clearly requires a macOS runner, shell executor, Xcode, and `macos` tag; Linux runners are Dart-only, not native-validation fallback.
- For GitLab v1, prefer explicit manual per-environment deploy jobs over pipeline-variable-selected deploys.
- Do not rely on custom GitLab CI config-path settings outside the repo; generated projects must work with the default root `.gitlab-ci.yml` entrypoint.
- Do not consider provider/deploy support complete until the root GitHub macOS generated-app check is merged, always runs on `pull_request` and `push`, and is configured as a required status check for `main`.

## Phase Plan
| Phase | Status | Effort | Depends on | Output |
| --- | --- | ---: | --- | --- |
| [01. Provider Selection Contract](./phase-01-provider-selection-contract.md) | Completed | 3h | None | CLI/config/brick contract for one CI provider |
| [02. Provider-Specific Scaffold And Deploy](./phase-02-provider-specific-scaffold-and-deploy.md) | Completed | 5h | Phase 01 | Exclusive GitHub/GitLab templates, macOS-native provider contracts, and provider-aware deploy |
| [03. Tests, Docs, And Validation](./phase-03-tests-docs-and-validation.md) | Completed | 4h | Phase 02 | Coverage, smoke validation, root macOS CI gate, and docs reconciliation |

## Data Flow
1. User runs `create` or `init` with optional `--ci-provider`.
2. CLI validates provider and passes one normalized value downstream.
3. `AgenticConfig` persists `ci_provider` into `.info/agentic.yaml`.
4. Mason brick uses the provider value to emit only the matching CI files.
5. Provider CI definitions call shared project scripts, with native validation delegated to `./tools/ci-check.sh`.
6. `deploy <env>` reads `ci_provider`, validates provider-specific CLI/auth, then triggers the matching remote pipeline or workflow.
7. Tests and CI assert the generated project contains one provider contract only and that macOS-native validation is enforced where required.

## Dependency Graph
- Phase 01 blocks every later step because provider persistence is the root contract.
- Phase 02 depends on Phase 01 because template emission and deploy routing need stored provider state.
- Phase 03 depends on Phase 02 because tests/docs must validate the final scaffold and deploy contract.
- Parallelism not recommended; shared surfaces (`create`, `init`, config, brick, deploy) make sequential delivery lower risk.

## Backwards Compatibility
- Existing projects with no `ci_provider` remain deployable via legacy GitHub fallback.
- New scaffolds default to `github` when provider is omitted.
- `deploy` command name and environment contract stay unchanged.
- Root package CI stays on GitHub, but it no longer remains Ubuntu-only; required macOS validation becomes part of the repo contract.
- Generated-project GitLab support is validated from package tests and generated root `.gitlab-ci.yml` plus `.gitlab/ci/*.yml`; repo-level GitLab automation for `agentic_base` itself stays out of scope unless requested later.

## Validation And Rollback
- Validation completed locally: `dart analyze lib test`, full `dart test`, and a manual macOS native check that generated a GitLab-flavored app and passed `./tools/ci-check.sh`, including `flutter build ios --simulator`.
- Validation shipped in repo CI: unit/integration coverage plus an always-on pinned `macos-15` generated-app native gate in [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml).
- Enforcement: required GitHub macOS check must use a stable check/job name, always run on `pull_request` and `push`, and avoid workflow-level path filters or job-level conditional skip logic.
- Rollback: revert provider flag/config additions and GitLab template files; GitHub default path remains intact because user-facing deploy contract is unchanged.

## Success Criteria
- `create` and `init` accept exactly one provider value and persist it.
- Generated app contains GitHub CI files or GitLab root/bootstrap CI files, never both.
- `deploy dev|staging|prod` routes by provider without requiring a new command.
- Package tests cover both scaffold variants and legacy GitHub fallback.
- Root GitHub Actions CI always runs a required macOS native gate that fresh-generates an app and executes `./tools/ci-check.sh`.
- That GitHub macOS gate is configured as a required status check for `main`, with a stable check/job name and no conditional skip path.
- Generated GitLab projects declare a macOS-native validation job that requires a `macos` runner, shell executor, and Xcode; docs do not imply Linux fallback.
- Generated GitLab projects declare a blocking macOS-native validation job that runs before deploy jobs, is not `allow_failure`, and requires a `macos` runner, shell executor, and Xcode.
- Generated GitLab projects keep CI portable with root `.gitlab-ci.yml` bootstrapping `.gitlab/ci/*.yml`, without depending on external GitLab project settings.
- GitLab deploy v1 uses explicit manual per-env jobs (`dev`, `staging`, `prod`), with `prod` protected/manual by default.
- Repo docs no longer claim GitLab support is absent for generated projects, and they distinguish repo CI from generated-project native validation.
