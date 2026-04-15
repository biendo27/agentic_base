# Phase 06: Reduce Test Runtime Without Lowering Assurance

## Context Links

- [Plan overview](./plan.md)
- [Research summary](./research/research-summary.md)
- [Scout report](./reports/scout-report.md)

## Overview

- Priority: P1
- Status: Completed
- Goal: cut redundant heavy-path execution while preserving the final confidence model.

## Key Insights

- the main slowdown is repeated real project generation plus downstream verify/native gates
- speed work should remove duplicated work, not remove assurance
- many structural assertions can move from integration smoke to unit-level tests once coverage exists

## Requirements

- keep at least one true end-to-end generated repo lane per major surface
- move structural or manifest-only checks downward where possible
- reuse fixtures or generated outputs where assertions are identical
- preserve native-readiness and evidence semantics

## Architecture

- define a layered test strategy:
  - unit and command tests for contract logic
  - focused integration smoke for one real generated repo per surface
  - native-heavy lanes only where the assertion actually requires them
- gate optimization decisions by assertion ownership, not by convenience

## Related Code Files

- Modify:
  - `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`
  - `/Users/biendh/base/test/src/cli/...`
  - `/Users/biendh/base/test/src/generators/...`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh`
  - CI workflow files if the lane split changes
- Create:
  - fixture helpers or cached generated-app utilities if justified
- Delete:
  - duplicated heavy smoke cases no longer needed after lower-level coverage lands

## Implementation Steps

1. Classify every current heavy smoke assertion by the lowest safe test layer.
2. Move structural checks into command/generator unit tests where possible.
3. Collapse redundant end-to-end permutations.
4. Reuse fixtures or cached outputs only for assertions that do not depend on fresh generation.
5. Measure runtime before and after, and keep the evidence model intact.

## Todo List

- [x] Classify heavy smoke assertions
- [x] Move contract-only assertions downward
- [x] Collapse redundant permutations
- [x] Introduce safe fixture reuse if justified
- [x] Record runtime delta and residual risks

## Execution Notes

- completed in repo state as of 2026-04-15
- the retained heavy matrix is now intentionally limited to one cubit/github ownership lane, riverpod and mobx runtime lanes, module-specific generation lanes, and the pinned native gate
- more structural proof now lives in repo-level generator/contract tests instead of duplicate end-to-end assertions
- residual risk: generated-app create tests remain the dominant runtime cost because each retained lane still performs real generation plus downstream verify, but the remaining lanes each prove unique owned behavior

## Success Criteria

- local and CI test runtime improves materially
- no major assurance surface is removed
- heavy native and verify lanes remain where they still prove unique behavior

## Risk Assessment

- Risk: optimization silently weakens coverage
- Mitigation: define the retained assurance model before deleting any heavy path

## Security Considerations

- fixture reuse must not smuggle secrets or environment-specific artifacts into test data

## Next Steps

- Phase 07 updates generated docs and repo docs to reflect the final shipped contract and architecture.
