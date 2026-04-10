# 06. Deployment Guide

## Scope

This document covers two separate surfaces:

1. this repository and the `agentic_base` package itself
2. downstream Flutter projects created or initialized by `agentic_base`

## Verified Repo Automation

Current checked-in automation stays GitHub-hosted and lives in:

- [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)

It runs on pushes and pull requests to `main` and does:

- `dart pub get`
- `dart analyze --fatal-infos`
- `dart format --set-exit-if-changed lib bin test`
- `dart test`
- generated-app smoke coverage for `--ci-provider github`
- generated-app smoke coverage for `--ci-provider gitlab`
- a pinned macOS generated-app native gate that fresh-generates an app and runs `./tools/ci-check.sh`

There is no checked-in release workflow or pub.dev publish workflow in this repo today.

## Local Validation Before Any Package Release

Run from the repo root:

```bash
dart pub get
dart format --set-exit-if-changed lib bin
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
4. tag the release in git

This sequence is partly inference. The repo does not currently codify it in scripts or workflows.

## Generated-Project Deployment

`agentic_base` ships a `deploy` command with this contract:

- run inside an initialized/generated Flutter project
- require a clean git working tree
- require local branch to be pushed
- resolve one persisted `ci_provider` from `.info/agentic.yaml`
- do not accept a deploy-time provider override

Supported environments in source:

- `dev`
- `staging`
- `prod`

### GitHub generated projects

- scaffold `.github/workflows/*.yml`
- `agentic_base deploy <env>` requires authenticated `gh`
- deploy routing uses `gh workflow run cd-<env>.yml`
- generated workflows call the shared project scripts:
  - `./tools/ci-check.sh`
  - `./tools/build.sh <env>`

### GitLab generated projects

- scaffold root `.gitlab-ci.yml` plus `.gitlab/ci/verify.yml` and `.gitlab/ci/deploy.yml`
- `agentic_base deploy <env>` requires authenticated `glab`
- deploy routing creates a pipeline on the current branch, then targets the matching manual job:
  - `deploy_dev`
  - `deploy_staging`
  - `deploy_prod`
- generated GitLab CI keeps native validation explicit and blocking:
  - the verification job is tagged `macos`
  - the project must provide a macOS runner with shell executor and Xcode
  - Linux runners may handle Dart-only work, but they do not satisfy native validation

## Important Caveat

Generated-project GitLab support does not mean this package repo itself runs on GitLab CI. Current scope is:

- repo automation: GitHub Actions only
- generated project automation: GitHub or GitLab, selected by one persisted provider contract

GitLab production protection is still configured in GitLab project settings via protected environments. The scaffold keeps `deploy_prod` manual, but GitLab UI policy must still be applied by the downstream repo owner.

## References

- [`lib/src/cli/commands/deploy_command.dart`](../lib/src/cli/commands/deploy_command.dart)
- [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)
- [`pubspec.yaml`](../pubspec.yaml)
