# Phase 04: Make CI Release And Runtime Integrations Honest

## Context Links

- [Plan overview](./plan.md)
- [Phase 03](./phase-03-ship-deterministic-execution-harness-and-verify-ladder.md)
- [Current Repo Gap Analysis](./research/researcher-02-current-repo-gap-analysis.md)
- [`plans/260410-1026-dual-github-gitlab-cicd-selection/plan.md`](../260410-1026-dual-github-gitlab-cicd-selection/plan.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: remove template dishonesty from CI, release, and runtime module integration surfaces.

## Key Insights

- Current credibility gaps are concrete: broken GitHub expressions, placeholder release scripts, and incomplete Firebase wiring.
- Release automation is still valuable even when the final approval stays with humans.
- Runtime integrations must either work or fail loudly.

## Requirements

<!-- Updated: Validation Session 1 - release automation boundary locked -->
- Fix template rendering corruption in generated CI files and catch it with contract tests.
- Replace placeholder release flow with real preflight + execution layers, while keeping final publish/store release approval human-controlled.
- Support downstream release targets:
  - Firebase App Distribution
  - TestFlight
  - Play Console
  - App Store Connect
- Harden Firebase-backed module runtime seams:
  - `firebase_core`
  - initialization ordering
  - crash reporting handler integration

## Architecture

<!-- Updated: Validation Session 1 - human approval remains at final store publish/release -->
- CI wrappers:
  - provider-specific workflows call shared local scripts
- Release model:
  - `release-preflight` validates secrets, signing, IDs, provider auth
  - `release` performs build/upload plumbing via Fastlane/native tooling
  - final publish/store release remains a human approval boundary in v1
- Module model:
  - bootstrap and module installers own real runtime seams
  - contract tests assert presence and ordering

## Related Code Files

- Modify:
  - `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`
  - `/Users/biendh/base/lib/src/modules/core/analytics_module.dart`
  - `/Users/biendh/base/lib/src/modules/core/auth_module.dart`
  - `/Users/biendh/base/lib/src/modules/core/crashlytics_module.dart`
  - `/Users/biendh/base/lib/src/modules/extended/remote_config_module.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/bootstrap.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.github/workflows/*.yml`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab-ci.yml`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab/ci/*.yml`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release.sh`

## Implementation Steps

1. Add regression checks for preserved CI template expressions.
2. Define release-preflight inputs and failure messages.
3. Wire provider templates to shared preflight/build/release scripts.
4. Add Fastlane/native release scaffolding only where it stays generator-owned.
5. Fix Firebase-backed module bootstrap and crash handler ordering.
6. Extend smoke tests and contract checks for these surfaces.

## Todo List

- [x] Fix CI template rendering regression
- [x] Define release-preflight contract
- [x] Replace placeholder release flow
- [x] Harden Firebase runtime integrations
- [x] Extend tests for CI/release/runtime contracts

## Success Criteria

- Generated CI templates remain syntactically correct after generation.
- Generated release surfaces contain no TODO placeholders.
- Firebase-backed modules are either runnable by default or blocked by explicit preflight/setup checks.

## Risk Assessment

- Risk: native release tooling scope expands too fast.
- Mitigation: keep generator-owned release contract small, shared, and preflight-heavy.

## Security Considerations

- Never generate real credentials.
- Fail fast on missing secrets, signing config, or CLI auth.
- Keep human approval boundary explicit before final publish/upload.

## Next Steps

- Phase 05 adds migration safety and measurable proof that the new contract works.
