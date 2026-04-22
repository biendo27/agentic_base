# Validation Results

Date: 2026-04-21 to 2026-04-22

## Baseline

- `dart test test/src`: passed, 9.69s real.

## Final Validation

- `dart format --set-exit-if-changed lib bin test`: passed.
- `dart analyze --fatal-infos`: passed.
- `dart test test/src --exclude-tags generated-app`: passed, 5.98s real.
- `dart test test/src/cli/commands/create_command_test.dart test/src/modules/ads_module_test.dart test/src/generators/project_generator_test.dart test/src/docs/harness_contract_documentation_test.dart`: passed.
- `dart test test/integration/generated_app_smoke_test.dart --exclude-tags slow-canary`: passed, 251.81s real.
- `dart test test/integration/generated_app_smoke_test.dart --tags slow-canary`: passed, 70.12s real.
- Fresh local native gate: `agentic_base create native_gate_app --verify-mode none` then generated `./tools/ci-check.sh`: passed, 123.43s real.
- `actionlint .github/workflows/ci.yml`: passed.
- Workflow-token and prod-PR-build inspections are covered by `GeneratedProjectContract` tests and the generated-app smoke render/validate path for GitHub and GitLab scaffolds.
- Docs inspections covered root README/docs plus generated README/testing/workflow docs for verify modes, strict lint, prod boundary, and simulator-vs-device signing boundary.

## Post-Review Validation

- `dart format lib test`: passed, 0 changed.
- `dart analyze --fatal-infos`: passed.
- `dart test test/src/cli/commands/create_command_test.dart test/src/modules/ads_module_test.dart test/src/generators/project_generator_test.dart test/src/docs/harness_contract_documentation_test.dart --reporter compact`: passed.
- `actionlint .github/workflows/ci.yml`: passed.
- `/usr/bin/time -p dart test test/src --exclude-tags generated-app --reporter compact`: passed, 6.57s real.

## Evidence

- Native gate evidence: generated temp bundle ended at `artifacts/evidence/verify/20260421T105642Z-44293`.
- Slow canary evidence: generated temp bundle ended at `artifacts/evidence/verify/20260421T105505Z-41520`.

## Unresolved Questions

None.
