# Phase 01: Freeze Truthful Contract and Test Surfaces

## Context Links

- [Plan Overview](./plan.md)
- [Research Summary](./research/research-summary.md)
- [Scout Report](./reports/scout-report.md)
- [Harness Contract Docs Test](/Users/biendh/base/test/src/docs/harness_contract_documentation_test.dart)
- [Generated Project Contract](/Users/biendh/base/lib/src/generators/generated_project_contract.dart)

## Overview

- Priority: P0
- Status: Complete
- Goal: keep findings 1 and 2 closed by hardening regression guards instead of reopening wide doc rewrites

<!-- Updated: Validation Session 1 - findings 1 and 2 are guard-only -->

## Key Insights

- Root docs `08-13` are already truthful now.
- Generated testing docs already teach manager-aware wrappers.
- The gap is durability, not current wording.

## Requirements

- Preserve the shipped-state language in root contract docs.
- Preserve manager-aware testing guidance in generated docs and adapters.
- Add or tighten tests so a future edit cannot quietly reintroduce either finding.

## Architecture

- Treat root docs truthfulness and generated testing guidance as contract surfaces.
- Enforcement belongs in fast package tests and generated-project validators, not only manual review.

## Related Code Files

- Modify:
  - `/Users/biendh/base/test/src/docs/harness_contract_documentation_test.dart`
  - `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`
  - `/Users/biendh/base/test/src/generators/project_generator_test.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/06-testing-guide.md` only if wording still drifts after phase 03
- Create: none expected
- Delete: none

## Implementation Steps

1. Reconfirm the exact textual guarantees that define truthful root contract docs.
2. Tighten the docs test to cover any remaining stale phrase families or route mismatches discovered during implementation.
3. Keep generated-project validation strict on manager-aware testing commands and the absence of bare `flutter test`.
4. Add or update regression tests so the old findings fail fast without needing the heavy smoke lane.
5. Stop phase work once the guards are sufficient; do not reopen docs content broadly unless another phase creates real drift.

## Todo List

- [x] Reconfirm root doc truthfulness invariants
- [x] Tighten root docs regression test
- [x] Tighten generated testing-surface validation
- [x] Add focused regression assertions outside the heavy smoke suite

## Success Criteria

- Old findings 1 and 2 stay closed with explicit automated guards.
- No new wide doc rewrite is needed to keep the contract honest.

## Risk Assessment

- Risk: overfitting tests to exact prose.
- Mitigation: guard truth-critical phrases and command surfaces, not entire documents byte-for-byte.

## Security Considerations

- None beyond keeping human approval boundaries explicit in docs.

## Next Steps

- Phase 02 completed after the guard baseline was verified.
