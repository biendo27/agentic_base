# 06. Deployment Guide

## Scope

This document covers two separate surfaces:

1. this repository and the `agentic_base` package itself
2. downstream Flutter projects created or initialized by `agentic_base`

## Verified Repo Automation

Current checked-in automation stays GitHub-hosted and lives in:

- [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)
- [`.github/workflows/gitflow-guard.yml`](../.github/workflows/gitflow-guard.yml)

The repo now follows classic Gitflow with `main` as the release branch and `develop` as the integration branch.

Checked-in automation now runs on:

- pull requests into `main`
- pull requests into `develop`
- pushes to `main`
- pushes to `develop`
- pushes to `release/*`
- pushes to `hotfix/*`

The CI workflow does:

- `dart pub get`
- `dart analyze --fatal-infos`
- `dart format --set-exit-if-changed lib bin test`
- `dart test`
- generated-app smoke coverage
- a pinned macOS generated-app native gate that fresh-generates an app and runs `./tools/ci-check.sh`

The Gitflow guard workflow fails PRs that do not follow these routes:

- `feature/*` -> `develop`
- `release/*` -> `main`
- `hotfix/*` -> `main`

Back-merges from `release/*` and `hotfix/*` into `develop` remain required after production merges. This is policy plus PR-route validation, not true branch protection, because GitHub branch protection is unavailable on the current private-repo plan.

There is no checked-in pub.dev publish workflow in this repo today. Release automation focus remains on generated downstream repos.

## Local Validation Before Any Package Release

Run from the repo root:

```bash
dart pub get
dart format --set-exit-if-changed lib bin test
dart analyze --fatal-infos
dart test
dart pub publish --dry-run
```

The last command is an inferred best practice from the package metadata in `pubspec.yaml`. It is not automated in this repo yet.

## Package Publication Notes

Verified from [`pubspec.yaml`](../pubspec.yaml):

- package name: `agentic_base`
- version: `0.1.0`
- homepage/repository/issue tracker are set

Recommended manual publish sequence:

1. update `version:` in `pubspec.yaml`
2. run the local validation commands above
3. run `dart pub publish`
4. create an annotated release tag in the form `vX.Y.Z`

This sequence is partly inference. The repo does not currently codify pub.dev publishing in scripts or workflows.

## Generated-Project Deployment

`agentic_base` ships a `deploy` command with this contract:

- run inside an initialized/generated Flutter project
- require a clean git working tree
- require local branch to be pushed
- resolve one persisted `ci_provider` from `.info/agentic.yaml`
- do not accept a deploy-time provider override
- rely on the generated provider surface already matching the persisted contract; `init` now fails instead of keeping conflicting thin adapters or opposite-provider CI files

Supported environments in source:

- `dev`
- `staging`
- `prod`

### GitHub generated projects

- scaffold `.github/workflows/*.yml`
- logical environment mapping is one workflow file per environment:
  - `dev` → `cd-dev.yml`
  - `staging` → `cd-staging.yml`
  - `prod` → `cd-prod.yml`
- generated workflows call shared local scripts such as:
  - `./tools/verify.sh`
  - `./tools/build.sh <env> [artifact]`
  - `./tools/release-preflight.sh <env> <target>`
  - `./tools/release.sh <env> <target>`
- generated workflows upload `artifacts/evidence/**` so verify and release-preflight runs stay inspectable outside the runner
- final production store publish remains a human approval boundary even when upload plumbing is automated

### GitLab generated projects

- scaffold root `.gitlab-ci.yml` plus `.gitlab/ci/verify.yml` and `.gitlab/ci/deploy.yml`
- generated GitLab CI keeps native validation explicit and blocking:
  - the verification job is tagged `macos`
  - the project must provide a macOS runner with shell executor and Xcode
  - Linux runners may handle Dart-only work, but they do not satisfy native validation
- deploy jobs route through the same shared project scripts and stay manual
- generated verification and deploy pipelines preserve `artifacts/evidence/**` as job artifacts
- logical environment mapping fans out to the real generated jobs:
  - `dev` → `deploy_dev`
  - `staging` → `deploy_staging_android_internal` + `deploy_staging_testflight`
  - `prod` → `deploy_prod_play` + `deploy_prod_app_store`

## Important Caveat

Generated-project GitLab support does not mean this package repo itself runs on GitLab CI. Current scope is:

- repo automation: GitHub Actions only
- generated project automation: GitHub or GitLab, selected by one persisted provider contract

GitLab production protection is still configured in GitLab project settings via protected environments. The scaffold keeps production deploy jobs manual, but GitLab UI policy must still be applied by the downstream repo owner.

## Repo GitHub Settings

The repo-level GitHub settings target this merge policy:

- squash merge enabled
- merge commit disabled
- rebase merge disabled
- auto-delete merged branches enabled
- auto-merge enabled for PRs after checks pass

Server-side branch protection for `main` and `develop` is still blocked by the current GitHub private-repo plan. Once branch protection is available, require:

- CI checks from `CI` and `Gitflow Guard`
- pull request before merge
- approval after checks pass
- no direct pushes to `main`
- no direct pushes to `develop`

## Harness Contract V1 Status

The generated deployment and release surfaces now implement the Harness Contract V1 deployment-facing guarantees:

- named release-preflight and evidence outputs
- explicit approval states shared across local and CI runs
- tier-aware gate packs derived from the declared profile/support tier
- declared Flutter toolchain checks before release-preflight and release flows

The human boundary remains unchanged: final production publish is still not automated away.

The contract details are documented in:

- [`docs/11-eval-and-evidence-model.md`](./11-eval-and-evidence-model.md)
- [`docs/12-approval-state-machine.md`](./12-approval-state-machine.md)
- [`docs/14-sdk-and-version-policy.md`](./14-sdk-and-version-policy.md)

## References

- [`lib/src/cli/commands/deploy_command.dart`](../lib/src/cli/commands/deploy_command.dart)
- [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)
- [`.github/workflows/gitflow-guard.yml`](../.github/workflows/gitflow-guard.yml)
- [`pubspec.yaml`](../pubspec.yaml)
