# Scout Report

## Summary

Relevant current repo surfaces for this plan:

- `README.md`
- `docs/01-project-overview-pdr.md`
- `docs/03-code-standards.md`
- `docs/04-system-architecture.md`
- `docs/05-project-roadmap.md`
- `lib/src/config/agent_ready_repo_contract.dart`
- `lib/src/config/agentic_config.dart`
- `lib/src/cli/commands/doctor_command.dart`
- `lib/src/cli/commands/upgrade_command.dart`
- `lib/src/generators/generated_project_contract.dart`
- `lib/src/generators/project_generator.dart`
- generated app template docs/scripts under `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/`

## Key Pattern Findings

- Current contract is repo-centric and script-centric.
- Module/provider seams exist in code, but manifest-level provider policy is not yet formalized.
- Eval today is closer to project verification than harness verification.
- Versioning policy is partially deterministic but not yet complete.

## Planning Implication

- The next design step should formalize contract, scope, manifest, eval, and adapter boundaries before any large implementation wave.

## Unresolved Questions

- None beyond plan-level open questions.

