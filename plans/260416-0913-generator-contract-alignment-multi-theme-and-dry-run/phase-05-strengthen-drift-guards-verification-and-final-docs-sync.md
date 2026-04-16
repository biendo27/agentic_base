# Phase 05 — Strengthen Drift Guards, Verification, And Final Docs Sync

## Context Links

- [plan.md](./plan.md)
- [scout-report](./reports/scout-report.md)
- [red-team-review](./reports/red-team-review.md)
- [Generated Project Contract](</Users/biendh/base/lib/src/generators/generated_project_contract.dart>)
- [CLI command tests](/Users/biendh/base/test/src/cli/commands)

## Overview

- Priority: P0
- Status: Pending
- Goal: prevent the same categories of drift from returning after the implementation wave lands.

## Key Insights

- recent regressions were not mainly missing features; they were command/docs/contract drift.
- generated docs and command behavior need mechanical tests, not prose promises only.
- theme extensibility and failure modeling need regression proof.
<!-- Updated: Validation Session 1 - drift guards must lock preview-only dry-run semantics and snapshot-doc removal -->

## Requirements

- add or expand tests for docs/contract drift, dry-run output, toolchain honesty, and generated app architecture invariants
- keep test runtime reasonable
- finish with one docs sync pass after code stabilizes

## Architecture

- test layers:
  - unit tests for shared dry-run and toolchain helpers
  - command tests for dry-run/no-side-effect behavior
  - generator contract tests for generated docs/theme/contracts
  - generated app smoke checks only where structural proof is impossible at lower layers
- docs sync:
  - root README/docs aligned last
  - generated README/docs aligned last

## Related Code Files

- Modify:
  - [test/src/cli/commands](</Users/biendh/base/test/src/cli/commands>)
  - [test/src/config](</Users/biendh/base/test/src/config>)
  - [test/src/generators/project_generator_test.dart](/Users/biendh/base/test/src/generators/project_generator_test.dart)
  - [test/integration/generated_app_smoke_test.dart](/Users/biendh/base/test/integration/generated_app_smoke_test.dart)
  - [Generated Project Contract](</Users/biendh/base/lib/src/generators/generated_project_contract.dart>)
  - final root/generated docs touched by Phases 01-04

## Implementation Steps

1. Add regression tests for dry-run behavior and zero side effects.
2. Add command tests for manager-aware `eval` and `doctor`.
3. Add generator contract tests for theme-family surfaces, locale wrapper ownership, failure model expectations, and absence of deleted snapshot docs from canonical root docs.
4. Reduce any redundant heavy smoke lanes if lower-level tests now prove the same invariant.
5. Perform one final root/generated docs sync pass after tests are green.

## Todo List

- [ ] add dry-run regression tests
- [ ] add `eval`/`doctor` honesty tests
- [ ] add generated app contract tests
- [ ] trim redundant heavy smoke coverage if possible
- [ ] perform final docs sync

## Success Criteria

- regressions in docs/command/theme/contract drift are caught by tests
- final doc wording matches actual shipped behavior
- test runtime stays bounded while coverage meaning improves

## Risk Assessment

- final docs sync can easily reintroduce drift if done before code/tests settle
- over-trimming smoke tests can remove real guarantees

## Security Considerations

- keep dry-run and docs examples secret-safe
- keep evidence/log tests from asserting sensitive output

## Next Steps

- implementation can begin once validation answers are propagated into this plan set
