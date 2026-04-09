# 05. Project Roadmap

## Current Status

The core implementation plan for `agentic_base` is marked complete in [`plans/260409-1140-agentic-base-implementation/plan.md`](../plans/260409-1140-agentic-base-implementation/plan.md). The repo has now also been flattened so the package lives at root.

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
2. Add real end-to-end generation tests in CI.
   Current CI verifies the package, not a generated app.
3. Reduce oversized command files.
   `init`, `deploy`, `eval`, `brick`, and `project_generator` exceed the repo target.
4. Make deployment expectations concrete.
   `deploy` expects `cd-<env>.yml`, but workflow templates are not bundled here.
5. Decide whether root-level `CLAUDE.md` is still needed.
   `README.md` now exists at root, but AI-instruction surface is still split.

## Suggested Next Milestone

### Milestone: Release Hardening

Target outcome:

- package docs and code inventory agree
- generated-app smoke test runs in CI
- release path for pub.dev is documented and rehearsed
- deployment command either ships workflow templates or documents the external contract clearly
- large command files are split into smaller orchestration helpers

## Release Gates

- `agentic_base` passes analyze, format check, and test locally and in CI
- at least one generated app smoke test passes in CI
- command docs, module inventory, and roadmap agree
- `dart pub publish --dry-run` passes before publication

## Open Questions

- Should module inventory be generated from `ModuleRegistry` to avoid README drift?
- Will generated-project deployment workflows live in the app brick, or in downstream repos only?

## References

- [`plans/260409-1140-agentic-base-implementation/plan.md`](../plans/260409-1140-agentic-base-implementation/plan.md)
- [`plans/260409-1140-agentic-base-implementation/reports/red-team-review.md`](../plans/260409-1140-agentic-base-implementation/reports/red-team-review.md)
- [`lib/src/modules/module_registry.dart`](../lib/src/modules/module_registry.dart)
