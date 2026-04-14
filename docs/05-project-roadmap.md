# 05. Project Roadmap

## Current Status

The original generator foundation is complete. The active hardening lane is now the trust-repair follow-up in [`plans/260413-1616-agent-ready-repo-generator-trust-repair/plan.md`](../plans/260413-1616-agent-ready-repo-generator-trust-repair/plan.md), which closes the remaining gaps between repo claims and executable reality for `init`, GitLab deploy, deterministic module installs, and startup-bound runtime seams.

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

### Milestone: Agent-Ready Repo Generator Trust Repair

Target outcome:

- `init` syncs the same generator-owned scaffold source as `create` and `upgrade`, or fails instead of fabricating a contract
- GitLab deploy resolves real generated manual job names for each environment
- installable module dependencies come from a repo-owned version catalog with no `any` fallback
- Firebase-backed and startup-bound modules wire through the owned bootstrap seam, including a generated `firebase_options.dart` stub and non-fetching remote-config init
- README, architecture, deployment docs, and roadmap only claim behavior backed by code or tests

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

## References

- [`plans/260409-1140-agentic-base-implementation/plan.md`](../plans/260409-1140-agentic-base-implementation/plan.md)
- [`plans/260409-1140-agentic-base-implementation/reports/red-team-review.md`](../plans/260409-1140-agentic-base-implementation/reports/red-team-review.md)
- [`lib/src/modules/module_registry.dart`](../lib/src/modules/module_registry.dart)
