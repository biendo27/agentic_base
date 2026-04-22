---
type: research
created: 2026-04-21
scope: dart-flutter-ci-test-speed
---

# Research Report: Dart/Flutter Test Speed And CI Gating

## Executive Summary

Fast CI should not mean weaker gates. The best shape is a small always-required fast lane, then conditional heavy lanes that still report through an always-running aggregate status. Avoid workflow-level path filters for required GitHub checks because skipped workflows can leave checks pending.

For this repo, `dart test` must stop running generated-app smoke implicitly. Generated-app tests need explicit tags and dedicated jobs. Native simulator gates should run on generated/native/template changes, release branches, manual dispatch, and nightly canary, not on every doc/package-only PR.

## Sources

- [Dart testing docs](https://dart.dev/tools/testing)
- [package:test docs](https://pub.dev/packages/test)
- [Flutter testing overview](https://docs.flutter.dev/testing/overview)
- [GitHub Actions workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)
- [GitHub Actions concurrency](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency)
- [GitHub Actions dependency caching](https://docs.github.com/en/actions/reference/workflows-and-actions/dependency-caching)
- [GitLab CI caching](https://docs.gitlab.com/ci/caching/)

## Key Findings

1. Dart/package:test supports declared tags, `dart_test.yaml`, `--tags`, `--exclude-tags`, boolean tag selectors, and sharding. Use tags as the first lever before inventing custom runners.
2. Flutter separates unit, widget, and integration tests. Integration tests are for full app or large app surfaces and often require a real device/emulator. Do not mix them into the default unit lane.
3. GitHub workflow-level path filters are unsafe for required checks. If a required workflow is skipped by branch/path filtering, GitHub can leave associated checks pending and block merge.
4. GitHub concurrency can cancel older in-progress runs for the same PR/branch. This saves runner time without hiding failures.
5. Cache only stable dependency caches. Do not cache generated Flutter build directories blindly; cache churn can be slower and less reliable than recomputing.
6. GitLab supports fallback cache keys. Use unique keys per cache path to avoid cache mismatch.

## Recommended Strategy

### Required PR Lane

- `analyze`: `dart pub get`, `dart analyze --fatal-infos`, `dart format --set-exit-if-changed lib bin test tool`
- `unit-tests`: `dart test test/src --exclude-tags generated-app --reporter github`
- `contract-tests`: fast tests that inspect generated templates, workflow rendering, module plist mutation, and docs drift
- `ci-required`: always-running aggregate job that fails if any required or conditionally-run heavy job failed

### Conditional Heavy Lane

- `generated-app-smoke-fast`: run only when generator/template/module/harness paths changed, plus `workflow_dispatch`, `schedule`, `main/develop/release/hotfix` pushes
- `slow-canary`: run on nightly, release/hotfix/main promotion, or harness/verify/evidence/native path changes
- `native-ios-simulator`: run on macOS for native template/module path changes and release readiness; not physical device

### Generated App Test Tags

- `generated-app`: all tests in `test/integration/generated_app_smoke_test.dart`
- `slow-canary`: the full verify canary already exists
- `native-smoke`: future tests that build or run simulator/device targets

## Common Pitfalls

- Running `dart test` over `test/` while also running `test/integration/generated_app_smoke_test.dart` separately duplicates the slow lane.
- Adding workflow-level `paths` to a required GitHub workflow creates pending-check risk.
- Matrixing every flavor/state/provider in PR CI explodes time. Keep one golden path plus contract tests for variants.
- Building prod in PR CI without `env/prod.env` contradicts the generated script policy.

## Unresolved Questions

None.
