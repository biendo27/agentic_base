# Phase 02: Define Support Tier Matrix And Manifest Schema

## Context Links

- [Plan overview](./plan.md)
- [Phase 01](./phase-01-define-harness-contract-v1.md)
- [Brainstorm report](../reports/brainstorm-260414-1119-harness-first-flutter-agentic-base-direction.md)
- [Code standards](../../docs/03-code-standards.md)
- [Support tier matrix](../../docs/09-support-tier-matrix.md)
- [Manifest schema](../../docs/10-manifest-schema.md)

## Overview

- Priority: P1
- Status: Completed
- Goal: turn product scope into a truthful tiered support model and machine-readable manifest schema.

## Key Insights

- "Support all Flutter apps" is dishonest without support tiers.
- Each app needs one primary profile, not an all-profiles kitchen sink.
- Capability/provider selection belongs in configuration, not only in code seams.

## Requirements

<!-- Updated: Validation Session 1 - tier-2 guarantees stay core-only and schema stays in .info/agentic.yaml -->
- Define profile catalog for mainstream Flutter product apps.
- Define support tiers for v1 and what each tier guarantees.
- Define tier-2 as core-gates-only support with additional profile-specific checks treated as advisory unless proven later.
- Define `primary_profile` and `secondary_traits` semantics.
- Extend or reshape `.info/agentic.yaml` only as far as needed and keep it as the single machine-readable source of truth.

## Architecture

<!-- Updated: Validation Session 1 - do not create a second schema file yet -->
- Manifest should express:
  - app profile identity
  - secondary traits
  - enabled capabilities
  - selected providers
  - quality gates
  - approval gates
- Prefer evolving `.info/agentic.yaml` unless a separate schema file is clearly justified.
- Tier-2 semantics should inherit the core required gates only; any extra profile-specific checks should be documented as advisory rather than guaranteed.

## Related Code Files

- Modify:
  - `/Users/biendh/base/lib/src/config/agentic_config.dart`
  - `/Users/biendh/base/lib/src/config/project_metadata.dart`
  - `/Users/biendh/base/lib/src/config/agent_ready_repo_contract.dart`
  - `/Users/biendh/base/docs/01-project-overview-pdr.md`
  - `/Users/biendh/base/docs/05-project-roadmap.md`
- Create:
  - `/Users/biendh/base/docs/09-support-tier-matrix.md`
  - `/Users/biendh/base/docs/10-manifest-schema.md`
- Delete:
  - None expected

## Implementation Steps

1. Define supported profile catalog and support envelope.
2. Assign v1 support tiers with explicit guarantees and explicit exclusions.
3. Draft manifest schema examples for default, tier-1, and tier-2 apps.
4. Decide whether `.info/agentic.yaml` can carry the schema without becoming unreadable.
5. Record migration rules from the current metadata model.

## Todo List

- [x] Define profile catalog
- [x] Define tier guarantees and exclusions
- [x] Draft manifest schema
- [x] Decide config-file strategy
- [x] Document migration rules

## Success Criteria

- Product scope is honest and mechanically representable.
- One generated app can be classified without ambiguity.
- Tier-2 inherits only the core required gates and does not silently inherit tier-1 guarantees.

## Risk Assessment

- Risk: manifest grows into a second product spec the agent cannot reason about quickly.
- Mitigation: keep core fields short and push explanation into docs, not config.

## Security Considerations

- Provider fields must not encourage storing secrets in manifest state.
- Approval gates must remain declarative, not secret-bearing.

## Next Steps

- Phase 03 designs how the manifest and contract show up during runs and review loops.
