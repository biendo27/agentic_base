# 05. Project Roadmap

## Current Status

The original generator foundation is complete, and the active milestone has now been implemented locally. [`plans/260413-1238-agent-ready-repo-generator-v2-hard/plan.md`](../plans/260413-1238-agent-ready-repo-generator-v2-hard/plan.md) repositioned `agentic_base` as a generator for agent-ready repos with one canonical context source, deterministic harness scripts, honest release boundaries, and bounded upgrade sync for generator-owned surfaces.

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

### Milestone: Agent-Ready Repo Generator V2

Target outcome:

- generated repos keep one machine-readable contract in `.info/agentic.yaml`
- canonical repo context lives in generated `README.md` and `docs/`
- `AGENTS.md` and `CLAUDE.md` stay thin adapters derived from the same source
- deterministic `tools/` entrypoints exist for setup, run, verify, build, and release preflight
- generated CI/release surfaces contain no placeholder behavior
- upgrade syncs generator-owned files without rewriting user-owned app logic

## Release Gates

- `agentic_base` passes analyze, format check, and test locally and in CI
- generated app smoke tests pass in CI for GitHub and GitLab scaffolds
- the pinned macOS generated-app native gate passes in CI
- command docs, generated docs, adapters, and roadmap agree
- `dart pub publish --dry-run` passes before publication

## Open Questions

- Should module inventory be generated from `ModuleRegistry` to avoid README drift?
- Will repo-level GitLab automation for `agentic_base` itself be needed later, or should support stay limited to generated projects?

## References

- [`plans/260409-1140-agentic-base-implementation/plan.md`](../plans/260409-1140-agentic-base-implementation/plan.md)
- [`plans/260409-1140-agentic-base-implementation/reports/red-team-review.md`](../plans/260409-1140-agentic-base-implementation/reports/red-team-review.md)
- [`lib/src/modules/module_registry.dart`](../lib/src/modules/module_registry.dart)
