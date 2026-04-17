# Research Report: Docs and Contract Drift

- Conducted: 2026-04-17 09:14 Asia/Saigon
- Scope: root/generated doc truthfulness, shared contract-model drift, and minimum follow-up scope for the four red-team findings

## Summary

The four red-team findings are effectively closed in the current tree. Root docs no longer speak in future-wave language, `docs/02-codebase-summary.md` preserves the root navigation role instead of being deleted, the generated app now has one explicit workflow doc, and the shared contract package is modeled file-per-contract with tests and validator coverage.

I did not find an open issue among those four findings. The only residual drift I could verify is outside that set: `doctor` still has a no-manifest fallback path that probes bare `flutter`/`dart` before any `.info/agentic.yaml` exists. That is a fallback behavior, not a docs/model contradiction, but it is the one edge I would keep on the next checklist if the team wants the "manager-aware" story to read as absolute.

## Findings

1. External-pattern cargo cult: fixed.
   - The contract package is still file-per-contract, but it is now bounded and exercised instead of copied wholesale from an external model. The generated contract files are explicit and tested: [`app_response.dart`](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_response.dart#L5), [`app_list_response.dart`](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_list_response.dart#L5), [`pagination.dart`](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/pagination.dart#L25), [`localized_text.dart`](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/localized_text.dart#L5).
   - The generated starter tests also exercise those shapes directly: [`project_generator_test.dart`](/Users/biendh/base/test/src/generators/project_generator_test.dart#L145), [`localized_text` smoke coverage](/Users/biendh/base/test/integration/generated_app_smoke_test.dart#L124).

2. Docs deletion without canonical replacement: fixed.
   - The root doc surface still has a retained orientation doc instead of losing context: [`docs/02-codebase-summary.md`](/Users/biendh/base/docs/02-codebase-summary.md#L5) plus the root README index and contract summary remain aligned with the shipped-state story: [`README.md`](/Users/biendh/base/README.md#L67), [`README.md`](/Users/biendh/base/README.md#L86), [`docs/08-harness-contract-v1.md`](/Users/biendh/base/docs/08-harness-contract-v1.md#L21).
   - The docs test now explicitly forbids the stale future-wave phrases in the contract docs: [`harness_contract_documentation_test.dart`](/Users/biendh/base/test/src/docs/harness_contract_documentation_test.dart#L11).

3. Harness-flow doc duplication: fixed.
   - The generated repo now has one dedicated workflow doc, and it is wired through README, thin adapters, and the testing guide: [`README.md`](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md#L17), [`AGENTS.md`](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/AGENTS.md#L13), [`CLAUDE.md`](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/CLAUDE.md#L13), [`docs/07-agentic-development-flow.md`](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/07-agentic-development-flow.md#L5).
   - The workflow doc now owns the agent loop, verify order, and human approval boundary instead of reusing architecture prose: [`docs/07-agentic-development-flow.md`](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/07-agentic-development-flow.md#L13).

4. Method vs extension confusion: fixed.
   - The policy is now explicit in the manifest/schema docs: intrinsic behavior stays in the contract model, derived views stay derived, and `support_tier`/`default_gate_pack` remain read models only: [`docs/10-manifest-schema.md`](/Users/biendh/base/docs/10-manifest-schema.md#L125).
   - The model code follows that split instead of widening into a shared `base.dart`/`part` library: `FlutterSdkContract` carries preferred vs resolved values, `HarnessMetadata` derives support tier from profile, and the contract files use extensions for convenience rather than leaking runtime coupling into raw model classes: [`flutter_sdk_contract.dart`](/Users/biendh/base/lib/src/config/flutter_sdk_contract.dart#L35), [`harness_metadata.dart`](/Users/biendh/base/lib/src/config/harness_metadata.dart#L60), [`localized_text.dart`](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/localized_text.dart#L29).

## Recommendations

- Treat the four red-team findings as closed.
- Keep the existing guards: root doc truthfulness test, generated-doc validator, generated-project contract validation, and the contract-model unit tests.
- If you want one small follow-up, document or test the `doctor` no-manifest fallback so the bare `flutter`/`dart` probes are clearly called out as pre-contract behavior, not a contract-aware path.
- Do not reopen the contract package into a broader `base.dart` layout unless the team actually needs a cohesive library boundary; the current file-per-contract split is the lower-risk fit.

## Unresolved Questions

- Should `doctor`'s no-manifest fallback be documented as an explicit pre-contract exception, or left as implementation detail?

