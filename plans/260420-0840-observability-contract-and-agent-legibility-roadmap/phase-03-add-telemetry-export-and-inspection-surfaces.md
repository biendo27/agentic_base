# Phase 03 - Add Telemetry Export And Inspection Surfaces

## Context Links

- [Phase 02](./phase-02-add-runtime-observability-baseline-to-generated-repos.md)
- [Eval And Evidence Model](../../docs/11-eval-and-evidence-model.md)
- [Approval State Machine](../../docs/12-approval-state-machine.md)

## Overview

- Priority: P0
- Current status: Pending
- Brief description: Extend evidence bundles and package CLI surfaces so runtime telemetry becomes queryable, not just emitted.

## Key Insights

- Current bundles already capture commands, checks, summaries, and logs.
- The next step is structured telemetry export plus deterministic inspection, not a hosted dashboard.
- Agents and humans both need one inspectable path for latest-run context.

## Requirements

### Functional Requirements

- Extend evidence bundles with structured telemetry payloads:
  - logs
  - spans
  - metric snapshots
  - approval-state timeline fragments
- Add package-side inspect/report entrypoints for latest-run and specific bundle inspection.
- Add generated-repo helper scripts for local evidence inspection.
- Keep output deterministic and machine-readable.

### Non-Functional Requirements

- Local-first
- Scriptable
- Secret-safe

## Architecture

- `artifacts/evidence/...` stays canonical.
- New structured payloads live beside `summary.json` and `checks/*.json`, not in ad hoc locations.
- Package CLI adds one inspect/report command family instead of many one-off commands.
- Generated shell helpers render from one policy shared with the package validator.

## Related Code Files

### Files To Modify

- [lib/src/cli/cli_runner.dart](/Users/biendh/base/lib/src/cli/cli_runner.dart)
- [lib/src/cli/commands/eval_command.dart](/Users/biendh/base/lib/src/cli/commands/eval_command.dart)
- [lib/src/cli/commands/doctor_command.dart](/Users/biendh/base/lib/src/cli/commands/doctor_command.dart)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/_common.sh](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/_common.sh)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release-preflight.sh](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release-preflight.sh)
- [lib/src/generators/generated_project_contract.dart](/Users/biendh/base/lib/src/generators/generated_project_contract.dart)

### Files To Create

- [lib/src/cli/commands/inspect_command.dart](/Users/biendh/base/lib/src/cli/commands/inspect_command.dart)
- [lib/src/observability/run_event_reporter.dart](/Users/biendh/base/lib/src/observability/run_event_reporter.dart)
- [lib/src/observability/telemetry_bundle.dart](/Users/biendh/base/lib/src/observability/telemetry_bundle.dart)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/inspect-evidence.sh](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/inspect-evidence.sh)

### Files To Delete

- none expected

## Implementation Steps

1. Define the structured telemetry bundle shape.
2. Add export helpers and CLI inspect surfaces.
3. Keep evidence and inspection vocabulary aligned between package and generated repo.
4. Validate that the latest-run path stays deterministic and cheap enough for daily use.

## Todo List

- [ ] Freeze telemetry bundle shape
- [ ] Add package inspect command family
- [ ] Add generated-repo inspection helper
- [ ] Keep validator and shell surfaces aligned
- [ ] Add deterministic latest-run inspection path

## Success Criteria

- Latest run can be inspected through one canonical command path.
- Evidence bundles include structured telemetry without secret leakage.
- Generated repos gain a usable local inspection helper.

## Risk Assessment

- Risk: ad hoc JSON files proliferate and become another drift surface.
- Mitigation: define one bundle shape and enforce it in validators and tests.

## Security Considerations

- Inspection helpers must never print redacted fields back in raw form.
- Approval-state fragments must not imply human approval where none exists.

## Next Steps

- Aggregate telemetry and approval-state data into agent-legible operator reports.
