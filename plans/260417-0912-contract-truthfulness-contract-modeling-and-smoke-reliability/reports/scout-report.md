# Scout Report

## Scope

Focused scan of the four review findings plus nearby enforcement surfaces.

## Confirmed Current State

1. Root contract docs are already in shipped-state language.
   - `README.md` claims Harness Contract V1 is implemented.
   - `docs/08-13` no longer contain the stale future-tense phrases.
   - `test/src/docs/harness_contract_documentation_test.dart` enforces that.

2. Generated testing docs are already manager-aware.
   - Generated `docs/06-testing-guide.md` now teaches `./tools/test.sh`, `make test`, and `./tools/verify.sh`.
   - `lib/src/generators/generated_project_contract.dart` requires those strings and forbids `flutter test`.

3. Shared contract modeling still conflicts with published guidance.
   - `docs/02-coding-standards.md` says intrinsic contract behavior belongs on the contract class.
   - `app_response.dart`, `app_list_response.dart`, `localized_text.dart`, and `pagination.dart` still put intrinsic helpers in extensions.

4. Smoke verification is structurally heavy.
   - `ProjectGenerator.generate()` ends with `_verify()`, so every smoke case pays the full create + verify cost.
   - `verify.sh` runs `run_flutter test` and then runs `run_flutter test test/app_smoke_test.dart` again.
   - `generated_app_smoke_test.dart` creates multiple full temp projects and gives each lane a 6-minute timeout.

## Files Most Likely In Scope

- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/02-coding-standards.md`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_response.dart`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_list_response.dart`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/localized_text.dart`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/pagination.dart`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh`
- `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`
- `/Users/biendh/base/test/src/docs/harness_contract_documentation_test.dart`
- `/Users/biendh/base/test/src/generators/project_generator_test.dart`
- `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`

## Recommendation

Keep the plan narrow:

- do not reopen already-correct root/generated docs except to strengthen guards
- resolve the contract-class vs extension mismatch decisively
- cut smoke duplication first, then decide whether to keep one heavy canary and lighter parity lanes

## Resolution Note

No unfinished plan overlaps this scope. The completed plans from 2026-04-16 are context only.
