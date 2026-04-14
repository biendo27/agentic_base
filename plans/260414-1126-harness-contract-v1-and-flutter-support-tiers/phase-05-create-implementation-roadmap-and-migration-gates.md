# Phase 05: Create Implementation Roadmap And Migration Gates

## Context Links

- [Plan overview](./plan.md)
- [Phase 01](./phase-01-define-harness-contract-v1.md)
- [Phase 02](./phase-02-define-support-tier-matrix-and-manifest-schema.md)
- [Phase 03](./phase-03-design-eval-evidence-and-approval-model.md)
- [Phase 04](./phase-04-design-flutter-adapter-boundaries-and-versioning-policy.md)
- [Project roadmap](../../docs/05-project-roadmap.md)
- [Scout report](./reports/scout-report.md)
- [Red-team review](./reports/red-team-review.md)
- [Research summary](./research/research-summary.md)

## Overview

- Priority: P1
- Status: Completed
- Goal: translate the design work into a staged implementation roadmap that does not destabilize the current generator.

## Key Insights

<!-- Updated: Validation Session 1 - remove obsolete-plan dependency from rollout framing -->
- The repo already ships a meaningful contract; migration must preserve honesty throughout.
- Design decisions without rollout sequencing will cause overlapping refactors.
- Harness evolution still needs a controlled migration path, not a rewrite fantasy.

## Requirements

- Break implementation into sequenced phases with low-regret ordering.
- Define migration gates so product claims stay truthful during rollout.
- Identify what can ship incrementally vs what must land atomically.
- Define rollback and success criteria for each implementation phase.

## Architecture

- Rollout should likely progress:
  - contract docs and invariants first
  - manifest/schema changes second
  - eval/evidence changes third
  - Flutter adapter/versioning changes fourth
  - public claim updates last
- Docs and roadmap updates should be gated by executed code/tests, not intent.

## Related Code Files

- Modify:
  - `/Users/biendh/base/docs/05-project-roadmap.md`
  - `/Users/biendh/base/README.md`
  - `/Users/biendh/base/docs/01-project-overview-pdr.md`
- Create:
  - `/Users/biendh/base/plans/260414-1126-harness-contract-v1-and-flutter-support-tiers/reports/red-team-review.md`
  - `/Users/biendh/base/plans/260414-1126-harness-contract-v1-and-flutter-support-tiers/research/research-summary.md`
  - `/Users/biendh/base/plans/260414-1126-harness-contract-v1-and-flutter-support-tiers/reports/scout-report.md`
- Delete:
  - None expected

## Implementation Steps

1. Order the implementation waves to minimize contract churn and docs drift.
2. Define entry and exit gates for each wave.
3. Define what can remain behind flags or tier labels during migration.
4. Define when existing product language may be updated.
5. Capture rollout risks and rollback rules.

## Todo List

- [x] Sequence implementation waves
- [x] Define migration gates
- [x] Define incremental vs atomic changes
- [x] Define docs-claim update policy
- [x] Define rollback rules

## Success Criteria

- The future implementation can start without re-litigating core product direction.
- Migration order reduces repo-wide churn.
- Product claims stay honest at every intermediate state.

## Risk Assessment

- Risk: roadmap becomes too broad and loses execution value.
- Mitigation: keep each wave outcome concrete, testable, and claim-sensitive.

## Security Considerations

- Migration must preserve current human-only credential and publish boundaries.
- Rollout steps must avoid creating transient states that imply unsafe release autonomy.

## Next Steps

- Use this plan as the prerequisite for any implementation work on Harness Contract V1.
