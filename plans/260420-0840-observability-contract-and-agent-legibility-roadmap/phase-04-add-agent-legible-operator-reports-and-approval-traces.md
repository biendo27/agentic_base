# Phase 04 - Add Agent-Legible Operator Reports And Approval Traces

## Context Links

- [Phase 03](./phase-03-add-telemetry-export-and-inspection-surfaces.md)
- [Official Guidance Note](./research/official-observability-guidance.md)
- [Approval State Machine](../../docs/12-approval-state-machine.md)

## Overview

- Priority: P1
- Current status: Pending
- Brief description: Turn raw telemetry and gate outputs into repo-local operator reports that agents and humans can inspect without needing a hosted console.

## Key Insights

- Observability is only useful if the agent can query and reason about it.
- This repo can ship report surfaces and run ledgers. It should not claim a persistent remote operator plane.
- Approval states, command runs, and runtime telemetry need one joined timeline.

## Requirements

### Functional Requirements

- Join command runs, gate outcomes, runtime telemetry, and approval states into one canonical run ledger.
- Add repo-local report outputs:
  - machine-readable timeline JSON
  - human-readable Markdown or HTML summary
- Make approval traces visible in reports and inspect commands.
- Keep downstream generated repos and package-level CLI semantics aligned.

### Non-Functional Requirements

- Agent-legible first
- Human-readable second
- No remote service dependency

## Architecture

- Run ledger becomes the canonical read model for operator-style inspection.
- CLI inspect/report surfaces read the same ledger used by generated shell helpers.
- Approval traces stay finite and derived from the existing state machine vocabulary.
- HTML or Markdown summaries are read models only, never the source of truth.

## Related Code Files

### Files To Modify

- [docs/04-system-architecture.md](/Users/biendh/base/docs/04-system-architecture.md)
- [docs/06-deployment-guide.md](/Users/biendh/base/docs/06-deployment-guide.md)
- [docs/12-approval-state-machine.md](/Users/biendh/base/docs/12-approval-state-machine.md)
- [lib/src/cli/commands/deploy_command.dart](/Users/biendh/base/lib/src/cli/commands/deploy_command.dart)
- [lib/src/cli/commands/eval_command.dart](/Users/biendh/base/lib/src/cli/commands/eval_command.dart)
- [lib/src/tui/agentic_logger.dart](/Users/biendh/base/lib/src/tui/agentic_logger.dart)

### Files To Create

- [lib/src/observability/run_ledger.dart](/Users/biendh/base/lib/src/observability/run_ledger.dart)
- [lib/src/observability/operator_report_renderer.dart](/Users/biendh/base/lib/src/observability/operator_report_renderer.dart)
- [docs/18-local-operator-reporting.md](/Users/biendh/base/docs/18-local-operator-reporting.md)

### Files To Delete

- none expected

## Implementation Steps

1. Define the run-ledger read model.
2. Join command, telemetry, and approval-state records into that ledger.
3. Render canonical machine output plus one human-facing summary surface.
4. Keep report generation deterministic and local-only.

## Todo List

- [ ] Define run-ledger schema
- [ ] Join command, telemetry, and approval-state records
- [ ] Add machine and human report renderers
- [ ] Expose approval traces in inspect/report surfaces
- [ ] Document local operator reporting boundaries

## Success Criteria

- Agents can inspect one joined run timeline without scraping multiple files manually.
- Human-readable reports map back to canonical machine artifacts.
- The repo still does not claim a hosted control plane.

## Risk Assessment

- Risk: report rendering becomes the de facto truth and drifts from source artifacts.
- Mitigation: keep ledger canonical and renderers read-only.

## Security Considerations

- Report renderers must inherit redaction policy from the canonical artifact layer.
- Approval traces must never expose credentials or masked provider values.

## Next Steps

- Lock tests, docs, migration, and rollout around the new observability contract.
