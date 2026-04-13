# Phase 02: Generate Canonical Agent Context And Thin Adapters

## Context Links

- [Plan overview](./plan.md)
- [Phase 01](./phase-01-reset-product-contract-and-canonical-repo-schema.md)
- [`docs/02-codebase-summary.md`](../../docs/02-codebase-summary.md)
- [`docs/03-code-standards.md`](../../docs/03-code-standards.md)
- [Red Team Review](./reports/red-team-review.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: generate one canonical context package and fan it out into thin agent-vendor adapters.

## Key Insights

- `AGENTS.md` must stay short and stable.
- Vendor-specific files should be generated from the same source or they will drift.
- Current template already proves drift exists across state profiles.

## Requirements

<!-- Updated: Validation Session 1 - adapter surface scope limited to AGENTS.md and CLAUDE.md in v1 -->
- Generate canonical long-form docs for repo understanding, execution rules, and release checkpoints.
- Keep `AGENTS.md` as a short TOC + command index.
- Keep `CLAUDE.md` as a thin adapter, not a second handbook.
- Limit v1 adapter support to `AGENTS.md` and `CLAUDE.md`; defer any extra surfaces such as Copilot-specific instructions.
- Preserve state-management parity across generated instruction surfaces.

## Architecture

<!-- Updated: Validation Session 1 - no extra adapter surfaces in v1 -->
- Canonical generated docs:
  - overview
  - architecture
  - execution and verify guide
  - release and human checkpoints
- Thin adapters:
  - `AGENTS.md`
  - `CLAUDE.md`
  - future adapters only after v1 and only if derived from the same source

## Related Code Files

- Modify:
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/AGENTS.md`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/CLAUDE.md`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/**`
  - `/Users/biendh/base/lib/src/generators/project_generator.dart`
  - `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`

## Implementation Steps

1. Define generated-doc structure owned by the app brick.
2. Refactor `AGENTS.md` into TOC + command index + links only.
3. Refactor `CLAUDE.md` into thin adapter content tied to the same canonical source.
4. Remove state-specific misinformation from adapters.
5. Extend smoke tests to assert adapter/docs parity for cubit, riverpod, and mobx.

## Todo List

- [x] Define canonical generated-doc structure
- [x] Thin down `AGENTS.md`
- [x] Thin down `CLAUDE.md`
- [x] Add state-parity assertions for context surfaces

## Success Criteria

- Generated agent context is stable, small, and consistent across state profiles.
- `AGENTS.md` and `CLAUDE.md` no longer behave like conflicting manuals.
- Future adapter expansion can happen without duplicating knowledge.

## Risk Assessment

- Risk: too much generated prose becomes stale again.
- Mitigation: keep adapters thin and move all detailed context into a few canonical docs.

## Security Considerations

- Generated docs must distinguish repo-owned instructions from user-managed secrets and credentials.

## Next Steps

- Phase 03 adds deterministic harness scripts and the verify ladder those docs point to.
