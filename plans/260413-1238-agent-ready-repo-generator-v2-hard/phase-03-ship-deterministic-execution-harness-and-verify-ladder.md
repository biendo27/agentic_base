# Phase 03: Ship Deterministic Execution Harness And Verify Ladder

## Context Links

- [Plan overview](./plan.md)
- [Phase 02](./phase-02-generate-canonical-agent-context-and-thin-adapters.md)
- [`docs/06-deployment-guide.md`](../../docs/06-deployment-guide.md)
- [`docs/03-code-standards.md`](../../docs/03-code-standards.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: generated repos must expose explicit scripts that agents can run without guessing.

## Key Insights

- Agents fail when setup/run/verify/build actions are implicit or scattered.
- Current repo already has pieces like `build.sh` and `ci-check.sh`; they need consolidation into a complete harness.
- Verify must be a first-class product feature.

## Requirements

- Add deterministic scripts for:
  - setup
  - run
  - verify
  - build
  - release preflight
- Standardize the local verify ladder:
  - analyze
  - tests
  - generated app checks
  - platform readiness checks
- Ensure docs and CI wrappers point to the same scripts.

## Architecture

- Local contract:
  - `tools/setup.sh`
  - `tools/run-dev.sh`
  - `tools/verify.sh`
  - `tools/build.sh`
  - `tools/release-preflight.sh`
- Validation contract:
  - generated-project contract assertions
  - smoke tests for script presence and content

## Related Code Files

- Modify:
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/build.sh`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/ci-check.sh`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`
  - `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`
  - `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`
- Add:
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/setup.sh`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/run-dev.sh`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release-preflight.sh`

## Implementation Steps

1. Define the harness script contract and naming.
2. Add missing scripts and align existing scripts to the same contract.
3. Update generated docs to make these scripts the primary execution surface.
4. Add contract assertions for presence and content.
5. Extend smoke tests to use the new verify surface where practical.

## Todo List

- [x] Define script contract
- [x] Add missing harness scripts
- [x] Align docs and CI wrappers
- [x] Add script-level contract assertions
- [x] Extend smoke coverage

## Success Criteria

- A fresh generated repo can be set up, run, and verified with explicit scripts only.
- Agent instructions and CI wrappers point to the same execution surfaces.
- Script drift becomes test-visible.

## Risk Assessment

- Risk: script sprawl without ownership clarity.
- Mitigation: one small named harness with explicit ownership and contract checks.

## Security Considerations

- Scripts must fail fast when environment prerequisites are missing.
- No secrets are baked into scripts or example env files.

## Next Steps

- Phase 04 makes CI, release, and runtime integrations truly honest on top of this harness.
