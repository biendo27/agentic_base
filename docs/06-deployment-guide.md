# 06. Deployment Guide

## Scope

This document covers two separate surfaces:

1. this repository and the `agentic_base` package itself
2. downstream Flutter projects created or initialized by `agentic_base`

## Verified Repo Automation

Current checked-in automation stays GitHub-hosted and lives in:

- [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)
- [`.github/workflows/gitflow-guard.yml`](../.github/workflows/gitflow-guard.yml)
- [`.github/workflows/publish.yml`](../.github/workflows/publish.yml)

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
- `dart test test/src --exclude-tags generated-app --reporter github`
- generated-app smoke coverage only when generator, template, module, harness, or integration-test paths changed
- the slow generated-app canary only for harness/profile/evidence/native-surface changes, manual runs, schedules, and protected branch promotions
- pub.dev package archive dry-run with zero warnings
- a conditional pinned macOS generated-app native gate that fresh-generates an app with `--verify-mode none` and then runs `./tools/ci-check.sh`
- an always-running `ci-required` aggregate status that fails if any required or executed conditional job fails or is cancelled

The workflow intentionally avoids workflow-level `paths` and `paths-ignore` filters. Required GitHub checks can remain pending when whole workflows are skipped, so path decisions happen inside the workflow through the `changes` job.

The Gitflow guard workflow fails PRs that do not follow these routes:

- `feature/*` -> `develop`
- `release/*` -> `main`
- `hotfix/*` -> `main`

Back-merges from `release/*` and `hotfix/*` into `develop` remain required after production merges. This is policy plus PR-route validation, not true branch protection, because GitHub branch protection is unavailable on the current private-repo plan.

The publish workflow releases this package to pub.dev when a version tag is pushed. It intentionally does not publish on normal branch pushes or pull requests.

Before publishing, the workflow validates:

- the pushed tag matches `vX.Y.Z`
- the tag version matches `version:` in [`pubspec.yaml`](../pubspec.yaml)
- the tag commit is already reachable from `origin/main`

The publish job uses Dart's official GitHub OIDC flow through `dart-lang/setup-dart/.github/workflows/publish.yml@v1`. It does not require a long-lived pub.dev token in GitHub secrets.

## Local Validation Before Any Package Release

Run from the repo root:

```bash
dart pub get
dart format --set-exit-if-changed lib bin test
dart analyze --fatal-infos
dart test test/src --exclude-tags generated-app
dart test test/integration/generated_app_smoke_test.dart --exclude-tags slow-canary
dart pub publish --dry-run
```

The CI workflow also runs `dart pub publish --dry-run` and fails unless the dry-run reports zero warnings.

## Package Publication Notes

Verified from [`pubspec.yaml`](../pubspec.yaml):

- package name: `agentic_base`
- version: `0.3.0`
- homepage/repository/issue tracker are set
- `.pubignore` excludes repo-only `/docs/`, `/plans/`, coverage output, and repomix artifacts from the published archive while keeping generated-app brick docs and hidden generated-project files available for runtime scaffolding

Recommended manual publish sequence:

1. update `version:` in `pubspec.yaml`
2. review `.pubignore` and `README.md` links so the archive only ships package assets
3. run the local validation commands above
4. merge the release branch into `main`
5. create and push an annotated release tag in the form `vX.Y.Z` from `main`

The tag push starts the pub.dev publish workflow after the one-time setup below is complete.

### One-time pub.dev automated publishing setup

Configure this in pub.dev after the package exists:

- open the `agentic_base` package admin page
- enable automated publishing
- provider: GitHub Actions
- repository: `biendo27/agentic_base`
- tag pattern: `v{{version}}`

Configure this in GitHub:

- create an environment named `pub.dev`
- require a reviewer for that environment if you want a final human gate before publishing
- keep release tags created from `main` after Gitflow promotion

The GitHub workflow passes `environment: pub.dev` to the official Dart reusable publish workflow, so GitHub environment approvals can pause production publishing without storing pub.dev credentials in the repo.

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
  - `./tools/lint.sh --strict`
  - `./tools/build.sh <env> [artifact]`
  - `./tools/release-preflight.sh <env> <target>`
  - `./tools/release.sh <env> <target>`
  - `./tools/inspect-evidence.sh <run-kind> [latest|run-id] [markdown|json]`
- generated workflows upload `artifacts/evidence/**` so verify and release-preflight runs stay inspectable outside the runner
- generated evidence bundles now also include `telemetry/*` files for runtime context, events, and metrics
- generated PR CI builds only credentialless `dev` and `staging` artifacts; `prod` builds require `env/prod.env` and protected release or production deploy workflows
- final production store publish remains a human approval boundary even when upload plumbing is automated

### GitLab generated projects

- scaffold root `.gitlab-ci.yml` plus `.gitlab/ci/verify.yml` and `.gitlab/ci/deploy.yml`
- generated GitLab CI keeps native validation explicit and blocking:
  - the verification job is tagged `macos`
  - the project must provide a macOS runner with shell executor and Xcode
  - Linux runners may handle Dart-only work, but they do not satisfy native validation
- iOS simulator readiness does not replace physical-device signing; provisioning profiles and device UDIDs remain human-owned setup
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

## Downstream Team Workflow

Generated repos document classic Gitflow as a recommended default team workflow:

- `feature/*` -> `develop`
- `release/*` -> `main`
- `hotfix/*` -> `main`
- back-merge `release/*` and `hotfix/*` into `develop` after production promotion

That guidance lives in generated `README.md`, `docs/07-agentic-development-flow.md`, `AGENTS.md`, and `CLAUDE.md`. It is not persisted in `.info/agentic.yaml`, and this wave does not add generated branch-guard automation for downstream repos.

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
- derived inspect/report surfaces that read local bundle files instead of a hosted service
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
- [`.github/workflows/publish.yml`](../.github/workflows/publish.yml)
- [`pubspec.yaml`](../pubspec.yaml)
