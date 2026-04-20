# Phase 05 - Lock Tests Docs Migration And Gitflow Delivery

## Context Links

- [Phase 01](./phase-01-freeze-product-contract-and-service-matrix.md)
- [Phase 02](./phase-02-implement-profile-presets-and-default-module-resolution.md)
- [Phase 03](./phase-03-implement-golden-path-runtime-seams-and-profile-aware-gates.md)
- [Phase 04](./phase-04-refresh-default-app-ui-system-and-starter-surfaces.md)
- [Code Standards](../../docs/03-code-standards.md)
- [Deployment Guide](../../docs/06-deployment-guide.md)

## Overview

- Priority: P0
- Current status: Complete
- Brief description: Lock the new contract with regression tests, generated-doc updates, migration notes, and a Gitflow-aware delivery sequence.

## Key Insights

- The product truth only holds if tests, docs, and generated surfaces all move together.
- The repo already uses Gitflow and should keep implementation work flowing into `develop`.
- This wave changes product claims, starter behavior, and verify logic at the same time, so regression-proofing matters.

## Requirements

### Functional Requirements

- Add regression tests for:
  - default profile resolution
  - profile-specific gate differences
  - starter runtime seams
  - generated docs and manifest drift
- Update generated repo docs and root docs
- Add migration guidance for existing generated repos with manual checklist and verification steps
- Do not build an auto-migrator in this wave

### Non-Functional Requirements

- Keep docs truthful
- Keep smoke lanes reliable
- Keep delivery sequencing clean

## Architecture

- Tests should prove:
  - profile changes are behavioral
  - Tier 1 vs Tier 2 differs mechanically
  - default app service matrix remains inspectable
- Delivery should follow Gitflow:
  - feature branches off `develop`
  - focused conventional commits
  - PR into `develop`
  - release branch only when the wave is ready

<!-- Updated: Validation Session 2 - regression tests, root docs, migration guidance, and rollout bookkeeping now match the shipped contract -->

## Related Code Files

### Files To Modify

- [test/integration/generated_app_smoke_test.dart](/Users/biendh/base/test/integration/generated_app_smoke_test.dart)
- [test/src/generators/project_generator_test.dart](/Users/biendh/base/test/src/generators/project_generator_test.dart)
- [docs/01-project-overview-pdr.md](/Users/biendh/base/docs/01-project-overview-pdr.md)
- [docs/02-codebase-summary.md](/Users/biendh/base/docs/02-codebase-summary.md)
- [docs/05-project-roadmap.md](/Users/biendh/base/docs/05-project-roadmap.md)
- [CHANGELOG.md](/Users/biendh/base/CHANGELOG.md)

### Files To Create

- generated-repo migration note if needed under root docs or plan reports

### Files To Delete

- none expected

## Implementation Steps

1. Add regression coverage for the new profile and gate behavior.
2. Update generated-doc templates and root docs together.
3. Document migration expectations for existing generated repos.
4. Stage implementation in focused Gitflow branches and conventional commits.
5. Keep release-preflight and deploy docs aligned with the new profile contract.

## Todo List

- [x] Add profile behavior regression tests
- [x] Add gate-difference regression tests
- [x] Update root and generated docs
- [x] Add migration guidance
- [x] Define implementation branch and commit strategy

## Success Criteria

- CI fails if profile behavior drifts back to metadata-only.
- Docs match generated behavior.
- Existing repos have an honest migration story.
- The implementation work is deliverable through Gitflow without ad hoc branching.

Status: met.

## Risk Assessment

- Risk: profile behavior lands in code but docs lag.
- Mitigation: treat docs and tests as part of the same delivery gate.

## Security Considerations

- Migration docs must not imply automatic credential carry-over.
- Evidence and docs must stay secret-free.

## Next Steps

- Rollout complete. Remaining follow-up is routine release hygiene and any future expansion of non-default profile coverage.
