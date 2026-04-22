---
type: red-team
created: 2026-04-21
scope: plan-review
---

# Red Team Review

## Findings

1. Fast CI can silently weaken the harness if generated/native gates become optional with no replacement. Mitigation: keep an always-required aggregate job, add contract tests for template/native bugs, and run heavy jobs conditionally on code paths plus nightly/manual/release.
2. Public `--verify-mode none` can be abused. Mitigation: default remains `full`; `none` prints a clear unverified warning and is used only in repo CI where a later job runs `tools/ci-check.sh`.
3. GitHub workflow-level path filters are tempting but unsafe for required checks. Mitigation: no workflow-level `paths`; do change detection inside an always-running workflow.
4. Caches can add flake and cost. Mitigation: cache dependency stores only, keyed by lockfiles/SDK; do not cache generated build products in v1.
5. Fixing generated CI tokens without tests will regress. Mitigation: contract tests must fail on unresolved `{{...}}` tokens while ignoring valid GitHub `${{ ... }}` expressions.
6. iOS physical device success cannot be guaranteed by code because Apple signing is account/profile-bound. Mitigation: CI proves simulator readiness; physical-device run remains a documented human/local credential boundary.
7. Building fewer flavors in PR CI may hide prod-only failures. Mitigation: prod build moves to release/manual lanes with real `env/prod.env`; prod release-preflight becomes mandatory before production deploy.

## Plan Corrections Applied

- Added contract-test phase before runtime/native smoke.
- Added generated CI prod-build split as a first-class requirement.
- Added explicit verification mode policy and misuse guard.
- Kept no workflow-level path filtering.
- Kept physical iOS out of CI success criteria.

## Unresolved Questions

None.
