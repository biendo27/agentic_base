# Phase 05: Expand Service Coverage And Generator Verification

## Context Links

- [Plan overview](./plan.md)
- [Scout report](./reports/scout-report.md)
- [Generator gap analysis](../reports/researcher-260415-0946-generator-gap-analysis.md)

## Overview

- Priority: P1
- Status: Completed
- Goal: prove the seams the generator claims to own, instead of relying mainly on downstream smoke checks.

## Key Insights

- generated app tests currently prove boot far better than service behavior
- module service seams and starter repositories deserve unit-level proof
- deeper coverage here is the prerequisite for safe test-speed optimization later

## Requirements

- add generated app tests for default services, starter repositories, and state runtime behavior
- expand repo-level tests around module-owned service injection and generated outputs
- keep verify gates meaningful and evidence-backed

## Architecture

- generated app brick should ship a small but representative test tree:
  - app shell
  - route or starter-flow widget tests
  - service/repository unit tests
  - state runtime tests for the selected state-management option
- repo-level contract tests should focus on ownership and generator guarantees, not duplicate every downstream widget assertion

## Related Code Files

- Modify:
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/test/...`
  - `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`
  - `/Users/biendh/base/test/src/generators/project_generator_test.dart`
  - `/Users/biendh/base/test/src/modules/...`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh`
- Create:
  - generated app service/repository tests
  - additional repo-level command or generator tests where coverage is missing
- Delete:
  - redundant smoke-only assertions replaced by lower-level tests

## Implementation Steps

1. Define the minimum generated test matrix for the base app.
2. Add service/repository/state tests in the app brick.
3. Expand repo-level generator tests to cover the new contracts and starter flow.
4. Update verify sequencing only where new tests should become required gates.
5. Keep evidence outputs aligned with the strengthened test matrix.

## Todo List

- [x] Add generated app unit/widget coverage for core seams
- [x] Expand repo-level generator assertions
- [x] Revisit verify gate boundaries
- [x] Keep evidence outputs meaningful
- [x] Remove redundant assertions only after replacements exist

## Execution Notes

- completed in repo state as of 2026-04-15
- generated app template now ships starter-owned repository tests, state-runtime tests, widget proof, app-shell smoke, and native-readiness verify gating
- repo-level tests now assert spec-driven feature host outputs beyond helper-file existence alone
- verify evidence remains aligned with the strengthened generated test matrix

## Success Criteria

- service seams are not proven only by app boot smoke
- generated app tests cover the strongest owned paths
- repo-level tests and verify gates stay aligned

## Risk Assessment

- Risk: test matrix grows faster than it becomes maintainable
- Mitigation: focus on owned seams and starter-flow proof, not exhaustive feature testing

## Security Considerations

- module and service tests must not depend on real credentials or external systems

## Next Steps

- Phase 06 optimizes runtime after the stronger verification model is in place.
