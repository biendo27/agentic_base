# 05. Project Roadmap

## Current Status

The original generator foundation is complete.

Harness Contract V1 implementation is landed in generator code, generated scripts, CI templates, validators, and regression tests.

The profile-execution rollout is also complete: `subscription-commerce-app` is now the shipped CLI default, preset resolution drives starter seams and verify policy from one source of truth, the default starter theme is the trustworthy-commerce family, and the default payment seam is store-native via `in_app_purchase`.

Validation is green on `dart analyze --fatal-infos`, the doc and generator-focused tests, shell syntax checks, the generated-app smoke regression, and the full `dart test` suite.

## Completed Phases

| Phase | Status | Outcome |
| --- | --- | --- |
| 1. Tool Scaffold & Create Command | Completed | CLI scaffold, create flow, app brick integration. |
| 2. Feature & Module System | Completed | Feature generation plus module registry/install flow. |
| 3. Testing & Eval | Completed | Package test suite and eval command in place. |
| 4. CI/CD & Deploy | Completed | Package CI exists; deploy command exists in source. |
| 5. Extended Modules | Completed | Extended module catalog added. |
| 6. Multi-State & Bricks | Completed | State options and brick-based scaffolding in place. |
| 7. Polish & Publish | Completed | Initial package polish and pubspec metadata present. |
| 8. Harness Contract V1 | Completed | Typed harness manifest, support tiers, evidence outputs, approval states, and SDK policy enforcement shipped. |
| 9. Contract-Freeze Slice 1 | Completed | Default app service matrix added; `observability` renamed to `evidence_quality`; validator and manifest parser now enforce canonical quality dimensions. |
| 10. Profile Execution Golden Path | Completed | Profile presets, profile-aware verify gates, trustworthy-commerce starter UI, migration docs, and generated-app regression coverage shipped. |

## Active Milestone

### Milestone: Profile Execution Rollout

Status:

- Complete
- Harness Contract V1 implementation complete
- Shared app contracts now standardize generated starter and feature data/domain boundaries on `fpdart` while keeping presentation state APIs simple
- CLI commands now have truthful preview-only `--dry-run` paths, and real execution uses manager-aware toolchain selection for `system`, `fvm`, and `puro`
- Generated starter contracts now use Freezed-backed response and pagination models, and the theme layer splits controller state from family composition
- Generated locale runtime wrapping now lives outside the Slang output tree so contract verification stays stable after regeneration
- Generated starter apps now ship the trustworthy-commerce family: bright neutral surfaces, blue primary, orange accent, Lexend headings, Source Sans 3 body copy, and `google_fonts` as part of the brick contract
- The starter app now proves one day-0 journey with profile-aware dashboard signals, settings preview, lifecycle/config seams, and separated payments, entitlement, consent, and ads starter seams
- Verification no longer relies mainly on downstream boot smoke: generated apps now ship repository tests, state-runtime tests, a starter widget test, and the package smoke matrix retains only the heavy lanes that still prove unique behavior
- Smoke verification is now split into a fast blocking lane and a slow blocking canary; the generic test pass excludes the dedicated `app-shell-smoke` gate so the canary is not duplicated
- The full contract-freeze slice is complete: default app service matrix docs landed, `evidence_quality` is canonical, preset resolution drives create output, profile-aware verify gates are rendered from generator policy, and migration guidance exists for older generated repos
- The default lane now uses store-native `in_app_purchase` instead of the earlier provider-neutral monetization demo
- Repo release hygiene now includes classic Gitflow branch roles, PR route validation, and CI coverage for `develop`, `release/*`, and `hotfix/*`
- Docs, generated workflow guidance, and release claims align with shipped behavior
- Remaining work is future generator polish and release automation, not this rollout

Defined outputs:

- keep `.info/agentic.yaml` as the single machine-readable source of truth
- prevent drift between generated surfaces, validators, and docs
- keep evidence and approval outputs stable across local and CI execution
- preserve honest Flutter SDK contract handling during future upgrades
- ship publication/release automation only when it matches the real package workflow

Key docs:

- [`docs/08-harness-contract-v1.md`](./08-harness-contract-v1.md)
- [`docs/09-support-tier-matrix.md`](./09-support-tier-matrix.md)
- [`docs/10-manifest-schema.md`](./10-manifest-schema.md)
- [`docs/11-eval-and-evidence-model.md`](./11-eval-and-evidence-model.md)
- [`docs/12-approval-state-machine.md`](./12-approval-state-machine.md)
- [`docs/13-flutter-adapter-boundaries.md`](./13-flutter-adapter-boundaries.md)
- [`docs/14-sdk-and-version-policy.md`](./14-sdk-and-version-policy.md)
- [`docs/15-default-app-service-matrix.md`](./15-default-app-service-matrix.md)
- [`docs/16-profile-rollout-migration-guide.md`](./16-profile-rollout-migration-guide.md)

## Next Waves

| Wave | Goal | Entry Gate | Exit Gate |
| --- | --- | --- | --- |
| 1 | Reduce command/orchestration file size | profile rollout complete | large command files split without behavior regressions |
| 2 | Improve package release hygiene | stabilized docs/tests | publish flow is scripted or explicitly documented end to end |
| 3 | Grow non-default profile coverage | rollout stable | more Tier 1 and Tier 2 profile packs are mechanically proven, not just documented |

## Release Gates

- `agentic_base` passes analyze, format check, and test locally and in CI
- generated app smoke tests pass in CI for the retained heavy starter lanes (GitHub cubit plus riverpod and mobx runtime variants)
- GitLab scaffold semantics remain covered by contract validators and repo-level tests instead of a duplicate full generated-app lane
- the pinned macOS generated-app native gate passes in CI
- `init` parity, deterministic module versioning, and startup-seam regressions stay covered by package tests
- command docs, generated docs, adapters, and roadmap agree
- generated verify/release-preflight evidence remains downloadable in downstream CI
- `dart pub publish --dry-run` passes before publication
- Gitflow PR routing and CI gates stay aligned with the documented branch model

## Open Questions

- Should module inventory be generated from `ModuleRegistry` to avoid README drift?
- Will repo-level GitLab automation for `agentic_base` itself be needed later, or should support stay limited to generated projects?

## References

- [`plans/260409-1140-agentic-base-implementation/plan.md`](../plans/260409-1140-agentic-base-implementation/plan.md)
- [`plans/260409-1140-agentic-base-implementation/reports/red-team-review.md`](../plans/260409-1140-agentic-base-implementation/reports/red-team-review.md)
- [`plans/260414-1126-harness-contract-v1-and-flutter-support-tiers/plan.md`](../plans/260414-1126-harness-contract-v1-and-flutter-support-tiers/plan.md)
- [`docs/08-harness-contract-v1.md`](./08-harness-contract-v1.md)
- [`docs/11-eval-and-evidence-model.md`](./11-eval-and-evidence-model.md)
- [`lib/src/modules/module_registry.dart`](../lib/src/modules/module_registry.dart)
