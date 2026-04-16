# Phase 04 — Clean Generated App Architecture And Contract Modeling

## Context Links

- [plan.md](./plan.md)
- [generated-app-architecture-review](./research/generated-app-architecture-review.md)
- [Architecture Doc](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/01-architecture.md>)
- [FlavorConfig](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/flavors.dart>)
- [AppLocaleContract](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/locale/app_locale_contract.dart>)
- [Failures](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/error/failures.dart>)

## Overview

- Priority: P0
- Status: Pending
- Goal: clean the generated starter architecture where current implementation is functionally fine but structurally uneven.

## Key Insights

- `AppLocaleContract` is correctly outside generated Slang output, but the rationale is not encoded strongly enough.
- `FlavorConfig` duplicates env lookups per flavor.
- `AppFailure` is modeled as a sealed hierarchy but lacks `freezed` ergonomics.
- some large files violate the starter’s own size standard.
- broad `library/part` adoption would worsen coupling; targeted file splits are the right modularization path.
<!-- Updated: Validation Session 1 - expand freezed usage across shared contracts where technically possible -->

## Requirements

- Preserve stable runtime wrappers outside generated trees.
- Make flavor config smaller and easier to reason about.
- Improve modeled contracts where codegen benefits are real.
- Keep generated app approachable for downstream teams.

## Architecture

- Locale:
  - keep stable app-facing locale wrapper outside `lib/app/i18n/**`
  - make generated-tree ownership rule explicit in code/docs/tests
- Flavor:
  - define one clearer flavor data model with defaults + env overrides
  - reduce repeated `String.fromEnvironment` declarations
- Contracts:
  - migrate `AppFailure` to `freezed` union
  - migrate shared modeled contracts such as response and pagination surfaces to `freezed` where technically possible, with explicit exceptions only when a type cannot or should not move
- Modularization:
  - split large pages/widgets/theme files
  - keep `part` limited to codegen-required leaf surfaces

## Related Code Files

- Modify:
  - [lib/app/flavors.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/flavors.dart>)
  - [lib/app/locale/app_locale_contract.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/locale/app_locale_contract.dart>)
  - [lib/core/contracts/app_response.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_response.dart>)
  - [lib/core/contracts/pagination.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/pagination.dart>)
  - [lib/core/error/failures.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/error/failures.dart>)
  - [lib/core/error/error_handler.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/error/error_handler.dart>)
  - [lib/features/home/presentation/pages/home_page.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/presentation/pages/home_page.dart>)
  - generated docs that describe locale/flavor/contracts
- Add:
  - split files extracted from oversized pages/theme modules as needed
  - tests for locale wrapper ownership and failure behavior

## Implementation Steps

1. Decide and encode the ownership rationale for locale wrapper placement.
2. Refactor flavor config into a smaller data model with shared env key resolution.
3. Migrate `AppFailure` to `freezed`.
4. Migrate `AppResponse`, pagination surfaces, and other shared modeled contracts to `freezed` where technically possible, and document any narrow exceptions explicitly.
5. Split oversized page/theme files into smaller widgets/helpers.
6. Update generated coding/architecture docs so the rationale matches the code.

## Todo List

- [ ] encode locale-wrapper ownership rationale
- [ ] simplify flavor config
- [ ] migrate failures modeling
- [ ] migrate shared modeled contracts to `freezed` where feasible
- [ ] split oversized files
- [ ] sync generated docs

## Success Criteria

- `AppLocaleContract` placement is explicit and mechanically defended
- `FlavorConfig` becomes smaller and less repetitive
- shared modeled contracts have stronger modeling and easier exhaustive/value handling
- large generated files shrink under or closer to the stated size target
- no unnecessary `part` sprawl is introduced

## Risk Assessment

- migrating failures to `freezed` touches error handling, tests, and downstream examples
- file splitting can churn imports and generated docs if not done systematically

## Security Considerations

- keep env handling limited to safe public build-time values
- do not model secrets in flavor/runtime config

## Next Steps

- Feed updated contracts and file splits into Phase 05 drift guards and regression tests.
