# Phase 05 — Add Drift Guards, Verification, and Final Docs Sync

## Context Links

- [plan.md](./plan.md)
- [phase-01](./phase-01-rationalize-root-contract-docs-and-remove-redundant-canonical-surface.md)
- [phase-02](./phase-02-re-layer-generated-app-docs-for-agentic-harness-workflow-clarity.md)
- [phase-03](./phase-03-rework-shared-contract-modeling-with-meup-informed-boundaries.md)
- [phase-04](./phase-04-propagate-contract-and-command-guidance-across-the-generated-surface.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: prove the cleaned docs and contract package stay aligned after regeneration

## Key Insights

- docs drift is now a product risk, not a wording nit
- contract-package changes without tests will regress fast
- generated-app smoke tests already exist and should be extended rather than replaced
- repo Gitflow docs now need to stay aligned with real workflow files, not only with prose siblings

## Requirements

- add or extend tests for:
  - root doc truthfulness where practical
  - generated manager-aware command guidance
  - shared contract serialization and convenience boundaries
- verify root Gitflow docs stay aligned with checked-in workflow guardrails
- verify generated Gitflow guidance stays aligned with any GitHub-only automation added in this wave
- update final docs after implementation, not before
- rerun analyze and targeted/full test suites

## Architecture

- favor regression tests around generated outputs and parsers
- use content assertions for critical generated docs only, not brittle full-file snapshots
- verify workflow-alignment claims against `.github/workflows/ci.yml` and `.github/workflows/gitflow-guard.yml`
- if generated Gitflow automation is added, verify it against generated GitHub workflow outputs rather than inventing GitLab parity

## Related Code Files

- Modify:
  - `.github/workflows/ci.yml`
  - `.github/workflows/gitflow-guard.yml`
  - relevant unit tests under `test/src/**`
  - generated-app smoke tests under `test/integration/**`
  - final docs touched by the implementation

## Implementation Steps

1. Add regression assertions for manager-aware generated testing docs.
2. Add contract-package tests for newly introduced request/response/multilanguage types.
3. Add minimal drift checks for root canonical doc language if practical.
4. Recheck root Gitflow docs against `.github/workflows/ci.yml` and `.github/workflows/gitflow-guard.yml` so docs do not overclaim or contradict the actual automation.
5. If generated Gitflow automation lands, add regression checks for GitHub outputs only and keep GitLab assertions documentation-level.
6. Run `dart analyze --fatal-infos`.
7. Run targeted tests first, then full `dart test`, and record any suite-speed or hang regressions honestly.

## Todo List

- [x] extend regression tests
- [x] rerun analyze
- [x] rerun targeted tests
- [x] rerun full test suite
- [x] sync final docs after green verification

## Success Criteria

- analyze is green
- targeted regression tests are green
- full suite is green or any blocking instability is documented honestly
- docs and generated surfaces no longer drift on the reviewed points
- root Gitflow prose matches the real workflow triggers and PR-route guardrails
- generated Gitflow docs/adapters match the chosen recommended policy, and any automation added in this wave is constrained to GitHub scaffolds only

## Risk Assessment

- content assertions can become brittle if they test prose too broadly
- full suite may still expose slow smoke cases that need separate follow-up

## Security Considerations

- ensure no docs rewrite loosens production publish approval boundaries

## Next Steps

- full-suite smoke verification is still expensive on macOS because generated apps run native-readiness gates; treat speed as a separate follow-up if it becomes release pain
