# Phase 01 - Freeze Observability Contract And Support Envelope

## Context Links

- [Official Guidance Note](./research/official-observability-guidance.md)
- [Harness Contract V1](../../docs/08-harness-contract-v1.md)
- [Manifest Schema](../../docs/10-manifest-schema.md)
- [Eval And Evidence Model](../../docs/11-eval-and-evidence-model.md)
- [Flutter Adapter Boundaries](../../docs/13-flutter-adapter-boundaries.md)

## Overview

- Priority: P0
- Current status: Pending
- Brief description: Freeze what observability means in this repo so implementation stops drifting between run evidence, runtime signals, and agent traces.

## Key Insights

- `evidence_quality` is already canonical and should not be overloaded again.
- The missing gap is queryable runtime and run-legibility, not another evidence bundle rename.
- This repo is a generator package. It can ship local-first observability surfaces, not a hosted control plane.

## Requirements

### Functional Requirements

- Define one canonical observability vocabulary with explicit subdomains:
  - `runtime_observability`
  - `agent_legibility`
  - `operator_reports`
- Define which fields belong in `.info/agentic.yaml` and which stay doc-only.
- Freeze the minimum supported signals for V1.5:
  - structured logs
  - traces and correlation ids
  - bounded metrics counters and timings
- Define redaction and retention rules for observability artifacts.

### Non-Functional Requirements

- No overclaiming
- No hosted backend assumptions
- Contract must remain additive and generator-owned

## Architecture

- Harness core owns vocabulary, schema, artifact shape, and redaction policy.
- Flutter adapter owns app-side signal capture and export semantics.
- CLI layer owns inspect/report entrypoints.
- Approval trace semantics stay aligned with `docs/12`, not reinvented.

## Related Code Files

### Files To Modify

- [docs/08-harness-contract-v1.md](/Users/biendh/base/docs/08-harness-contract-v1.md)
- [docs/10-manifest-schema.md](/Users/biendh/base/docs/10-manifest-schema.md)
- [docs/11-eval-and-evidence-model.md](/Users/biendh/base/docs/11-eval-and-evidence-model.md)
- [docs/12-approval-state-machine.md](/Users/biendh/base/docs/12-approval-state-machine.md)
- [docs/13-flutter-adapter-boundaries.md](/Users/biendh/base/docs/13-flutter-adapter-boundaries.md)
- [lib/src/config/harness_metadata.dart](/Users/biendh/base/lib/src/config/harness_metadata.dart)
- [lib/src/config/project_metadata.dart](/Users/biendh/base/lib/src/config/project_metadata.dart)
- [lib/src/generators/generated_project_contract.dart](/Users/biendh/base/lib/src/generators/generated_project_contract.dart)

### Files To Create

- [docs/17-observability-contract.md](/Users/biendh/base/docs/17-observability-contract.md)

### Files To Delete

- none expected

## Implementation Steps

1. Freeze the observability support envelope and explicit non-goals.
2. Decide manifest additions versus doc-only read models.
3. Define artifact redaction, retention, and naming rules.
4. Update validators only after docs and schema are frozen.

## Todo List

- [ ] Freeze observability vocabulary and support envelope
- [ ] Freeze minimal supported signals
- [ ] Freeze manifest versus doc-only ownership
- [ ] Freeze redaction and retention rules
- [ ] Sync validators with the frozen contract

## Success Criteria

- The repo has one canonical definition of observability that does not regress `evidence_quality`.
- Manifest shape stays additive and testable.
- No doc implies a hosted operator platform exists.

## Risk Assessment

- Risk: mixing app runtime telemetry with agent transcript semantics.
- Mitigation: keep subdomains explicit and separately named.

## Security Considerations

- Never store secrets, bearer tokens, or raw PII in observability artifacts.
- Redaction policy must be generator-owned and inspectable.

## Next Steps

- Implement the generated-repo runtime baseline against the frozen contract.
