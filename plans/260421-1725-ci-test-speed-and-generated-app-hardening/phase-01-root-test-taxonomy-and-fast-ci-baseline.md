# Phase 01: Root Test Taxonomy And Fast CI Baseline

## Context Links

- [Plan](./plan.md)
- [Research: CI/Test Speed](./research/researcher-01-ci-test-speed-best-practices.md)
- [Scout Report](./reports/scout-report.md)
- Current root CI: [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml)
- Current test config: [`dart_test.yaml`](../../dart_test.yaml)
- Current generated smoke: [`test/integration/generated_app_smoke_test.dart`](../../test/integration/generated_app_smoke_test.dart)

## Overview

Priority: P0. Status: Completed.

Make the default package test lane fast and deterministic by tagging generated-app tests and preventing duplicate slow execution. Keep one always-required CI workflow/check, but move heavy work behind internal change detection and an aggregate status.

## Key Insights

- `dart test` currently includes `test/integration/generated_app_smoke_test.dart`.
- CI then runs the same integration file again in `generated-app-smoke`.
- GitHub workflow-level path filters are not acceptable for required checks because skipped workflows can stay pending.

## Requirements

- Functional:
  - Declare all test tags in `dart_test.yaml`.
  - Tag the whole generated-app smoke suite as `generated-app`.
  - Keep `slow-canary` for the full verify canary.
  - Split root CI into fast required jobs and conditional heavy jobs.
  - Add an always-running aggregate required job.
- Non-functional:
  - No workflow-level path filters.
  - No third-party path-filter action unless a simple shell diff is insufficient.
  - Keep CI logs clear for why heavy jobs ran or skipped.

## Architecture

Use one GitHub workflow:

1. `changes` job computes booleans from `git diff`.
2. `analyze` and `unit-tests` always run.
3. `generated-app-smoke-fast`, `slow-canary`, and `native-smoke` run conditionally.
4. `ci-required` runs with `if: always()` and fails if any required or executed conditional job failed.

## Related Code Files

- Modify `/Users/biendh/base/dart_test.yaml`.
- Modify `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`.
- Modify `/Users/biendh/base/.github/workflows/ci.yml`.
- Modify `/Users/biendh/base/test/src/docs/harness_contract_documentation_test.dart` if docs tests assert old tags.
- Possibly update `/Users/biendh/base/docs/06-deployment-guide.md`.

## Implementation Steps

1. Measure current baseline:
   - `time dart test test/src`
   - `time dart test test/integration/generated_app_smoke_test.dart --exclude-tags slow-canary`
   - `time dart test test/integration/generated_app_smoke_test.dart --tags slow-canary`
2. Add `generated-app` and `native-smoke` tag declarations in `dart_test.yaml`.
3. Add suite-level `@Tags(['generated-app'])` to generated-app smoke test.
4. Change root CI `test` job to run only fast package tests:
   - `dart test test/src --exclude-tags generated-app --reporter github`
5. Change `generated-app-smoke` to:
   - `dart test test/integration/generated_app_smoke_test.dart --exclude-tags slow-canary --reporter github`
6. Add a `changes` job using shell `git diff --name-only` against the PR base or previous push SHA.
7. Gate generated smoke on generator/template/module/harness/test-integration changes, plus `workflow_dispatch`, scheduled runs, and protected branch pushes.
8. Gate slow canary on harness/verify/evidence/native-surface changes, plus nightly/manual/release/hotfix/main promotion.
9. Add `ci-required` aggregate job that always runs and fails when an executed dependency failed or was cancelled.
10. Keep concurrency cancellation at workflow level.

## Todo List

- [x] Record baseline runtime.
- [x] Add tags to `dart_test.yaml`.
- [x] Tag generated-app smoke suite.
- [x] Split CI jobs.
- [x] Add change detection.
- [x] Add aggregate required job.
- [x] Update docs/tests that reference CI shape.

## Success Criteria

- `dart test test/src --exclude-tags generated-app` does not run generated-app smoke.
- `dart test test/integration/generated_app_smoke_test.dart --exclude-tags slow-canary` still runs the fast generated-app lane.
- `dart test test/integration/generated_app_smoke_test.dart --tags slow-canary` still runs the canary.
- PR CI has one always-running required aggregate status.
- No workflow-level `paths` or `paths-ignore` are added to `.github/workflows/ci.yml`.

## Risk Assessment

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Heavy jobs skip when they should run | Missed regression | Keep path list broad for `bricks/**`, `lib/src/generators/**`, `lib/src/modules/**`, generated scripts, docs contract tests, and CI files |
| Aggregate job masks failure | False green | Explicitly inspect `needs.*.result` for failure/cancelled |
| CI becomes harder to read | Maintainer friction | Print changed files and skip reasons |

## Security Considerations

- No new secrets.
- Do not expose env files or generated artifacts beyond existing evidence uploads.

## Next Steps

Phase 02 converts generator verification from a boolean to explicit modes so CI can avoid double verification.
