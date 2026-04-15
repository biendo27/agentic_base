# 05. Project Roadmap

## Current Status

The original generator foundation is complete.

Harness Contract V1 implementation is now landed in generator code, generated scripts, CI templates, validators, and regression tests.

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

## Active Milestone

### Milestone: Contract Rollout Stabilization

Status:

- Harness Contract V1 implementation complete
- Shared app contracts now standardize generated starter and feature data/domain boundaries on `fpdart` while keeping presentation state APIs simple
- Generated locale runtime wrapping now lives outside the Slang output tree so contract verification stays stable after regeneration
- Generated starter apps now ship a stronger Material 3 foundation with the exact default Figma palette, exact base typography and measurement tokens, `ThemeData.from(...)`, and internal adaptive helpers instead of ScreenUtil leftovers
- The starter app now proves one day-0 journey: runtime diagnostics, detail navigation, settings, and a provider-neutral monetization screen
- Verification no longer relies mainly on downstream boot smoke: generated apps now ship repository tests, state-runtime tests, a starter widget test, and the package smoke matrix retains only the heavy lanes that still prove unique behavior
- Docs and release claims aligned with shipped behavior
- Remaining work is stabilization, release hygiene, and future generator polish

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

## Next Waves

| Wave | Goal | Entry Gate | Exit Gate |
| --- | --- | --- | --- |
| 1 | Stabilize Harness Contract V1 | current suite green | no contract drift across create/init/upgrade/docs |
| 2 | Reduce command/orchestration file size | contract stable | large command files split without behavior regressions |
| 3 | Improve package release hygiene | stabilized docs/tests | publish flow is scripted or explicitly documented end to end |

## Release Gates

- `agentic_base` passes analyze, format check, and test locally and in CI
- generated app smoke tests pass in CI for the retained heavy starter lanes (GitHub cubit plus riverpod and mobx runtime variants)
- GitLab scaffold semantics remain covered by contract validators and repo-level tests instead of a duplicate full generated-app lane
- the pinned macOS generated-app native gate passes in CI
- `init` parity, deterministic module versioning, and startup-seam regressions stay covered by package tests
- command docs, generated docs, adapters, and roadmap agree
- generated verify/release-preflight evidence remains downloadable in downstream CI
- `dart pub publish --dry-run` passes before publication

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
