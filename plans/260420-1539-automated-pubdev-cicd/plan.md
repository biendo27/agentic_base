---
status: completed
created: 2026-04-20
updated: 2026-04-20
blockedBy: []
blocks: []
---

# Automated pub.dev CI/CD

## Overview

Add repo-level continuous delivery for `agentic_base` package releases while preserving existing Gitflow and CI gates.

## Scope

- Add a GitHub Actions workflow that publishes to pub.dev from version tags only.
- Use pub.dev automated publishing via GitHub OIDC, not stored secrets.
- Add a CI dry-run gate so PRs and protected branch pushes validate publish readiness.
- Update deployment docs with exact setup steps for pub.dev and GitHub environment protection.
- Add a lightweight regression test that keeps the workflow contract visible.

## Decisions

- Tag pattern: `v{{version}}` on pub.dev and `v[0-9]+.[0-9]+.[0-9]+` in GitHub Actions.
- Environment name: `pub.dev`, matching Dart official guidance.
- Release path: merge feature into `develop`, create a release branch when promoting to `main`, then tag from `main`.

## Files

- `.github/workflows/ci.yml`
- `.github/workflows/publish.yml`
- `docs/06-deployment-guide.md`
- `test/src/docs/harness_contract_documentation_test.dart`

## Implementation Steps

1. Add `publish.yml` using `dart-lang/setup-dart/.github/workflows/publish.yml@v1`.
2. Add `pub-publish-dry-run` job to CI after unit and generated-app smoke checks.
3. Update docs to replace manual-only publish notes with automated tag-driven release notes.
4. Add docs regression test assertions for workflow trigger, OIDC permission, and environment.
5. Run format/analyze targeted tests and `dart pub publish --dry-run`.

## Success Criteria

- CI workflow validates `dart pub publish --dry-run`.
- Publish workflow requires tag push and OIDC `id-token: write`.
- Publish workflow is gated by the `pub.dev` environment input.
- Docs explain the remaining one-time external setup on pub.dev/GitHub.
- No package code behavior changes.

## Validation

- `dart format test/src/docs/harness_contract_documentation_test.dart`
- `dart analyze`
- `dart test test/src/docs/harness_contract_documentation_test.dart`
- `actionlint .github/workflows/*.yml`
- `git diff --check`
