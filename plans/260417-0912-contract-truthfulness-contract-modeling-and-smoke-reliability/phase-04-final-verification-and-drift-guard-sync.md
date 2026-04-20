# Phase 04: Final Verification and Drift Guard Sync

## Context Links

- [Plan Overview](./plan.md)
- [Research Summary](./research/research-summary.md)
- [Scout Report](./reports/scout-report.md)

## Overview

- Priority: P0
- Status: Complete
- Goal: close the wave with fast proof, truthful docs, and stable enforcement

## Key Insights

- This wave is not done when code changes land; it is done when docs, validators, and tests all tell the same story.
- Findings 1 and 2 are already fixed, so the close-out must ensure they stay fixed after phases 02-03.
- Fast lane is the universal blocking gate; the slow canary is conditionally blocking by validated policy.

<!-- Updated: Validation Session 1 - close-out must reflect conditional slow-canary policy -->

## Requirements

- Re-run the focused package tests and smoke suite needed by this wave.
- Re-sync any root/generated docs touched by the contract-model or smoke-lane changes.
- Keep generated-project validation aligned with the final gate vocabulary and command surface.

## Architecture

- Close-out uses layered proof:
  - fast unit/package tests for doc and contract drift
  - focused generated-project validation
  - targeted smoke run for the heavy canary plus parity cases
- Final close-out record must say when the slow canary is required to block:
  - harness
  - verify
  - evidence
  - native-readiness changes

## Related Code Files

- Modify:
  - `/Users/biendh/base/test/src/docs/harness_contract_documentation_test.dart` if needed
  - `/Users/biendh/base/test/src/generators/project_generator_test.dart`
  - `/Users/biendh/base/README.md` only if phase outputs materially change the public repo story
  - generated docs only if phase outputs materially change the generated repo story
- Create: none expected
- Delete: none

## Implementation Steps

1. Run the focused test packs for docs, contract models, generator validation, and smoke.
2. Sync any doc wording that changed because of phase 02 or 03 decisions.
3. Verify that the old findings do not reappear in root docs, generated docs, or validators.
4. Record the final verification command set so the next reviewer can reproduce it quickly.
5. Record the conditional slow-canary policy in the close-out notes or supporting docs if implementation makes it user-facing.

## Todo List

- [x] Run focused doc/contract/generator tests
- [x] Run targeted smoke verification
- [x] Sync final docs and validators
- [x] Record final verification pack
- [x] Record conditional slow-canary policy

## Success Criteria

- All four findings are closed by code, docs, or explicit regression guards.
- The close-out verification pack is shorter and more confidence-building than before this wave.

## Risk Assessment

- Risk: final docs drift from last-minute code decisions.
- Mitigation: sync docs in the same phase as the final verification pass.

## Security Considerations

- Preserve explicit human approval boundaries and release-preflight expectations while changing smoke coverage.

## Next Steps

- No follow-up plan should be needed unless validation chooses a broader smoke-matrix policy.
