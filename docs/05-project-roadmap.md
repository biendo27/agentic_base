# 05. Project Roadmap

## Current Status

The original generator foundation is complete.

Harness Contract V1 implementation is landed in generator code, generated scripts, CI templates, validators, and regression tests.

The profile-execution rollout is also complete: `subscription-commerce-app` is now the shipped CLI default, preset resolution drives starter seams and verify policy from one source of truth, the default starter theme is the trustworthy-commerce family, and the default payment seam is store-native via `in_app_purchase`.

Validation is green on `dart analyze --fatal-infos`, the doc and generator-focused tests, shell syntax checks, the generated-app smoke regression, and the full `dart test` suite.

The observability contract and agent legibility milestone is now complete: repo-scoped runtime telemetry, structured evidence exports, and a single derived local inspect surface are landed and regression-covered.

The CI speed and generated-app hardening wave is complete: root package CI now has fast required tests plus conditional generated/native gates, generated CI/CD templates render provider variables safely, PR CI avoids credentialless prod builds, generated create supports explicit verification modes, iOS AdMob metadata is root-dict-safe, and generated strict lint is opt-in.

The next active milestone is command/orchestration modularization so large command files can be split without changing behavior.

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
| 11. Generator Contract Hardening | Completed | Run/flavor contract, dependency catalog, Firebase setup, DI startup split, and default runtime safety shipped. |
| 12. CI Speed And Generated App Hardening | Completed | Fast root CI taxonomy, explicit generated verify modes, render-safe CI templates, AdMob plist repair, and strict lint mode shipped. |

## Next Milestone

### Milestone: Command/Orchestration Modularization

Status:

- Next
- Split large command files without changing behavior
- Keep command orchestration thin enough to maintain without behavior drift
- Preserve the current run, Firebase, and DI contracts while modularizing

Defined outputs:

- keep `.info/agentic.yaml` as the single machine-readable source of truth
- prevent drift between generated surfaces, validators, and docs
- keep evidence and approval outputs stable across local and CI execution
- preserve honest Flutter SDK contract handling during future upgrades
- keep generated apps credential-safe before Firebase/AdMob setup

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
| 1 | Reduce command/orchestration file size | hardening wave stable | large command files split without behavior regressions |
| 2 | Improve package release hygiene | stabilized docs/tests | publish flow is scripted or explicitly documented end to end |
| 3 | Grow non-default profile coverage | rollout stable | more Tier 1 and Tier 2 profile packs are mechanically proven, not just documented |

## Release Gates

- `agentic_base` passes analyze, format check, and test locally and in CI
- generated app smoke tests pass in CI when generator/template/module/harness paths require them
- GitLab scaffold semantics remain covered by contract validators and repo-level tests instead of a duplicate full generated-app lane
- the pinned macOS generated-app native gate passes when native/template/module paths require it
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
