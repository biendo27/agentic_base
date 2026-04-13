# Phase 02: Generate Agent Context And Execution Harness

## Context Links

- [Proposal overview](./plan.md)
- [Phase 01](./phase-01-reset-product-contract-and-command-surface.md)
- [`docs/02-codebase-summary.md`](../../docs/02-codebase-summary.md)
- [`docs/03-code-standards.md`](../../docs/03-code-standards.md)

## Overview

- Priority: P0
- Status: Proposed
- Goal: every generated repo must expose context and runnable entrypoints that let external agents work effectively on day one.

## Key Insights

- Agents work best when setup, run, verify, and release commands are explicit and stable.
- `AGENTS.md` should be a short table of contents, not a giant instruction dump.
- Vendor-specific instruction files should be generated from one canonical source to avoid drift.

## Requirements

- Generate a canonical agent context package:
  - `AGENTS.md` as short entrypoint
  - `docs/` as canonical long-form context
  - `.info/agentic.yaml` as machine-readable metadata
- Generate deterministic harness scripts:
  - setup
  - run
  - verify
  - build
  - release-preflight
- Generate vendor adapters from the same source:
  - `AGENTS.md`
  - `CLAUDE.md`
  - optionally `.github/copilot-instructions.md` if supported later
- Encode human checkpoints:
  - product approvals
  - secrets setup
  - store/release approvals

## Architecture

- Context surfaces:
  - `.info/agentic.yaml`: stack, state profile, environments, release targets, owner checkpoints
  - `docs/`: overview, architecture, standards, deployment, review/release contract
  - `AGENTS.md`: entrypoint with links only
- Harness surfaces:
  - `tools/setup.sh`
  - `tools/run-dev.sh`
  - `tools/verify.sh`
  - `tools/build.sh`
  - `tools/release-preflight.sh`
- Generator internals:
  - add a small contract builder, not a new runtime subsystem
  - derive all generated instruction files from one structured source

## Related Code Files

- Modify:
  - `lib/src/config/agentic_config.dart`
  - `lib/src/generators/project_generator.dart`
  - `lib/src/generators/generated_project_contract.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/AGENTS.md`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/CLAUDE.md`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/build.sh`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/ci-check.sh`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`
- Add within existing structure:
  - generated docs files under the app brick
  - missing harness scripts under `tools/`

## Implementation Steps

1. Expand `.info/agentic.yaml` with agent-relevant metadata, not product prose.
2. Refactor generated `AGENTS.md` into a short TOC and derive vendor shims from the same source.
3. Add missing setup/run/verify/release-preflight scripts.
4. Ensure scripts are deterministic and CI-safe.
5. Extend smoke tests to assert these files exist and are internally consistent.

## Todo List

- [ ] Define v2 metadata schema
- [ ] Generate canonical docs + thin adapters
- [ ] Add deterministic harness scripts
- [ ] Add contract/smoke assertions for harness presence

## Success Criteria

- An external agent can boot a fresh repo without guessing commands.
- Generated instruction files no longer drift by state-management profile or CI provider.
- Human review points are explicit, finite, and visible in generated docs.

## Risk Assessment

- Risk: too much generated prose becomes stale.
- Mitigation: keep `AGENTS.md` thin and move long-lived context into a few canonical docs.

## Security Considerations

- Scripts must fail fast when secrets or store credentials are missing.
- No hidden secret locations; generated docs must name required env vars and files explicitly.

## Next Steps

- Phase 3 turns verify and release from placeholders into blocking contracts.
