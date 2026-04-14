# Phase 05: Add Regression Gates And Resync Product Docs

## Context Links

- [Plan overview](./plan.md)
- [Phase 04](./phase-04-finish-runtime-bootstrap-integrations-and-firebase-seams.md)
- [Review findings snapshot](./reports/agent-ready-review-findings.md)
- [`docs/05-project-roadmap.md`](../../docs/05-project-roadmap.md)

## Overview

- Priority: P0
- Status: Proposed
- Goal: make the repaired contract provable and stop docs from outrunning executable reality again.

## Key Insights

- `dart analyze` and `dart test` already pass today, which proves the current verify ladder does not protect the critical promises.
- The missing evidence is concrete: no `init` parity smoke, weak provider deploy proof, thin runtime module coverage, and root docs drift.
- If roadmap/docs remain ahead of reality, the repo will reintroduce the same trust problem even after code fixes.

## Requirements

- Add regression coverage for `init` contract parity, provider deploy mapping, deterministic dependency installs, and runtime bootstrap seams.
- Ensure generated output tests prove behavior after generation, not only in source templates.
- Resync README, architecture, deployment, and roadmap docs to the repaired contract.
- Remove or fix broken links, overstated completion language, and misleading `upgrade` descriptions.

## Architecture

- The verify ladder must include package tests plus generated-output contract/smoke assertions for the repaired areas.
- Docs updates should be treated as contract sync, not marketing copy.
- Roadmap completion language must follow evidence, not intent.

## Related Code Files

- Modify:
  - `/Users/biendh/base/test/**/*.dart`
  - `/Users/biendh/base/README.md`
  - `/Users/biendh/base/docs/01-project-overview-pdr.md`
  - `/Users/biendh/base/docs/04-system-architecture.md`
  - `/Users/biendh/base/docs/05-project-roadmap.md`
  - `/Users/biendh/base/docs/06-deployment-guide.md`
  - `/Users/biendh/base/my_app/**`

## Implementation Steps

1. Add test coverage for every repaired breach, using generated output where possible.
2. Refresh fixture apps or smoke fixtures only after the new contract tests pass.
3. Rewrite public docs and roadmap language to match the verified product boundary.
4. Add checklist-style regression assertions for future claim-sensitive changes.
5. Re-run the full local verify ladder and record the outcome in docs if needed.

## Todo List

- [ ] Add missing contract/smoke tests
- [ ] Refresh fixtures under the repaired contract
- [ ] Fix broken links and overstated claims
- [ ] Update roadmap and deployment docs to reflect actual state
- [ ] Re-run and record the full verify ladder

## Success Criteria

- The repo cannot regress these trust gaps without failing tests or smoke checks.
- Public docs no longer claim completed capability without executable evidence.
- The final verdict can honestly say the generator is agent-ready, or it can say exactly what still blocks it.

## Risk Assessment

- Risk: docs are updated before tests prove the behavior.
- Mitigation: treat docs sync as the final phase, never the first fix.

## Security Considerations

- Docs must keep human-only boundaries explicit around credentials, signing, and final publish approval.
- Regression tests must not require live secrets to prove contract honesty.

## Next Steps

- After this phase, rerun the same review standard used in the original audit and compare verdicts directly.
