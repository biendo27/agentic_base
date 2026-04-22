---
created: 2026-04-21
type: planning-journal
plan: plans/260421-1725-ci-test-speed-and-generated-app-hardening
---

# CI Test Speed Plan Journal

## Context

Created hard-mode plan for remaining post-publish issues after generated app Android/iOS testing.

## What Happened

- Researched official Dart/package:test, Flutter testing, GitHub Actions, GitLab CI, Firebase, and AdMob guidance.
- Scouted current root CI, generated-app smoke test, create command, generated workflow templates, generated scripts, and Ads module.
- Created plan at `plans/260421-1725-ci-test-speed-and-generated-app-hardening/`.

## Decisions

- Keep one always-running required CI aggregate; avoid workflow-level path filters.
- Tag generated-app smoke so root `dart test` stops running it implicitly.
- Add explicit generator verification modes instead of boolean `runVerify`.
- Fix generated CI rendering and remove prod from credentialless PR CI.
- Treat physical iOS device signing as human/local boundary; prove simulator readiness in CI.

## Next

Implement with Gitflow from `develop`, then validate fast lane, generated smoke, and native/iOS gates according to the plan.

## Unresolved Questions

None.
