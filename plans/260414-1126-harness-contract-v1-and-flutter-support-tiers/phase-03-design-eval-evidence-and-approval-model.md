# Phase 03: Design Eval, Evidence, And Approval Model

## Context Links

- [Plan overview](./plan.md)
- [Phase 01](./phase-01-define-harness-contract-v1.md)
- [Phase 02](./phase-02-define-support-tier-matrix-and-manifest-schema.md)
- [Eval and evidence model](../../docs/11-eval-and-evidence-model.md)
- [Approval state machine](../../docs/12-approval-state-machine.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: define what evidence a generated repo must produce for agent runs and where human approval interrupts autonomy.

## Key Insights

- `analyze + test` is necessary but not sufficient for harness reliability.
- Agents need artifacts they can inspect and compare, not only exit codes.
- Human checkpoints must be explicit stopping conditions, not cultural expectations.

## Requirements

<!-- Updated: Validation Session 1 - quality should stay multi-dimensional in v1 -->
- Define eval ladder levels for generated repos.
- Define evidence bundle outputs for each meaningful run.
- Define approval state machine and human review boundaries.
- Define quality as multiple internal dimensions in v1 instead of one public scalar.
- Keep the model lightweight enough for default usage.

## Architecture

- Eval model should likely tier checks:
  - static
  - unit/widget
  - integration/smoke
  - native readiness
  - release readiness
- Evidence model should define canonical output paths and summary payloads.
- Quality should likely be modeled across multiple internal dimensions:
  - correctness
  - release-readiness
  - observability
  - UX confidence
- Approval model should define where an agent must pause:
  - product-significant direction changes
  - credential/signing setup
  - final production publish

## Related Code Files

- Modify:
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release-preflight.sh`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release.sh`
  - `/Users/biendh/base/lib/src/config/agent_ready_repo_contract.dart`
  - `/Users/biendh/base/docs/06-deployment-guide.md`
- Create:
  - `/Users/biendh/base/docs/11-eval-and-evidence-model.md`
  - `/Users/biendh/base/docs/12-approval-state-machine.md`
- Delete:
  - None expected

## Implementation Steps

1. Define the eval ladder and minimum default gate set.
2. Define evidence bundle shape and canonical paths.
3. Define approval states and transitions.
4. Map each contract clause to an eval or approval gate where relevant.
5. Identify which current scripts can evolve and which need new outputs.

## Todo List

- [x] Define eval ladder
- [x] Define evidence bundle schema
- [x] Define approval state machine
- [x] Map contract clauses to gates
- [x] Identify script changes and new artifacts

## Success Criteria

- Generated repos have a concrete answer to "what proves this run is trustworthy?"
- Human pause points are finite, explicit, and product-relevant.
- The model is compatible with both local runs and CI runs.
- The quality model avoids fake precision by staying multi-dimensional in v1.

## Risk Assessment

- Risk: evidence model becomes too heavy and slows routine work.
- Mitigation: define a minimum default bundle and optional richer artifacts.

## Security Considerations

- Evidence bundles must not capture secrets by default.
- Approval states must not blur the boundary between build/upload and final publish.

## Next Steps

- Phase 04 binds the model to Flutter-specific runtime and versioning constraints.
