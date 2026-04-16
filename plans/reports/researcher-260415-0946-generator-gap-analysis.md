# Generator Gap Analysis

Scope: local repo only. No implementation changes. Evidence weighted in this order: runtime code, tests, then docs/README. That matters here because `docs/05-project-roadmap.md` and `README.md` are more optimistic than the shipped enforcement in code.

## Shipped vs Claimed

| Surface | Documented claim | Shipped reality |
| --- | --- | --- |
| `README.md` + `docs/05-project-roadmap.md` | Harness Contract V1 and SDK policy are implemented | Contract surfaces exist, but `create`/`init` still write a valid-looking manifest even when the selected SDK manager is unavailable |
| `docs/08-harness-contract-v1.md`, `docs/11-eval-and-evidence-model.md`, `docs/13-flutter-adapter-boundaries.md`, `docs/14-sdk-and-version-policy.md` | Several areas are still design targets / partial enforcement | Code matches that caution: validation is mostly structural, not end-to-end, and feature/test scaffolding is not wired into the flow |

## Findings

| Severity | Finding | Affected files | Evidence | Plan implication |
| --- | --- | --- | --- | --- |
| High | SDK manager enforcement is not end-to-end. | `lib/src/cli/commands/create_command.dart:245-257`, `lib/src/generators/project_generator.dart:39-47,83-181`, `lib/src/config/flutter_sdk_contract.dart:152-169`, `lib/src/config/init_project_metadata_resolver.dart:151-159`, `lib/src/generators/generated_project_contract.dart:763-781`, `lib/src/cli/commands/doctor_command.dart:26-59`, `lib/src/cli/commands/upgrade_command.dart:80-108,158-187` | `resolveFlutterSdkContract()` falls back to `newestTestedFlutterVersion` even when `detectFlutterToolchain()` cannot find the selected manager; `GeneratedProjectContract` only checks manager string shape and semver shape; `doctor` and `upgrade` catch mismatches later, after the repo has already been stamped. | Make `create` and `init` fail fast on unavailable or mismatched managers, and add tests for `fvm`/`puro` missing, version mismatch, and explicit fallback policy. |
| High | Feature generation is mostly dead scaffolding. | `lib/src/cli/commands/feature_command.dart:77-96`, `lib/src/generators/feature_generator.dart:21-47`, `lib/src/config/spec_parser.dart:35-54`, `lib/src/generators/test_generator.dart:14-137`, `bricks/agentic_feature/__brick__/{{project_name.snakeCase()}}/lib/features/home/home.spec.yaml:1-10` | `FeatureCommand` only overlays Mason files and then tells the user to manually register routes; `SpecParser` and `TestGenerator` exist, but I found no production call site that consumes them. The starter `home.spec.yaml` is emitted but not used. | Wire `feature.spec.yaml` into test generation and route integration, or remove the unused spec/test scaffolding so the contract is honest. |
| Medium | Starter app/base architecture is shallow relative to its docs. | `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md:39-106`, `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/router/app_router.dart:4-9`, `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/home.module.dart:1-10`, `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/test/app_smoke_test.dart:7-17`, `docs/06-testing-guide.md:1-32,148-220` | The router hardcodes a single `HomeRoute`; the home feature module is only comments; the app smoke test checks only `MaterialApp` and `Scaffold`. Docs promise stronger unit/widget/core coverage than the template actually emits. | Add route-level and feature-flow assertions, or narrow the docs so they only claim what the brick actually guarantees. |
| Medium | Service-level test coverage is missing for the capability seams the generator claims to own. | `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/test/`, `test/integration/generated_app_smoke_test.dart:44-372`, `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/domain/repositories/home_repository.dart:1-7`, `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/data/repositories/home_repository_impl.dart:11-30`, `lib/src/modules/*` | The generated app brick ships state-runtime tests and one app smoke path, but no `test/core/*` or service/repository test surface. The real capability modules in `lib/src/modules/*` all rely on service abstractions, yet the starter test tree does not prove those seams. | Add at least one unit test per core capability/service seam and include those gates in `verify` so module regressions do not surface only in smoke tests. |
| Low-Medium | The smoke suite is slow because it runs the full generator pipeline repeatedly. | `lib/src/generators/project_generator.dart:83-181,316-343`, `test/integration/generated_app_smoke_test.dart:38-372` | Each `create` path runs `flutter create`, `flutter pub get`, `flutter_flavorizr`, `build_runner`, `dart fix --apply`, `dart run slang`, `dart format`, and then `tools/verify.sh`. The integration smoke suite repeats that pipeline across CI providers, state modes, and release-preflight. | Keep only one true end-to-end smoke per major surface; move manifest/contract assertions to unit tests; use injected process runners for command tests; reuse static fixtures where the assertion target does not change. |

## Recommended Order

1. SDK manager enforcement first. This is the highest-correctness blocker and the only place where the generator can prevent invalid repos from being stamped as honest contracts.
2. Feature spec/test wiring second. `SpecParser` and `TestGenerator` already exist, so this is the shortest path to making `agentic_feature` stronger without redesigning the whole app brick.
3. Starter app/service tests third. This closes the architecture gap and makes the generated app a better proof of the contract instead of just a boot smoke.
4. Smoke acceleration last. Optimize after the contract semantics are stable, so CI speed work does not paper over logic gaps.

## Slow Test Notes

Likely causes: repeated real Flutter subprocesses, `build_runner`, Slang, flavorization, formatting, and full repo regeneration inside `create`; plus the smoke suite replays the same heavy path for several permutations. Safe accelerations: isolate contract checks from end-to-end smoke, mock subprocesses in command-unit tests, reuse generated fixtures for static assertions, and tag the heavy smoke lane so it does not run everywhere.

## Resolution Note

The previously open planning questions are now closed:

- SDK manager behavior is preference-driven with `preferred` + `resolved` traceability and a defined fallback order.
- `feature.spec.yaml` remains in scope and must be wired into real route/test generation.
