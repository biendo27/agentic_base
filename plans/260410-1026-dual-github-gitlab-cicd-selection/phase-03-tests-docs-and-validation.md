# Phase 03 — Tests, Docs, And Validation

## Context Links
- [Plan Overview](./plan.md)
- [Phase 02](./phase-02-provider-specific-scaffold-and-deploy.md)
- [Root README](../../README.md)
- [Deployment Guide](../../docs/06-deployment-guide.md)
- [Repo CI](../../.github/workflows/ci.yml)
- [Smoke Test](../../test/integration/generated_app_smoke_test.dart)

## Overview
- **Priority**: P2
- **Status**: Completed
- **Effort**: 4h
- **Depends on**: Phase 02
- **File ownership**: `test/src/cli/commands/create_command_test.dart`, optional `test/src/cli/commands/init_command_test.dart`, `test/src/cli/commands/deploy_command_test.dart`, `test/src/config/agentic_config_test.dart`, `test/src/generators/project_generator_test.dart`, `test/integration/generated_app_smoke_test.dart`, `README.md`, `docs/02-codebase-summary.md`, `docs/04-system-architecture.md`, `docs/05-project-roadmap.md`, `docs/06-deployment-guide.md`, `.github/workflows/ci.yml`
- **Description**: Prove the new provider contract works, document it, and reconcile repo-level CI expectations with generated-project support.

## Key Insights
- Repo CI is GitHub-only today, but that does not block validating generated GitLab scaffolds from package tests.
- There are no deploy command tests today, so provider branching needs new seams and coverage.
- Root docs currently describe GitLab as absent; that will be false for generated projects after this work.
- The repo-level miss that mattered was native validation on macOS; this phase must close that gap explicitly.
- GitHub required checks should not rely on workflow-level path filters because skipped required workflows can stay pending.

## Requirements

### Functional Requirements
- Add tests for provider parsing, config persistence, legacy fallback, and deploy routing.
- Expand smoke generation to cover both `github` and `gitlab`.
- Update root docs to distinguish:
  - package repo automation
  - generated project provider support
- Ensure package CI validates both scaffold variants even if the package repo itself stays on GitHub.
- Add a required pinned macOS GitHub Actions job that fresh-generates an app and runs `./tools/ci-check.sh`.
- Make GitLab docs/tests state clearly that native validation depends on a macOS runner and Xcode.
- Make the root GitHub macOS gate merge-blocking in practice: stable check name, required status check on `main`, and no conditional skip path.

### Non-Functional Requirements
- Keep validation automated from existing GitHub Actions unless GitLab repo automation is explicitly requested later.
- Make docs precise about what is shipped versus what remains TODO in downstream deploy jobs.

## Architecture

### Validation Strategy
1. Unit tests validate parser/config/provider resolution and provider-specific deploy adapters.
2. Integration tests generate temp apps for both providers and assert exclusive CI files plus config values.
3. Root GitHub Actions CI runs the expanded test suite on Ubuntu and a separate required pinned macOS job that exercises the generated app’s Darwin-only native gate.
4. GitLab scaffold validation remains repo-test-driven, but generated docs and templates must clearly declare the macOS runner prerequisite for native checks.
5. GitLab scaffold validation must assert root `.gitlab-ci.yml` exists and bootstraps `.gitlab/ci/*.yml`, so generated projects stay self-bootstrapping.
6. Enforcement matters as much as YAML presence: the GitHub macOS check must remain always-on with a stable name, and the GitLab native-validation job must stay blocking ahead of deploy jobs.

### Backwards Compatibility Strategy
- Legacy projects with missing `ci_provider` continue to follow GitHub fallback in tests and docs.
- No root repo `.gitlab-ci.yml` is required for this milestone.

## Related Code Files

### Files to Modify
- `test/src/cli/commands/create_command_test.dart`
- `test/src/config/agentic_config_test.dart`
- `test/src/generators/project_generator_test.dart`
- `test/integration/generated_app_smoke_test.dart`
- `README.md`
- `docs/02-codebase-summary.md`
- `docs/04-system-architecture.md`
- `docs/05-project-roadmap.md`
- `docs/06-deployment-guide.md`
- `.github/workflows/ci.yml`

### Files to Create
- `test/src/cli/commands/init_command_test.dart`
- `test/src/cli/commands/deploy_command_test.dart`

### Files to Delete
- None

## Implementation Steps
1. Add unit tests for provider constants, config read/write, create/init option handling, and legacy fallback behavior.
2. Add deploy command tests around provider selection, missing CLI/auth errors, and command construction using mocked execution seams.
3. Expand generated-app smoke coverage to run `create --ci-provider github` and `create --ci-provider gitlab`, asserting GitLab emits root `.gitlab-ci.yml` plus `.gitlab/ci/*.yml`.
4. Update root GitHub Actions CI to keep Ubuntu analyze/test and add a separate required pinned macOS job that fresh-generates an app and runs `./tools/ci-check.sh`.
5. Keep the required GitHub macOS gate always-on: no workflow-level path filters, no job-level conditional skip logic, and no unstable check/job naming.
6. Document/configure that macOS job as a required status check on `main`.
7. Rewrite root docs so GitLab support is described as a generated-project capability with one-provider selection, root `.gitlab-ci.yml`, and `.gitlab/ci/*.yml`, and make the macOS runner/Xcode prerequisite explicit.
8. Update roadmap/changelog style docs to reflect the new milestone and residual gaps.

## Todo List
- [x] Unit coverage added for provider contract
- [x] Deploy command tests added
- [x] Smoke test covers both providers
- [x] Root CI validates both scaffold variants
- [x] Root GitHub Actions includes a required pinned macOS native gate
- [x] Root GitHub macOS gate has a stable always-on required-check contract
- [x] Root docs updated to match shipped behavior

## Success Criteria
- `dart test` covers provider selection and legacy fallback.
- Smoke tests fail if both CI providers are emitted into one generated app.
- Smoke tests fail if GitLab scaffold lacks root `.gitlab-ci.yml` or the expected `.gitlab/ci/*.yml` include structure.
- Root docs state exactly what the package repo automates and what generated apps can scaffold.
- Root GitHub CI stays green while validating GitLab scaffold generation.
- Root GitHub CI fails if a fresh generated app fails the macOS/iOS native validation path in `./tools/ci-check.sh`.
- Root GitHub CI macOS gate is merge-blocking on `main`, not merely present in YAML.
- Docs do not imply that GitLab Linux runners can replace a macOS runner for iOS/native checks.
- Generated GitLab native validation is blocking before deploy jobs and is not marked `allow_failure`.

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Smoke test runtime grows too much when generating both providers | Medium | Medium | Keep matrix to two cases only; share assertions/helpers |
| macOS CI minutes become expensive | Medium | Medium | Keep one required native gate only; leave optimizations for non-required jobs later |
| Docs drift again from code | Medium | Medium | Update README + deployment guide + architecture summary in same change |
| Repo CI passes while provider trigger commands are wrong | Medium | High | Add mocked deploy tests and one manual validation checklist item before release |
| Required macOS workflow gets skipped by path filtering or conditional logic | Low | High | Avoid workflow-level path filters, job-level skip logic, and unstable check names on required checks |

## Security Considerations
- Docs must not encourage storing provider tokens in repo files.
- Any sample CI variables should be placeholders only.
- Manual validation notes should use non-production repos/tokens.

## Test Matrix
- **Unit**: `create`, `init`, config, provider resolver, deploy adapter behavior.
- **Integration**: generated app contract for GitHub and GitLab.
- **Repo CI**: Ubuntu analyze/test plus required pinned macOS native gate with a stable, always-on check name.
- **End-to-end / manual**: trigger one GitHub workflow and one GitLab pipeline in disposable repos before release.

## Rollback Plan
- Revert new smoke matrix and docs if provider support is paused.
- Keep legacy GitHub tests intact so package CI remains stable.

## Next Steps
- After implementation, consider whether `doctor` should warn when the provider-specific CLI (`gh` or `glab`) is missing.

## Unresolved Questions
- Repo-level GitLab automation for `agentic_base` itself remains intentionally out of scope. Generated-project GitLab support is now complete for this milestone.
