# Phase 05: Add Regression Coverage, Fixture Updates, And Claim-Safe Rollout

## Context Links

- [Plan overview](./plan.md)
- [Project roadmap](../../docs/05-project-roadmap.md)
- [README](../../README.md)
- [Project overview PDR](../../docs/01-project-overview-pdr.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: prove the new contract in package tests and generated output before broadening product claims.

## Key Insights

- The last trust problem came from claims outrunning executable reality.
- The new contract touches generated repos, generator code, scripts, CI, and docs; regression proof has to cross all of them.
- Generated-app smoke runs can expose real native-readiness regressions plus host-tooling blockers that need honest classification.
- Public product language should move last, not first.

## Requirements

- Add regression tests for manifest semantics, generated-surface parity, evidence bundles, approval outputs, and SDK mismatch behavior.
- Update fixture expectations and generated-app smoke tests.
- Harden native-readiness and module-owned Podfile paths when smoke coverage exposes contract regressions.
- Sync README and doc claims only after the new contract is backed by code/tests.
- Keep rollout incremental and reversible.

## Architecture

- Package tests should cover typed config and validator behavior.
- Generated-app smoke tests should cover evidence and generated-surface outputs.
- Generated verify/native-readiness paths should distinguish code regressions from host-tooling blockers and emit the next required human action.
- Public docs should distinguish:
  - now-shipped guarantees
  - newly-shipped Harness Contract V1 guarantees
  - still-design-only surfaces, if any remain

## Related Code Files

- Modify:
  - `/Users/biendh/base/lib/src/modules/module_installer.dart`
  - `/Users/biendh/base/lib/src/modules/core/analytics_module.dart`
  - `/Users/biendh/base/lib/src/modules/extended/notifications_module.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/_common.sh`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh`
  - `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`
  - `/Users/biendh/base/test/src/config/**/*.dart`
  - `/Users/biendh/base/test/src/cli/commands/**/*.dart`
  - `/Users/biendh/base/test/src/generators/**/*.dart`
  - `/Users/biendh/base/README.md`
  - `/Users/biendh/base/docs/01-project-overview-pdr.md`
  - `/Users/biendh/base/docs/04-system-architecture.md`
  - `/Users/biendh/base/docs/05-project-roadmap.md`
  - `/Users/biendh/base/docs/06-deployment-guide.md`
- Create:
  - additional fixture/assertion helpers under `/Users/biendh/base/test/` if needed
- Delete:
  - stale claim text or obsolete fixture expectations if replaced

## Implementation Steps

1. Add regression assertions for each newly-implemented contract surface.
2. Harden generated native-readiness paths uncovered by smoke coverage.
3. Refresh generated-app fixture expectations only after tests pass.
4. Update public docs and roadmap claims to match the now-executable contract.
5. Re-run full local verification and record any residual gaps.
6. Leave unsupported surfaces explicitly unsupported.

## Todo List

- [x] Add contract-surface regression coverage
- [x] Refresh fixture and smoke expectations
- [x] Update public docs last
- [x] Re-run full local verification
- [x] Document residual unsupported areas explicitly

## Success Criteria

- The package cannot regress the new harness contract without test failures.
- Generated output proves the new contract, not only source templates.
- README and docs only claim behavior backed by code, scripts, and tests.

## Risk Assessment

- Risk: docs get updated before the new behavior is actually stable.
- Mitigation: treat docs sync as the final exit gate for the rollout.

## Security Considerations

- Tests must not require live secrets to prove the contract.
- Rollout must keep human-only boundaries explicit for credentials and final production publish.

## Next Steps

- Completed. The repo can now claim implemented Harness Contract V1 support, subject to ongoing stabilization and regression coverage.
