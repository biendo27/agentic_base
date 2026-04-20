---
status: completed
created: 2026-04-20
updated: 2026-04-20
blockedBy: []
blocks: []
---

# Fix Pub Archive Hidden Brick Files

## Context

Published `agentic_base 0.2.1` restores generated docs but still omits hidden generated-app brick paths such as `.vscode/launch.json`, `.github/workflows/*.yml`, and `.info/agentic.yaml`.

## Root Cause

`dart pub publish` excludes dot files and dot directories from the package archive unless explicitly re-included. The source tree contains the required generated-app hidden paths, but the published archive does not.

## Scope

- Update archive policy so required hidden generated-app brick files are packaged.
- Add regression coverage that compares required generated project paths with source and archive policy.
- Bump package version to `0.2.2`.
- Validate local source generation and package dry-run before release.

## Files

- `.pubignore`
- `pubspec.yaml`
- `lib/src/cli/cli_runner.dart`
- `CHANGELOG.md`
- `docs/06-deployment-guide.md`
- `test/src/docs/harness_contract_documentation_test.dart`

## Success Criteria

- Published archive policy explicitly includes `.info`, `.vscode`, `.github`, `.gitlab`, `.gitlab-ci.yml`, `.gitignore`, and `.idea` under the app brick.
- Regression test fails if any `GeneratedProjectContract.requiredPaths` file is missing from the app brick source.
- `dart pub publish --dry-run` shows hidden app-brick files in the archive and reports zero warnings after commit.
- `agentic_base create` succeeds from both source and installed package `0.2.2`.

## Validation

- `git check-ignore` confirmed hidden app-brick files are not ignored by root `.gitignore`.
- `dart pub publish --dry-run` listing includes hidden app-brick entries: `.github`, `.gitignore`, `.gitlab`, `.gitlab-ci.yml`, `.idea`, `.info`, and `.vscode`.
- `dart analyze --fatal-infos` passed.
- Targeted docs/config/generator tests passed.
- `dart format --set-exit-if-changed lib bin test` passed.
- Full `dart test --reporter compact` passed: 273 tests.
- Source `create` passed for default GitHub provider.
- Source `create --ci-provider gitlab` passed for GitLab provider.
