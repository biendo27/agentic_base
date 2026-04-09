# 06. Deployment Guide

## Scope

This document covers two separate surfaces:

1. this repository and the `agentic_base` package itself
2. downstream Flutter projects created or initialized by `agentic_base`

## Verified Repo Automation

Current checked-in automation is limited to CI:

- [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)

It runs on pushes and pull requests to `main` and does:

- `dart pub get`
- `dart analyze --fatal-infos`
- `dart format --set-exit-if-changed lib bin`
- `dart test`

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
- require authenticated `gh`
- run `gh workflow run cd-<env>.yml`

Supported environments in source:

- `dev`
- `staging`
- `prod`

## Important Caveat

The required `cd-<env>.yml` workflows are not checked into this repo, and they were not found inside the current app brick either. That means:

- the command contract exists in package code
- the workflow implementation must be supplied by downstream projects or added later to the template

Do not assume `agentic_base deploy prod` works out of the box in a newly generated project until those workflow files exist.

## Recommended Next Step

Pick one of these and document it permanently:

- bundle deployment workflows inside the app brick
- keep workflows external, but document the expected file names and inputs in the generated project README

## References

- [`lib/src/cli/commands/deploy_command.dart`](../lib/src/cli/commands/deploy_command.dart)
- [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)
- [`pubspec.yaml`](../pubspec.yaml)
