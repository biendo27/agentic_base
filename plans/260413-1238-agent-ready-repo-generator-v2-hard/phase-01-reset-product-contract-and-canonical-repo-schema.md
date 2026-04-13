# Phase 01: Reset Product Contract And Canonical Repo Schema

## Context Links

- [Plan overview](./plan.md)
- [Agent Engineering Patterns](./research/researcher-01-agent-engineering-patterns.md)
- [Current Repo Gap Analysis](./research/researcher-02-current-repo-gap-analysis.md)
- [`README.md`](../../README.md)
- [`docs/04-system-architecture.md`](../../docs/04-system-architecture.md)
- [`docs/05-project-roadmap.md`](../../docs/05-project-roadmap.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: make the product honest and define one canonical v2 repo contract before changing templates.

## Key Insights

- Repo already has the generator primitives. Contract honesty is the real missing layer.
- The repo needs one canonical schema that drives docs, adapters, scripts, and validation.
- Product copy must stop implying unsupported intelligence.

## Requirements

<!-- Updated: Validation Session 1 - canonical context split locked --> 
- Reframe repo and generated-app docs around `agent-ready repo`.
- Define canonical schema where `.info/agentic.yaml` is machine-readable source of truth, generated `docs/` is canonical human-readable context, and adapters stay derived.
- Keep command names stable while updating semantics and help text.
- Add contract tests that fail when docs overclaim unsupported behavior.

## Architecture

<!-- Updated: Validation Session 1 - canonical source-of-truth boundaries confirmed -->
- Canonical surfaces:
  - `.info/agentic.yaml` for machine-readable schema and execution metadata
  - generated app docs under `docs/` for canonical human-readable context
  - contract assertions in `GeneratedProjectContract`
- Derived surfaces:
  - `AGENTS.md` as thin adapter
  - `CLAUDE.md` as thin adapter
  - command help text

## Related Code Files

- Modify:
  - `/Users/biendh/base/README.md`
  - `/Users/biendh/base/docs/01-project-overview-pdr.md`
  - `/Users/biendh/base/docs/04-system-architecture.md`
  - `/Users/biendh/base/docs/05-project-roadmap.md`
  - `/Users/biendh/base/lib/src/config/agentic_config.dart`
  - `/Users/biendh/base/lib/src/generators/project_generator.dart`
  - `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`
  - `/Users/biendh/base/lib/src/cli/cli_runner.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`

## Implementation Steps

1. Define v2 schema fields for context, checkpoints, and execution commands.
2. Rewrite repo README and roadmap around the new promise.
3. Rewrite generated app README to match the same promise.
4. Update command descriptions/help text to remove unsupported AI claims.
5. Add contract assertions for required schema keys and forbidden claims.

## Todo List

- [x] Define canonical v2 schema
- [x] Align repo docs
- [x] Align generated app docs
- [x] Align CLI help text
- [x] Add contract tests for honesty rules

## Success Criteria

- A new reader can tell in minutes that the product generates agent-ready repos, not AI-autonomous features.
- v2 schema exists and is the single source of truth for later phases.
- Drift between repo docs, generated docs, and CLI help becomes test-visible.

## Risk Assessment

- Risk: too much wording churn without enough structural change.
- Mitigation: make the schema and contract tests land in the same phase.

## Security Considerations

- No remote execution or secret handling changes yet.
- Keep metadata declarative and non-sensitive.

## Next Steps

- Phase 02 generates thin adapters and canonical context from the new schema.
