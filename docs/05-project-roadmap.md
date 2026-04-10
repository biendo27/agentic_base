# 05. Project Roadmap

## Current Status

The core implementation plan for `agentic_base` is marked complete in [`plans/260409-1140-agentic-base-implementation/plan.md`](../plans/260409-1140-agentic-base-implementation/plan.md). The repo has now also been flattened so the package lives at root.

The default generated app architecture refresh is now implemented in source and fixture form via [`plans/260410-0859-default-generated-app-architecture-refresh/plan.md`](../plans/260410-0859-default-generated-app-architecture-refresh/plan.md).

Dual GitHub/GitLab CI provider selection is now implemented in source via [`plans/260410-1026-dual-github-gitlab-cicd-selection/plan.md`](../plans/260410-1026-dual-github-gitlab-cicd-selection/plan.md).

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

## Immediate Follow-Up Work

1. Align public docs with code reality.
   Current mismatch: README says 25 modules; registry exposes 27.
2. Reduce oversized command files.
   `init`, `eval`, `brick`, `create`, and `project_generator` still exceed the repo target.
3. Decide whether root-level `CLAUDE.md` is still needed.
   `README.md` now exists at root, but AI-instruction surface is still split.
4. Decide whether repo-level GitLab automation for `agentic_base` itself is needed later.
   Current scope stops at generated-project GitLab support.

## Suggested Next Milestone

### Milestone: Release Hardening And CI Portability

Target outcome:

- package docs and code inventory agree
- generated-app smoke test runs in CI for both CI providers
- generated-app ownership and i18n contract stay green under smoke coverage
- generated-app native validation is enforced by a pinned macOS GitHub gate
- deployment command ships provider-aware CI templates and routes through one persisted provider contract
- large command files are split into smaller orchestration helpers where touched

## Release Gates

- `agentic_base` passes analyze, format check, and test locally and in CI
- generated app smoke tests pass in CI for GitHub and GitLab scaffolds
- the pinned macOS generated-app native gate passes in CI
- command docs, module inventory, and roadmap agree
- `dart pub publish --dry-run` passes before publication

## Open Questions

- Should module inventory be generated from `ModuleRegistry` to avoid README drift?
- Will repo-level GitLab automation for `agentic_base` itself be needed later, or should support stay limited to generated projects?

## References

- [`plans/260409-1140-agentic-base-implementation/plan.md`](../plans/260409-1140-agentic-base-implementation/plan.md)
- [`plans/260409-1140-agentic-base-implementation/reports/red-team-review.md`](../plans/260409-1140-agentic-base-implementation/reports/red-team-review.md)
- [`lib/src/modules/module_registry.dart`](../lib/src/modules/module_registry.dart)
