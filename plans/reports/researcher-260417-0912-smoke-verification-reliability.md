---
title: Generated-App Smoke Verification Reliability
date: 2026-04-17
scope: /Users/biendh/base
---

# Research Report: Generated-App Smoke Verification Reliability

## Summary
The current smoke path is honest, but it is not cheap. The dominant cost is structural: each smoke case runs a fresh `agentic_base create`, and that create path already does `flutter create`, dependency refresh, codegen, formatting, validation, and a final verify pass before the test even inspects the output. The verify ladder then re-runs generation prep, runs the full test suite, and runs a separate app-shell smoke gate plus native iOS readiness on Darwin.

Sources consulted: [generated_app_smoke_test.dart](/Users/biendh/base/test/integration/generated_app_smoke_test.dart#L270), [project_generator.dart](/Users/biendh/base/lib/src/generators/project_generator.dart#L162), [generated_project_contract.dart](/Users/biendh/base/lib/src/generators/generated_project_contract.dart#L202), [verify.sh](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh#L13), [tools/_common.sh](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/_common.sh#L303), [tools/gen.sh](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/gen.sh#L1), [test/app_smoke_test.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/test/app_smoke_test.dart#L7), [eval_command_test.dart](/Users/biendh/base/test/src/cli/commands/eval_command_test.dart#L36), [doctor_command_test.dart](/Users/biendh/base/test/src/cli/commands/doctor_command_test.dart#L36).

## Findings
1. `ProjectGenerator.generate()` is already a full end-to-end pipeline, so every smoke case pays the whole setup cost.
   - It runs `flutter create`, overlay sync, `pub get`, optional flavorizr, module install, `build_runner`, `dart fix`, `slang`, `format`, validation, then `_verify()` again.
   - Module cases add another dependency refresh after module install.
   - Impact: runtime grows linearly with smoke cases; no shared cache or reused app skeleton.

2. `verify.sh` duplicates Flutter test startup and the app-shell smoke file.
   - Gate 4 runs `run_flutter test` over the whole `test/` tree.
   - Gate 5 immediately runs `run_flutter test test/app_smoke_test.dart` again.
   - `test/app_smoke_test.dart` only checks that the app boots to `MaterialApp` and `Scaffold`, so the second run is pure duplicate launcher cost unless the file is excluded from gate 4.
   - Impact: avoidable latency with no extra confidence.

3. Native readiness is the slowest and most host-sensitive gate.
   - On Darwin with `ios/`, `verify.sh` runs a full `flutter build ios --simulator --debug`.
   - The script already special-cases stale CocoaPods specs, which is a sign this gate is known to be environment-fragile.
   - Impact: large wall-clock cost and the main flake source on macOS lanes.

4. The smoke suite multiplies that cost across six independent app generations.
   - One cubit/github case, two state-runtime cases, two module cases, and one release-preflight case all create fresh temp projects.
   - Each case has its own 6-minute timeout and no artifact reuse.
   - Impact: one slow or flaky path can dominate the whole suite.

5. Contract checks are strong for drift, but brittle to harmless text churn.
   - `GeneratedProjectContract.validate()` and the release-surface checks rely on exact file presence and substring matches.
   - Good for catching contract drift early, but a wording or formatting-only edit can fail the smoke path.
   - Impact: honest, but higher maintenance than a behavior-based assertion.

## Recommendations
1. Recommended: deduplicate the app-shell smoke.
   - Smallest credible change: exclude `test/app_smoke_test.dart` from the generic `flutter test` pass, then keep it only as the explicit `app-shell-smoke` gate.
   - Why this first: it removes one full Flutter startup per verify run with almost no honesty loss.
   - Trade-off: needs a tag or runner exclusion convention, but it fits the repo’s existing test layout.

2. Split verify into core and native/release lanes.
   - Core lane: contract surface, toolchain check, generation prep, unit/widget tests, one shell smoke.
   - Native/release lane: iOS build readiness and release-preflight.
   - Why this fits: the repo already uses dry-run / preview patterns in `EvalCommand` and `DoctorCommand`, so a fast-path / heavy-path split matches existing CLI design.
   - Risk: PRs lose immediate iOS confidence unless the native lane stays mandatory somewhere else.

3. Trim the PR smoke matrix to one canary per dimension.
   - Keep one representative state/runtime case and one release-preflight case on PRs.
   - Move the remaining state and module permutations to nightly or pre-release smoke.
   - Risk: biggest speed win, but the weakest breadth and the highest chance of a regression surfacing later.

## Unresolved Questions
- Should PR verification always include native iOS readiness on Darwin, or only a separate release lane?
- Should `app-shell-smoke` stay as a named evidence gate if the same file is already inside the generic unit/widget run?
- Which smoke permutations are mandatory on PRs: state runtime, modules, or release-preflight?
- Is a tag-based exclusion for `test/app_smoke_test.dart` acceptable, or should the file move to a separate lane?
