# 05. Project Roadmap

## Current Status

The original generator foundation is complete.

The harness-contract design milestone is now defined in repo docs and plan artifacts. The next milestone is implementation sequencing, not re-litigating product direction.

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

## Active Milestone

### Milestone: Harness Contract V1 And Flutter Support Tiers

Status:

- Architecture definition complete
- Generator implementation not started

Defined outputs:

- define the harness-first repo contract precisely enough to implement without re-litigating product direction
- define truthful support tiers for mainstream Flutter product app profiles
- keep `.info/agentic.yaml` as the single machine-readable source of truth for the next manifest evolution
- define eval, evidence, and approval models before extending generator behavior
- define Flutter adapter and versioning boundaries before any future cross-stack extraction work

Key docs:

- [`docs/08-harness-contract-v1.md`](./08-harness-contract-v1.md)
- [`docs/09-support-tier-matrix.md`](./09-support-tier-matrix.md)
- [`docs/10-manifest-schema.md`](./10-manifest-schema.md)
- [`docs/11-eval-and-evidence-model.md`](./11-eval-and-evidence-model.md)
- [`docs/12-approval-state-machine.md`](./12-approval-state-machine.md)
- [`docs/13-flutter-adapter-boundaries.md`](./13-flutter-adapter-boundaries.md)
- [`docs/14-sdk-and-version-policy.md`](./14-sdk-and-version-policy.md)

## Next Implementation Waves

| Wave | Goal | Entry Gate | Exit Gate |
| --- | --- | --- | --- |
| 1 | Lock terminology, docs, and current-vs-target contract boundaries | Architecture docs approved | doc set reviewed and current scaffold-contract checks stay green |
| 2 | Add manifest schema and support-profile encoding to `.info/agentic.yaml` | Wave 1 merged | create/init/upgrade keep honest manifest state and package tests cover new manifest semantics |
| 3 | Add eval gate expectations, approval metadata, and evidence bundle outputs | manifest fields available | local verify and generated CI emit canonical evidence and package tests cover the new gate vocabulary |
| 4 | Add Flutter SDK manager and version-policy enforcement | evidence model stable | doctor, create, and upgrade can validate tested toolchains |
| 5 | Update public product claims and rollout docs | waves 1-4 shipped | README and generated docs match actual guarantees |

## Release Gates

- `agentic_base` passes analyze, format check, and test locally and in CI
- generated app smoke tests pass in CI for GitHub and GitLab scaffolds
- the pinned macOS generated-app native gate passes in CI
- `init` parity, deterministic module versioning, and startup-seam regressions stay covered by package tests
- command docs, generated docs, adapters, and roadmap agree
- `dart pub publish --dry-run` passes before publication

## Open Questions

- Should module inventory be generated from `ModuleRegistry` to avoid README drift?
- Will repo-level GitLab automation for `agentic_base` itself be needed later, or should support stay limited to generated projects?
- Should evidence bundles stay as local artifacts only, or should generated CI publish them consistently as downloadable artifacts?

## References

- [`plans/260409-1140-agentic-base-implementation/plan.md`](../plans/260409-1140-agentic-base-implementation/plan.md)
- [`plans/260409-1140-agentic-base-implementation/reports/red-team-review.md`](../plans/260409-1140-agentic-base-implementation/reports/red-team-review.md)
- [`plans/260414-1126-harness-contract-v1-and-flutter-support-tiers/plan.md`](../plans/260414-1126-harness-contract-v1-and-flutter-support-tiers/plan.md)
- [`docs/08-harness-contract-v1.md`](./08-harness-contract-v1.md)
- [`docs/11-eval-and-evidence-model.md`](./11-eval-and-evidence-model.md)
- [`lib/src/modules/module_registry.dart`](../lib/src/modules/module_registry.dart)
