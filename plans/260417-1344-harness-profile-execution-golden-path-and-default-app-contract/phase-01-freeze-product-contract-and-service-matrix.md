# Phase 01 - Freeze Product Contract And Service Matrix

## Context Links

- [Thin-But-Hard Harness Criteria And Repo Checklist](../reports/brainstorm-260417-1145-thin-but-hard-harness-criteria-and-repo-checklist.md)
- [Project Overview PDR](../../docs/01-project-overview-pdr.md)
- [Support Tier Matrix](../../docs/09-support-tier-matrix.md)
- [Manifest Schema](../../docs/10-manifest-schema.md)
- [Eval And Evidence Model](../../docs/11-eval-and-evidence-model.md)

## Overview

- Priority: P0
- Current status: Complete
- Brief description: Freeze the canonical V1 decisions so implementation stops drifting between docs, brainstorm notes, and generator behavior.

## Key Insights

- The repo already has a strong harness core.
- The biggest truth gap is profile metadata vs executable behavior.
- `subscription-commerce-app` is now the agreed default and golden path.
- Thin base and golden path must stay separate concepts.
- Validation fixed the rename to `evidence_quality` as a breaking change in this wave.

## Requirements

### Functional Requirements

- Define one canonical default V1 profile: `subscription-commerce-app`
- Define one canonical golden-path preset for that profile
- Define thin-base default services vs profile-owned default-on services vs opt-in-only services
- Rename `observability` to `evidence_quality`

### Non-Functional Requirements

- No overclaiming
- Contract language must stay testable
- Product rules must fit the current generator model

## Architecture

- Harness core owns:
  - profile identity
  - support-tier rules
  - default module and service policy
  - evidence vocabulary
- Flutter adapter owns:
  - how starter output changes by profile
  - how verify and release-preflight differ by profile
- Capability packs own:
  - provider runtime
  - extra seams
  - manual setup notes

<!-- Updated: Validation Session 1 - phase complete; `observability` becomes `evidence_quality` everywhere in this wave -->

## Related Code Files

### Files To Modify

- [README.md](/Users/biendh/base/README.md)
- [docs/01-project-overview-pdr.md](/Users/biendh/base/docs/01-project-overview-pdr.md)
- [docs/08-harness-contract-v1.md](/Users/biendh/base/docs/08-harness-contract-v1.md)
- [docs/09-support-tier-matrix.md](/Users/biendh/base/docs/09-support-tier-matrix.md)
- [docs/10-manifest-schema.md](/Users/biendh/base/docs/10-manifest-schema.md)
- [docs/11-eval-and-evidence-model.md](/Users/biendh/base/docs/11-eval-and-evidence-model.md)
- [lib/src/config/harness_profile.dart](/Users/biendh/base/lib/src/config/harness_profile.dart)

### Files To Create

- [docs/15-default-app-service-matrix.md](/Users/biendh/base/docs/15-default-app-service-matrix.md)

### Files To Delete

- none expected

## Implementation Steps

1. Freeze the product language for thin base, golden path, Tier 1, Tier 2, and default V1 profile.
2. Define the service matrix with three buckets:
   - thin base
   - subscription-commerce default-on
   - opt-in only
3. Rename `observability` to `evidence_quality` in docs, schema, summaries, and generated contract language.
4. Update root docs so the product story is canonical in one place.
5. Update code-level enums, summaries, and constants only after the docs are frozen.

## Todo List

- [x] Freeze default V1 profile and golden-path wording
- [x] Freeze default service and module matrix
- [x] Rename `observability` to `evidence_quality`
- [x] Sync root docs with the frozen product rules
- [x] Sync `harness_profile.dart` summaries and defaults

## Success Criteria

- The repo has one canonical answer for what the default app contains.
- Thin base vs golden path is explicit and non-contradictory.
- No doc implies agent telemetry if the repo only ships run evidence under `evidence_quality`.

Status: met.

## Risk Assessment

- Biggest risk: docs say more than code can enforce.
- Mitigation: freeze contract first, then implement only what the contract now promises.

## Security Considerations

- Do not move secrets or provider credentials into manifest or evidence surfaces.
- Keep consent, monetization, and crash/analytics boundaries explicit.

## Next Steps

- Feed the frozen service matrix into preset resolution logic.
- Use the same matrix to drive starter runtime seams and generated docs.
