# Phase 01: Repair Init Contract Truth And Canonical Context

## Context Links

- [Plan overview](./plan.md)
- [Review findings snapshot](./reports/agent-ready-review-findings.md)
- [`docs/03-code-standards.md`](../../docs/03-code-standards.md)
- [`docs/04-system-architecture.md`](../../docs/04-system-architecture.md)

## Overview

- Priority: P0
- Status: Proposed
- Goal: make `init` produce the same truthful agent-ready contract that the repo claims publicly.

## Key Insights

- The current breach is structural, not cosmetic: `.info/agentic.yaml` points to files that do not exist after `init`.
- Narrowing docs without fixing generated output would still leave retrofit repos below the target architecture.
- The safest product position is one contract per repo, not one contract for `create` and another undocumented reality for `init`.

## Requirements

- Make `init` generate or sync the generator-owned docs, metadata, scripts, and adapters required by the agent-ready contract.
- Keep `init` non-destructive for user-owned app logic and credentials.
- Ensure `.info/agentic.yaml`, generated docs, and thin adapters all derive from the same canonical source.
- Fail `init` if the repo cannot satisfy the minimum agent-ready contract instead of writing false metadata.

## Architecture

- Treat generator-owned repo surfaces as a named scaffold set: metadata, docs, adapters, `tools/`, CI/release wrappers.
- `create` and `init` must both materialize that scaffold set, with `init` using additive sync only.
- `GeneratedProjectContract` and metadata writers must validate existence before declaring contract entries.

## Related Code Files

- Modify:
  - `/Users/biendh/base/lib/src/cli/commands/init_command.dart`
  - `/Users/biendh/base/lib/src/config/agent_ready_repo_contract.dart`
  - `/Users/biendh/base/lib/src/config/agentic_config.dart`
  - `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`
  - `/Users/biendh/base/README.md`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/AGENTS.md`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/CLAUDE.md`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/*.md`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/*.sh`

## Implementation Steps

1. Inventory the full generator-owned scaffold set currently emitted by `create`.
2. Make `init` converge on that scaffold set with additive writes and safe skips for existing files.
3. Tighten metadata generation so `.info/agentic.yaml` only lists files that were materialized.
4. Add integration tests that run `init` in a fresh Flutter app and assert contract/file parity.
5. Update package docs/help text so retrofit behavior is described honestly.

## Todo List

- [ ] Define the minimum scaffold set that every initialized repo must receive
- [ ] Converge `init` onto that scaffold set
- [ ] Guard metadata against nonexistent files
- [ ] Add `init` contract parity tests
- [ ] Sync package-facing docs and help

## Success Criteria

- A repo initialized via `init` contains the same generator-owned agent surfaces the metadata declares.
- `GeneratedProjectContract` passes for both `create` and `init` flows.
- No generated adapter or doc points to missing files.

## Risk Assessment

- Risk: `init` begins overwriting user-owned docs or scripts.
- Mitigation: keep an explicit generator-owned file allowlist and additive sync rules.

## Security Considerations

- Never create or rewrite secret files during retrofit.
- Keep human-only approval and credential boundaries explicit in generated docs.

## Next Steps

- Phase 02 repairs the release/provider surfaces that depend on the now-truthful contract.
