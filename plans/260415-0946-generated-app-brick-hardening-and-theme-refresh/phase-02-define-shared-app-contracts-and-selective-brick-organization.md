# Phase 02: Define Shared App Contracts And Selective Brick Organization

## Context Links

- [Plan overview](./plan.md)
- [Research summary](./research/research-summary.md)
- [Scout report](./reports/scout-report.md)
- [Effective Dart note on `part`](https://dart.dev/effective-dart/usage)

## Overview

- Priority: P0
- Status: Completed
- Goal: replace weak generated base contracts and decide where brick-level file compaction is actually justified.

## Key Insights

- tuple-based repository/use-case returns are too weak for a generator base
- research points to keeping `part` limited to codegen leaf files only
- the starter app needs reusable result, pagination, and language contracts before richer features make sense

## Requirements

- define reusable app-level `fpdart` boundary contracts plus result/response/pagination helpers
- add a base language/locale contract that can support multi-language features beyond app/home strings
- sweep core/config surfaces for obvious sealed/freezed candidates
- establish a written rule for where `library` + `part` is allowed and where barrel exports stay preferable
- keep presentation state APIs straightforward for generated UI code

## Architecture

- prefer `Either` / `TaskEither` / `Option` at data/domain boundaries, with UI layers converting into generated state objects
- define typed support models such as paged response/request and typed `Failure`
- keep Freezed/JsonSerializable for generated immutable/state models
- keep `part` limited to codegen-required files unless a later implementation change proves a narrowly scoped exception
- keep repositories, use cases, services, pages, and modules as normal files
- avoid FP-heavy presentation pipelines in the base scaffold

## Related Code Files

- Modify:
  - `/Users/biendh/base/lib/src/cli/commands/feature_command.dart`
  - `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/error/failures.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/error/error_handler.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/network/api_client.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/network/interceptors/error_interceptor.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/flavors.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/data/repositories/home_repository_impl.dart`
  - `/Users/biendh/base/bricks/agentic_feature/__brick__/...`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/pubspec.yaml`
  - `/Users/biendh/base/test/src/cli/commands/feature_command_test.dart`
  - `/Users/biendh/base/test/src/generators/project_generator_test.dart`
  - `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`
- Create:
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_result.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_response.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/pagination.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/locale/app_locale_contract.dart`
  - organization guidance for generated files if needed
- Delete:
  - dead or redundant tuple-based seams if replaced fully

## Implementation Steps

1. Define the shared result/response/pagination contract set.
   - standardize on `fpdart` at boundaries
2. Decide sealed/freezed usage boundaries for core/config surfaces.
3. Replace tuple-based returns in starter and feature brick outputs.
4. Add base locale/language support and shared translation namespaces.
5. Apply selective file-organization cleanup with explicit `part` boundaries.

## Todo List

- [x] Define reusable generated app contracts
- [x] Add pagination and response abstractions
- [x] Add base language or locale support
- [x] Replace tuple-based home/feature seams
- [x] Document and enforce codegen-only `part` usage by default

## Success Criteria

- generated features stop relying on `(data, failure)` tuples
- shared contracts are reusable across starter app and generated features
- `part` usage remains selective, consistent, and explainable

## Risk Assessment

- Risk: overengineering the base contracts
- Mitigation: keep only contracts that are already exercised by starter app, feature brick, or module seams

## Security Considerations

- response and pagination models must remain declarative and secret-free
- locale persistence must not encourage unsafe storage patterns

## Next Steps

- Phase 03 builds the refreshed theme system on top of these shared contracts and organization rules.

## Execution Notes

- Added reusable generated-app contracts for `AppResult`, `AppResponse`, and pagination under `lib/core/contracts/**`.
- Upgraded starter and generated feature repositories/use cases from tuple returns to `fpdart`-backed `AppResult<T>` boundaries.
- Added a stable locale wrapper under `lib/app/locale/app_locale_contract.dart` so runtime code no longer depends on writing custom files into the generated Slang output directory.
- Expanded generated failure types and error mapping to cover unauthorized, not-found, and validation failures without leaking raw transport exceptions past the data layer.
- Hardened `agentic_base feature` so full feature scaffolds fail fast on legacy repos that do not yet have the shared host contract files or `fpdart` dependency.
- Updated the generated network layer so interceptors attach typed failure payloads and repositories normalize them through `ErrorHandler.handle(...)` instead of silently downgrading everything to `UnexpectedFailure`.
- Updated generated app docs and root repo docs to keep the `codegen-only part usage` rule and the new shared-contract boundary explicit.

## Verification

- `dart analyze` on the package root passes.
- `dart test test/src/generators/project_generator_test.dart` passes.
- `dart test test/src/cli/commands/feature_command_test.dart` passes.
- `dart test test/integration/generated_app_smoke_test.dart --plain-name "riverpod starter app with no foreign runtime leftovers"` passes.
- Generated-app smoke coverage passes for:
  - cubit + GitHub scaffold
  - cubit + GitLab scaffold
  - riverpod starter scaffold
  - mobx starter scaffold
