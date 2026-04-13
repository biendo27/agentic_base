# Phase 03: Turn Verification And Release Into First-Class Contracts

## Context Links

- [Proposal overview](./plan.md)
- [Phase 02](./phase-02-generate-agent-context-and-execution-harness.md)
- [`docs/06-deployment-guide.md`](../../docs/06-deployment-guide.md)
- [`plans/260410-1026-dual-github-gitlab-cicd-selection/plan.md`](../260410-1026-dual-github-gitlab-cicd-selection/plan.md)

## Overview

- Priority: P0
- Status: Proposed
- Goal: generated repos must have a real verify ladder and real release automation, not placeholder CI scaffolds.

## Key Insights

- Agent-ready claims collapse if the repo cannot prove correctness or ship artifacts without manual scripting.
- The biggest current credibility gaps are broken CI templates, incomplete Firebase wiring, and TODO release flows.
- Release automation still needs human approval, but agent execution should cover everything before that gate.

## Requirements

- Add a blocking verify ladder:
  - analyze
  - unit/widget/integration tests
  - generated-project smoke checks
  - platform preflight
  - release preflight
- Replace placeholder deploy scripts and workflows with real flows:
  - Firebase App Distribution
  - TestFlight
  - Play Console
  - App Store Connect
- Ensure Firebase-backed modules either fully initialize or fail fast with explicit setup errors.
- Expand generated-project contract checks to catch templating corruption and runtime-wiring drift.

## Architecture

- Release contract:
  - shared `tools/release-preflight.sh`
  - Fastlane as native release execution layer
  - provider-specific CI wrappers that call the same local scripts
- Verify contract:
  - one local `tools/verify.sh`
  - one CI contract per provider
  - one generated-project contract validator in the package repo
- Module contract:
  - installable modules must wire runtime seams honestly
  - no silent `Firebase*.instance` usage without `firebase_core` bootstrap

## Related Code Files

- Modify:
  - `lib/src/generators/generated_project_contract.dart`
  - `lib/src/modules/core/analytics_module.dart`
  - `lib/src/modules/core/auth_module.dart`
  - `lib/src/modules/core/crashlytics_module.dart`
  - `lib/src/modules/extended/remote_config_module.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.github/workflows/*.yml`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab-ci.yml`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab/ci/*.yml`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release.sh`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/bootstrap.dart`
- Add within generated app contract:
  - fastlane files
  - release env documentation
  - preflight helpers

## Implementation Steps

1. Fix template rendering corruption and add explicit regression checks.
2. Define shared release execution contract and wire provider templates to it.
3. Implement preflight validation for secrets, signing, app ids, and provider auth.
4. Make Firebase-backed modules truly runnable or explicitly guarded.
5. Expand smoke tests to verify release and runtime wiring contracts.

## Todo List

- [ ] Fix CI template rendering regressions
- [ ] Add shared verify/release-preflight contract
- [ ] Wire Fastlane + provider CI templates
- [ ] Harden Firebase-backed module integrations
- [ ] Extend smoke and contract coverage

## Success Criteria

- Fresh generated app can reach local verify and release preflight without manual repo surgery.
- Deploy/release templates contain no TODO placeholders.
- Contract tests fail if provider templates or runtime integrations regress.

## Risk Assessment

- Risk: store-release setup introduces significant platform complexity.
- Mitigation: keep agent-owned execution deterministic and leave only credential provisioning and release approval to humans.

## Security Considerations

- Never generate or store real secrets in repo.
- Enforce fail-fast checks for missing signing, API keys, and CLI auth before build/upload.

## Next Steps

- Phase 4 closes migration, compatibility, and measurable success tracking.
