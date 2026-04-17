# Research Summary

## Summary

Local code inspection plus two researcher reports show a split outcome:

- Finding 1 is already fixed: root docs `08-13` are now in shipped-state language, and `test/src/docs/harness_contract_documentation_test.dart` forbids the stale future-tense phrases.
- Finding 2 is already fixed: generated `docs/06-testing-guide.md` now teaches `./tools/test.sh`, `make test`, and `./tools/verify.sh`, while `GeneratedProjectContract.validate()` forbids bare `flutter test`.
- Finding 3 is still open by direct code evidence: generated coding standards say intrinsic contract behavior belongs on the contract class, but `app_response.dart`, `app_list_response.dart`, `localized_text.dart`, and `pagination.dart` still place intrinsic helpers in extensions.
- Finding 4 is still open: smoke verification is structurally expensive because each smoke case runs a full `create` pipeline, `verify.sh` duplicates `app_smoke_test.dart`, and Darwin native readiness is the heaviest gate.

## Inputs Used

- [README.md](/Users/biendh/base/README.md)
- [docs/08-harness-contract-v1.md](/Users/biendh/base/docs/08-harness-contract-v1.md)
- [test/src/docs/harness_contract_documentation_test.dart](/Users/biendh/base/test/src/docs/harness_contract_documentation_test.dart)
- [generated_project_contract.dart](/Users/biendh/base/lib/src/generators/generated_project_contract.dart)
- [06-testing-guide.md](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/06-testing-guide.md>)
- [02-coding-standards.md](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/02-coding-standards.md>)
- [app_response.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_response.dart>)
- [app_list_response.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_list_response.dart>)
- [localized_text.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/localized_text.dart>)
- [pagination.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/pagination.dart>)
- [generated_app_smoke_test.dart](/Users/biendh/base/test/integration/generated_app_smoke_test.dart)
- [verify.sh](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh>)
- [Docs and Contract Drift Report](../../reports/researcher-260417-0912-docs-and-contract-drift.md)
- [Smoke Verification Reliability Report](../../reports/researcher-260417-0912-smoke-verification-reliability.md)

## Adjudication

- The docs/contracts researcher marked finding 3 as fixed. The code does not support that conclusion. This plan follows the code, not the optimistic reading.
- The smoke researcher found a low-risk first optimization: stop running `test/app_smoke_test.dart` twice in one verify pass.

## Planning Implications

1. Treat findings 1-2 as regression-proofing work, not as a content-rewrite project.
2. Make one explicit architectural choice for generated contracts: either move intrinsic helpers onto classes or relax the docs rule. Do not keep the current mismatch.
3. Speed work must preserve one honest full verify canary. Do not win time by silently dropping the strongest gate.

## Resolution Note

No planning blocker remains. The only user-facing decisions now are how strict the contract-class policy should be and how much heavy smoke coverage must stay on the PR path.
