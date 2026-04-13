# Phase 01: Reset Product Contract And Command Surface

## Context Links

- [Proposal overview](./plan.md)
- [`README.md`](../../README.md)
- [`docs/04-system-architecture.md`](../../docs/04-system-architecture.md)
- [`docs/05-project-roadmap.md`](../../docs/05-project-roadmap.md)

## Overview

- Priority: P0
- Status: Proposed
- Goal: make the product honest about what it generates and what it does not.

## Key Insights

- The current repo already has useful scaffolding primitives; the problem is not lack of codegen, it is overclaiming agent readiness.
- `feature --spec` is the wrong center. Real projects need repo harnesses, not magical feature DSLs.
- The command surface should reflect actual value: scaffold, context, verify, release.

## Requirements

- Reframe the public promise from "AI generates features" to "repo is optimized for agent execution".
- Keep existing commands stable where possible.
- Reduce wording that implies discovery, reasoning, or full product synthesis inside the CLI.
- Define one canonical generated-project contract and make docs, templates, and tests follow it.

## Architecture

- Product center:
  - `create` and `init` generate an agent-ready repo contract.
  - `feature` remains a convenience scaffold for repetitive local structure.
  - `add/remove` remain capability installers.
- Contract center:
  - one canonical metadata source in `.info/agentic.yaml`
  - one canonical agent-context source in generated docs
  - thin vendor adapters derived from the canonical source

## Related Code Files

- Modify:
  - `README.md`
  - `docs/01-project-overview-pdr.md`
  - `docs/04-system-architecture.md`
  - `docs/05-project-roadmap.md`
  - `lib/src/cli/cli_runner.dart`
  - `lib/src/cli/commands/create_command.dart`
  - `lib/src/cli/commands/init_command.dart`
  - `lib/src/generators/project_generator.dart`
  - `lib/src/generators/generated_project_contract.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`
- Review carefully:
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/AGENTS.md`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/CLAUDE.md`

## Implementation Steps

1. Rewrite product positioning in repo docs and generated-app docs.
2. Define the generated-project v2 contract in one source file or contract helper.
3. Trim or rename any command/help text that implies unsupported intelligence.
4. Add generated-project contract checks that assert the new honesty rules.
5. Make roadmap/docs call out `feature` as scaffold-only.

## Todo List

- [ ] Lock v2 product statement
- [ ] Define canonical generated-project contract
- [ ] Align CLI help text and generated docs
- [ ] Add contract assertions for the new promise

## Success Criteria

- A user reading the repo understands the product correctly in under five minutes.
- No generated docs imply unsupported `discover/spec` intelligence.
- Contract tests fail if docs or templates drift from the new promise.

## Risk Assessment

- Risk: scope creep into redesigning every command.
- Mitigation: keep user-facing command names stable and change semantics/docs first.

## Security Considerations

- Avoid adding remote AI execution or secret-dependent behavior in this phase.
- Keep metadata declarative; no hidden network calls.

## Next Steps

- Phase 2 builds the repo context and execution harness on top of the reset contract.
