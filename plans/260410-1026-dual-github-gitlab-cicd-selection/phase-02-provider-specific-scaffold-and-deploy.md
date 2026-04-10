# Phase 02 — Provider-Specific Scaffold And Deploy

## Context Links
- [Plan Overview](./plan.md)
- [Phase 01](./phase-01-provider-selection-contract.md)
- [Deploy Command](../../lib/src/cli/commands/deploy_command.dart)
- [Generated Project Contract](../../lib/src/generators/generated_project_contract.dart)
- [App Brick README](../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md)

## Overview
- **Priority**: P1
- **Status**: Completed
- **Effort**: 5h
- **Depends on**: Phase 01
- **File ownership**: `lib/src/cli/commands/deploy_command.dart`, optional `lib/src/deploy/**`, `lib/src/generators/generated_project_contract.dart`, `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.github/workflows/*.yml`, `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab-ci.yml`, `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`, `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/AGENTS.md`, `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/CLAUDE.md`
- **Description**: Emit exactly one CI provider in the generated app and make `deploy` follow the stored provider.

## Key Insights
- The app brick already contains hidden GitHub workflows and Fastlane placeholders.
- `deploy_command.dart` is already too large and directly shells out to `gh`, which will get worse if GitLab logic is inlined.
- Generated project scripts (`tools/ci-check.sh`, `tools/build.sh`) already provide a reusable execution layer that both providers can call.
- Current generated-project contract does not assert CI files, so “both provider files present” would go undetected.
- The iOS/native regression that triggered this plan is only caught on macOS; Linux-only CI is insufficient.
- GitLab cannot honestly claim this gate without a macOS runner contract; generic Linux runners cannot validate iOS/native flavors.

## Requirements

### Functional Requirements
- GitHub projects emit only `.github/workflows/*.yml`.
- GitLab projects emit root `.gitlab-ci.yml` plus included files under `.gitlab/ci/*.yml`.
- `agentic_base deploy <dev|staging|prod>` remains unchanged.
- Deploy logic routes by persisted provider:
  - GitHub: existing workflow filename contract stays `cd-<env>.yml`
  - GitLab: explicit per-environment manual deploy jobs map to `dev`, `staging`, `prod`
- GitHub generated workflows must keep native validation callable through `./tools/ci-check.sh`.
- GitLab generated CI must define a dedicated macOS-native validation job and must not imply Linux fallback for that gate.
- Generated docs mention provider-specific prerequisites (`gh` vs `glab`, auth, runner expectations).

### Non-Functional Requirements
- Preserve current generator architecture: CLI -> config -> brick -> scripts.
- Reduce logic duplication between GitHub and GitLab templates by delegating to `tools/*.sh`.
- Keep deploy command file size under control via small helpers if needed.

## Architecture

### Data Flow
1. `ci_provider` enters from Phase 01 and is stored in config.
2. Mason renders only the matching provider CI definition.
3. Generated CI definitions call project-local scripts:
   - verify: `./tools/ci-check.sh`
   - build/deploy: `./tools/build.sh <env>`
4. User runs `agentic_base deploy <env>`.
5. Deploy resolver reads `ci_provider`.
6. Provider adapter validates auth/tooling and triggers the matching remote workflow or pipeline.
7. Adapter prints the run URL back to the user.

### Provider Contract
- **GitHub**: keep current workflow names; update templates to delegate to scripts where practical.
- **GitHub**: generated workflow set remains provider-exclusive; native verification stays script-driven and must include macOS/iOS validation where the workflow runs on macOS.
- **GitLab**: keep root `.gitlab-ci.yml` as bootstrap and split actual jobs into `.gitlab/ci/*.yml` via `include: local`, with verify/build/manual deploy jobs keyed off the same env set: `dev`, `staging`, `prod`.
- **GitLab native gate**: add one blocking job tagged `macos` that assumes shell executor + Xcode, runs `./tools/ci-check.sh`, is not `allow_failure`, and sits before deploy jobs; Linux jobs may cover Dart-only checks, not native validation.
- **Fastlane**: remain provider-neutral; do not fork fastlane config by CI provider in this phase.

## Related Code Files

### Files to Modify
- `lib/src/cli/commands/deploy_command.dart`
- `lib/src/generators/generated_project_contract.dart`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.github/workflows/ci.yml`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.github/workflows/cd-dev.yml`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.github/workflows/cd-staging.yml`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.github/workflows/cd-prod.yml`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.github/workflows/release.yml`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab-ci.yml`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/AGENTS.md`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/CLAUDE.md`

### Files to Create
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab/ci/verify.yml`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab/ci/deploy.yml`
- Optional: `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab/ci/common.yml`
- Optional helper files under `lib/src/deploy/` for provider adapters and process execution seams

### Files to Delete
- None; provider exclusivity should come from conditional emission, not post-generation deletion, unless Mason path conditions fail

## Implementation Steps
1. Extract provider resolution and shell execution seams from `deploy_command.dart` so provider-specific command building is testable.
2. Preserve GitHub trigger behavior: clean git state, `gh` auth check, `gh workflow run cd-<env>.yml`, print run URL.
3. Add GitLab trigger behavior: clean git state, `glab` auth check, trigger the pipeline for the current branch and target the matching manual deploy contract, print pipeline URL.
4. Render provider-exclusive brick files:
   - GitHub: existing workflow set
   - GitLab: root `.gitlab-ci.yml` bootstrapping `.gitlab/ci/*.yml`
5. Keep the GitLab root file minimal and self-bootstrapping so generated projects do not depend on custom GitLab project CI config-path settings.
6. Make provider templates call existing scripts instead of duplicating long command sequences where possible.
7. Encode GitLab macOS runner prerequisites directly in template comments/docs: `tags: [macos]`, shell executor, Xcode required.
8. Make the GitLab macOS native-validation job blocking by contract: no `allow_failure`, no deploy-before-validate path.
9. Extend generated-project validation so scaffold tests can assert “one provider only” and presence of the macOS-native contract where required.
10. Update generated-project README/agent docs with provider-specific deploy instructions and prerequisites.

## Todo List
- [x] Deploy provider resolver implemented
- [x] GitHub path preserved behind shared abstraction
- [x] GitLab pipeline trigger path added
- [x] Brick emits only one provider’s CI files
- [x] GitLab root `.gitlab-ci.yml` bootstraps `.gitlab/ci/*.yml` without extra project settings
- [x] GitLab template states macOS runner/Xcode requirement for native validation
- [x] GitLab native-validation job is explicitly blocking and runs before deploy jobs
- [x] Generated-project docs updated for provider-aware deploy
- [x] CI contract validation checks provider exclusivity

## Success Criteria
- GitHub scaffold still produces current workflow names.
- GitLab scaffold produces root `.gitlab-ci.yml` plus `.gitlab/ci/*.yml`, and no `.github/workflows`.
- `deploy prod` chooses provider from project config, not from a new user flag.
- Generated-project templates share script-level build logic instead of duplicating it in both CI providers.
- GitLab scaffold makes the macOS-native validation requirement explicit instead of silently treating Linux as equivalent.
- GitLab scaffold makes the macOS-native validation requirement enforceable, not just documented.
- GitLab deploy contract is readable and auditable through explicit per-env jobs, not opaque variable switching.
- GitLab scaffold stays portable because it does not depend on custom GitLab CI config-path settings.

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| `deploy_command.dart` becomes larger and harder to test | High | Medium | Extract provider adapters/process runner seam |
| Mason hidden-file conditionals do not reliably emit exclusive provider files | Medium | High | Validate with smoke tests; fallback to post-gen cleanup only if necessary |
| GitLab runner/image assumptions differ from GitHub hosted runner | High | High | Keep GitLab template minimal, require explicit macOS runner contract, document no Linux fallback |
| GitLab deploy trigger semantics for manual jobs may be awkward through CLI | Medium | Medium | Keep v1 contract explicit in docs/tests; if CLI trigger semantics are messy, plan follow-up seam instead of hiding complexity |

## Security Considerations
- CI templates must consume secrets from provider-native secret stores only.
- No auth tokens, signing secrets, or store credentials may be added to the brick.
- Deploy docs should keep least-privilege guidance for `gh` and `glab` tokens.

## Test Matrix
- **Unit**: provider adapter command construction, error mapping, file exclusivity validator.
- **Integration**: generate GitHub and GitLab apps and assert emitted CI file sets.
- **Manual validation**: dry-run trigger on one GitHub repo and one GitLab repo before release if CLI semantics are uncertain.
- **Native validation**: ensure GitLab sample contract documents `macos` runner + Xcode and that GitHub sample contract continues to call `./tools/ci-check.sh`.

## Rollback Plan
- Disable GitLab provider path in CLI/parser and brick while keeping GitHub flow intact.
- Revert deploy adapter wiring to GitHub-only if GitLab trigger semantics prove unstable.

## Next Steps
- Phase 03 adds repo tests, root-doc reconciliation, and CI validation coverage.

## Unresolved Questions
- None. The implementation now uses `glab ci run` plus `glab ci trigger deploy_<env>` against the resolved pipeline.
