# Phase 05 - Lock Tests Docs Migration And Rollout

## Context Links

- [Phase 01](./phase-01-freeze-observability-contract-and-support-envelope.md)
- [Phase 02](./phase-02-add-runtime-observability-baseline-to-generated-repos.md)
- [Phase 03](./phase-03-add-telemetry-export-and-inspection-surfaces.md)
- [Phase 04](./phase-04-add-agent-legible-operator-reports-and-approval-traces.md)
- [Project Roadmap](../../docs/05-project-roadmap.md)

## Overview

- Priority: P0
- Current status: Pending
- Brief description: Lock the observability wave with contract tests, generated smoke coverage, migration guidance, and rollout guardrails.

## Key Insights

- Observability work will drift fast if docs, schema, and bundle validators do not move together.
- Existing generated repos need an honest migration path because this wave extends the contract shape.
- Rollout should stay incremental even though the roadmap is one umbrella plan.

## Requirements

### Functional Requirements

- Add regression tests for:
  - manifest observability shape
  - generated contract validation
  - runtime telemetry artifacts
  - inspect command and run-ledger rendering
  - generated smoke and verify integration
- Update package docs and generated-repo docs.
- Add migration guidance and verification checklist for older repos.
- Define rollout order by phase, not one risky flag day.

### Non-Functional Requirements

- Truthful docs
- Cheap enough CI coverage
- Safe additive migration

## Architecture

- Tests prove the contract at package, generator, and generated-repo levels.
- Docs explain what is supported locally, what is advisory, and what remains future work.
- Migration stays additive and manual-first unless proven safe later.

## Related Code Files

### Files To Modify

- [test/src/config/project_metadata_test.dart](/Users/biendh/base/test/src/config/project_metadata_test.dart)
- [test/src/generators/project_generator_test.dart](/Users/biendh/base/test/src/generators/project_generator_test.dart)
- [test/integration/generated_app_smoke_test.dart](/Users/biendh/base/test/integration/generated_app_smoke_test.dart)
- [docs/05-project-roadmap.md](/Users/biendh/base/docs/05-project-roadmap.md)
- [CHANGELOG.md](/Users/biendh/base/CHANGELOG.md)

### Files To Create

- [test/src/cli/commands/inspect_command_test.dart](/Users/biendh/base/test/src/cli/commands/inspect_command_test.dart)
- [test/src/observability/run_ledger_test.dart](/Users/biendh/base/test/src/observability/run_ledger_test.dart)
- [docs/19-observability-rollout-migration-guide.md](/Users/biendh/base/docs/19-observability-rollout-migration-guide.md)

### Files To Delete

- none expected

## Implementation Steps

1. Add package and generated-repo regression coverage.
2. Update package and generated docs together.
3. Write migration guide and verification checklist for legacy repos.
4. Roll out phase-by-phase through focused Gitflow branches and CI-backed PRs.

## Todo List

- [ ] Add observability contract tests
- [ ] Add inspect and ledger tests
- [ ] Add generated smoke coverage for observability artifacts
- [ ] Update docs and roadmap
- [ ] Add migration guide and rollout checklist

## Success Criteria

- CI fails if observability shape drifts from docs or validators.
- Older repos have a credible migration story.
- Rollout can happen incrementally without one risky cutover.

## Risk Assessment

- Risk: runtime and CLI observability evolve unevenly and leave the contract half-true.
- Mitigation: gate rollout on cross-layer tests and migration docs.

## Security Considerations

- Tests and sample artifacts must use redacted fixtures only.
- Migration guidance must explicitly prohibit copying credentials into observability config.

## Next Steps

- After plan approval, implement by phase order and validate after each phase before widening rollout.
