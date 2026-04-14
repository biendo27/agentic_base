# Phase 01: Define Harness Contract V1

## Context Links

- [Plan overview](./plan.md)
- [Brainstorm report](../reports/brainstorm-260414-1119-harness-first-flutter-agentic-base-direction.md)
- [System architecture](../../docs/04-system-architecture.md)
- [Harness contract doc](../../docs/08-harness-contract-v1.md)

## Overview

- Priority: P1
- Status: Completed
- Goal: define the minimum truthful product contract for a harness-first generated repo.

## Key Insights

- The current repo already has a scaffold contract, but not a full harness contract.
- "Agent-ready" is too vague for future work unless turned into explicit invariants.
- If the contract stays fuzzy, docs and implementation will drift again.

## Requirements

<!-- Updated: Validation Session 1 - keep .info/agentic.yaml as the single machine-readable source of truth -->
- Define what every generated repo must expose for agents to understand, run, verify, and release it.
- Separate mandatory core contract from optional capability packs.
- Keep `.info/agentic.yaml` as the single machine-readable source of truth for the harness contract.
- Preserve explicit human approval boundaries.
- Keep the contract enforceable by scripts/tests, not prose only.

## Architecture

<!-- Updated: Validation Session 1 - contract core must preserve one machine-readable config surface -->
- Contract should have a small stable core:
  - canonical knowledge surface
  - one machine-readable source of truth in `.info/agentic.yaml`
  - deterministic entrypoints
  - run/eval/release states
  - ownership boundaries
  - human checkpoints
  - evidence expectations
- Contract should not yet encode cross-stack abstractions that Flutter does not need.

## Related Code Files

- Modify:
  - `/Users/biendh/base/README.md`
  - `/Users/biendh/base/docs/01-project-overview-pdr.md`
  - `/Users/biendh/base/docs/04-system-architecture.md`
  - `/Users/biendh/base/lib/src/config/agent_ready_repo_contract.dart`
  - `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`
- Create:
  - `/Users/biendh/base/docs/08-harness-contract-v1.md`
- Delete:
  - None expected

## Implementation Steps

1. Inventory the current scaffold contract and its already-enforced invariants.
2. Define the minimal harness-first contract in terms of hard guarantees and explicit non-goals.
3. Split contract clauses into:
   - required core
   - optional capability-linked clauses
   - human-only gates
4. Define which clauses must become executable checks.
5. Document the contract in one canonical doc and align code/docs terminology.

## Todo List

- [x] Inventory current contract clauses and gaps
- [x] Define required harness core clauses
- [x] Define explicit non-goals and boundaries
- [x] Mark which clauses need mechanical enforcement
- [x] Align terminology across docs and config code

## Success Criteria

- A generated repo can be evaluated against a finite list of harness guarantees.
- The contract is small enough to stay legible.
- The contract does not overclaim unsupported autonomy.

## Risk Assessment

- Risk: contract becomes a manifesto instead of an enforceable product boundary.
- Mitigation: every clause must map to code, script, template, or test work.

## Security Considerations

- Keep secrets, signing, and final publish approval explicitly human-owned.
- Avoid contract clauses that imply unattended production release authority.

## Next Steps

- Phase 02 turns the contract into support tiers and manifest shape.
