# Phase 03: Implement Eval Gates, Evidence Bundles, And Approval Outputs

## Context Links

- [Plan overview](./plan.md)
- [Eval and evidence model](../../docs/11-eval-and-evidence-model.md)
- [Approval state machine](../../docs/12-approval-state-machine.md)
- [Deployment guide](../../docs/06-deployment-guide.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: turn named gates, approval pauses, and evidence bundles into real generated behavior.

## Key Insights

- The current verify/release scripts are useful but still exit-code heavy.
- Evidence is the missing surface that makes the harness inspectable.
- Approval boundaries already exist conceptually and in warnings, but they are not yet formalized as stateful outputs.

## Requirements

- Add canonical evidence bundle output paths and summary files.
- Make verify and release-preflight emit named gate results.
- Surface approval pauses in machine-readable and human-readable output.
- Keep CI and local gate vocabulary aligned.

## Architecture

- Generated scripts should emit to a canonical evidence directory from the manifest.
- `summary.json` should contain:
  - executed gates
  - pass/fail/blocked/skipped states
  - quality dimensions
  - next required human action
- Release-preflight and release surfaces should expose approval-state transitions without implying final publish authority.
- Generated CI should be able to preserve the same evidence layout as local execution.

## Related Code Files

- Modify:
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release-preflight.sh`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release.sh`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.github/workflows/*.yml`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab-ci.yml`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab/ci/*.yml`
  - `/Users/biendh/base/lib/src/config/agent_ready_repo_contract.dart`
  - `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`
  - `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`
- Create:
  - evidence fixture assertions under `/Users/biendh/base/test/integration/`
- Delete:
  - None expected

## Implementation Steps

1. Add canonical evidence directory config to generated repos.
2. Update verify and release-preflight scripts to emit summary and check files.
3. Add approval-state outputs to release surfaces.
4. Update CI templates to preserve or publish evidence artifacts consistently.
5. Add integration tests that assert evidence bundle structure and gate naming.

## Todo List

- [x] Add canonical evidence directory handling
- [x] Emit gate summaries from verify
- [x] Emit approval metadata from release-preflight/release
- [x] Align CI artifact handling
- [x] Add evidence bundle integration tests

## Success Criteria

- Generated repos emit inspectable evidence bundles for meaningful runs.
- Local and CI runs share the same gate vocabulary.
- Approval boundaries become machine-readable, not only warning text.

## Risk Assessment

- Risk: evidence generation becomes noisy or slows default flows too much.
- Mitigation: start with a minimum required bundle and grow only when evidence proves useful.

## Security Considerations

- Evidence bundles must redact secrets by default.
- Approval outputs must not imply authorization to perform final production publish.

## Next Steps

- Completed. Phase 04 aligns toolchain handling with the declared harness contract.
