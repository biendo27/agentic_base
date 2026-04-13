# Phase 04: Close The Loop With Compatibility, Migration, And Metrics

## Context Links

- [Proposal overview](./plan.md)
- [Phase 03](./phase-03-turn-verification-and-release-into-first-class-contracts.md)
- [`docs/05-project-roadmap.md`](../../docs/05-project-roadmap.md)
- [`plans/260410-1755-generator-contract-hardening-and-parity/plan.md`](../260410-1755-generator-contract-hardening-and-parity/plan.md)

## Overview

- Priority: P1
- Status: Proposed
- Goal: make the v2 contract sustainable across external agents, upgrades, and future repo evolution.

## Key Insights

- A generator is only useful if existing projects can upgrade into the new contract.
- "Agent-ready" needs measurable outcomes, not just good-sounding docs.
- Compatibility should be won by common contracts, not tool-specific hacks.

## Requirements

- Add upgrade path for existing generated apps.
- Keep one canonical instruction source and fan out into vendor adapters.
- Define measurable outcomes for the new promise.
- Ensure docs, tests, and generated fixtures stay in sync.

## Architecture

- Upgrade contract:
  - `agentic_base upgrade` can reconcile generated docs/scripts/metadata without rewriting app code unexpectedly
- Compatibility contract:
  - canonical docs + metadata
  - generated vendor shims
  - deterministic scripts
- Measurement contract:
  - success metrics tracked in repo docs and regression checks

## Related Code Files

- Modify:
  - `lib/src/cli/commands/upgrade_command.dart`
  - `lib/src/generators/project_generator.dart`
  - `lib/src/generators/generated_project_contract.dart`
  - `docs/05-project-roadmap.md`
  - `docs/06-deployment-guide.md`
  - generated app fixture under `my_app/` where needed for parity validation

## Implementation Steps

1. Define what `upgrade` may rewrite and what it must leave alone.
2. Add migration coverage for older generated repos.
3. Add measurable metrics to roadmap/docs:
   - time to first successful agent verify
   - first-pass verify rate
   - manual-edit ratio before first release preflight
   - generated contract drift rate
4. Add parity checks for canonical docs, vendor shims, and scripts.
5. Refresh sample app fixture only after contract checks are green.

## Todo List

- [ ] Define safe upgrade scope
- [ ] Add migration tests for older outputs
- [ ] Add success metrics to docs and CI reporting
- [ ] Keep fixture app aligned with the new contract

## Success Criteria

- Existing generated apps can adopt the new contract with bounded, documented changes.
- At least two external agent surfaces can follow the generated repo without custom per-project docs.
- Repo-level docs and fixtures make drift visible quickly.

## Risk Assessment

- Risk: upgrade scope becomes too invasive and breaks user-owned code.
- Mitigation: restrict upgrade to generator-owned files and require explicit opt-in for anything broader.

## Security Considerations

- Upgrade flows must never overwrite secret files.
- Generated instructions must clearly separate agent-owned files from human-managed credentials.

## Next Steps

- After this phase, `agentic_base` can honestly market itself as a generator for agent-ready repos rather than a generic AI-codegen promise.
