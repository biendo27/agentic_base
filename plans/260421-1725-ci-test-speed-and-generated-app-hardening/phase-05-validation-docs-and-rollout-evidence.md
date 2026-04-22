# Phase 05: Validation Docs And Rollout Evidence

## Context Links

- [Plan](./plan.md)
- [Phase 01](./phase-01-root-test-taxonomy-and-fast-ci-baseline.md)
- [Phase 02](./phase-02-verification-mode-and-runtime-budget.md)
- [Phase 03](./phase-03-generated-cicd-contract-hardening.md)
- [Phase 04](./phase-04-native-ios-runtime-and-strict-lint-hardening.md)
- Deployment guide: [`docs/06-deployment-guide.md`](../../docs/06-deployment-guide.md)
- Roadmap: [`docs/05-project-roadmap.md`](../../docs/05-project-roadmap.md)

## Overview

Priority: P1. Status: Completed.

Close the loop with docs, validation evidence, and rollout notes. The implementation is not complete until fresh generated apps prove the new CI/native/lint contract.

## Key Insights

- This repo has two doc surfaces: root package docs and generated app docs inside the brick.
- Previous plans frequently closed code but left user-visible workflow assumptions stale.
- User specifically wants plan-first, then implementation through Gitflow.

## Requirements

- Functional:
  - Update root docs for new CI/test strategy.
  - Update generated docs for generated CI/CD, prod env boundary, verify modes, strict lint, and iOS signing boundary.
  - Update roadmap/changelog if implementation lands.
  - Save validation evidence or summarize command outputs in plan close-out.
- Non-functional:
  - Docs must not claim physical iOS device CI.
  - Docs must distinguish package repo CI from generated-project CI.

## Architecture

Docs are contract surfaces:

```text
root docs
  -> package maintainer CI/test/release behavior
generated docs
  -> downstream team local/CI/deploy behavior
GeneratedProjectContract/tests
  -> enforce both surfaces
```

## Related Code Files

- Modify `/Users/biendh/base/README.md` if CLI flags or CI provider prompt docs change.
- Modify `/Users/biendh/base/docs/02-codebase-summary.md`.
- Modify `/Users/biendh/base/docs/04-system-architecture.md`.
- Modify `/Users/biendh/base/docs/05-project-roadmap.md`.
- Modify `/Users/biendh/base/docs/06-deployment-guide.md`.
- Modify generated app docs under `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/`.
- Modify generated `README.md`, `AGENTS.md`, `CLAUDE.md` if workflow commands change.
- Modify docs regression tests under `/Users/biendh/base/test/src/docs/`.

## Implementation Steps

1. Update README flags table with `--verify-mode` if added.
2. Update root deployment guide:
   - fast required lane
   - conditional generated/native lanes
   - aggregate status policy
   - no workflow-level path filters for required checks
3. Update generated deployment docs:
   - PR CI builds dev/staging only
   - prod requires `env/prod.env` and protected release/deploy lane
   - GitHub/GitLab environment protection guidance
4. Update generated testing guide:
   - `./tools/lint.sh --strict` or equivalent
   - `./tools/verify.sh` modes and evidence expectations
5. Update generated Firebase/native docs:
   - physical iOS signing/provisioning boundary
   - simulator gate expectation
6. Add docs regression tests for the new user-facing claims.
7. Run validation pack:
   - `dart pub get`
   - `dart format --set-exit-if-changed lib bin test tool`
   - `dart analyze --fatal-infos`
   - `dart test test/src --exclude-tags generated-app`
   - `dart test test/integration/generated_app_smoke_test.dart --exclude-tags slow-canary`
   - `dart test test/integration/generated_app_smoke_test.dart --tags slow-canary` when touched paths require it
   - create GitHub app and inspect workflows for rendered tokens
   - create GitLab app and inspect generated CI paths
   - macOS iOS simulator native smoke when ads/native path changed
8. Record final command results in plan validation log.

## Todo List

- [x] Update root docs.
- [x] Update generated docs/adapters.
- [x] Add docs regression tests.
- [x] Run validation pack.
- [x] Record evidence paths/results.
- [x] Update roadmap/changelog if implementation completes.

## Success Criteria

- Docs match actual command behavior.
- Generated docs do not promise prod build or physical iOS success without credentials.
- Validation commands pass or have documented external blockers.
- Plan close-out includes runtime before/after for CI-critical lanes.

## Risk Assessment

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Docs drift again | User confusion | Add docs tests for critical claims |
| Validation too expensive locally | Slow iteration | Run fast pack first, slow canary/native only when touched paths require |
| Release notes omit breaking flag behavior | Adoption friction | Keep defaults backward-compatible; document new optional flags |

## Security Considerations

- Do not store Firebase, AdMob, Apple, or Play credentials in docs/evidence.
- Generated evidence uploads must not include env files with real secrets.

## Next Steps

After implementation, use Gitflow: feature branch from `develop`, PR into `develop`, then release branch when publishing package update.
