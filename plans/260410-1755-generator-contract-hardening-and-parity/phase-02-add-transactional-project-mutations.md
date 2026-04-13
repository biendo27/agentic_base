# Phase 02 — Add Transactional Project Mutations

## Context Links

- [Plan Overview](./plan.md)
- [Phase 01](./phase-01-lock-canonical-contract-model.md)

## Overview

- Priority: P1
- Status: Completed
- Goal: make `create`, `init`, `add`, and `remove` fail atomically instead of leaving partial project state.
- Result: project mutations now journal file/pubspec/bootstrap/config changes and commit config only after successful mutation flow.

## Key Insights

- `create --modules` currently logs module failures and continues.
- `ModuleInstaller` owns config mutation even though it is a low-level file helper.
- The current flow has no journal of file/pubspec/bootstrap/config mutations, so rollback cannot be trusted.

## Requirements

- Introduce a mutation plan/journal layer that records intended file, YAML, bootstrap, and config edits before commit.
- Make module failures fatal during `create`.
- Move final `.info/agentic.yaml` writes to command/generator orchestration, not `ModuleInstaller`.
- Preserve current command surface and exit-code behavior.

## Architecture

Data flow:
1. Command resolves intent into a `ProjectMutationPlan`.
2. Journal stages file writes, pubspec edits, registry edits, and config mutations.
3. Executor applies the plan in deterministic order.
4. Verification step runs command-specific checks.
5. Commit persists config; failure triggers rollback of the journaled changes.

## Related Code Files

- Modify: `lib/src/generators/project_generator.dart`
- Modify: `lib/src/cli/commands/create_command.dart`
- Modify: `lib/src/cli/commands/init_command.dart`
- Modify: `lib/src/cli/commands/add_command.dart`
- Modify: `lib/src/cli/commands/remove_command.dart`
- Modify: `lib/src/modules/module_installer.dart`
- Modify: `lib/src/modules/base_module.dart`
- Create: transaction helpers under `lib/src/generators/` or `lib/src/modules/`

## Implementation Steps

1. Define mutation primitives for file writes/deletes, YAML edits, and config updates.
2. Refactor `ModuleInstaller` to perform only file/pubspec work.
3. Wrap `create` module install flow in one transaction; abort on the first module failure.
4. Wrap `add` and `remove` in the same transaction semantics.
5. Add rollback coverage with injected failures after partial writes.

## Todo List

- [x] Mutation primitives defined
- [x] Journal/rollback executor defined
- [x] `create` no longer swallows module failures
- [x] `ModuleInstaller` no longer writes config
- [x] rollback tests added

## Success Criteria

- Injected failure in any module install leaves no kept project with mismatched config/modules.
- `add` and `remove` either fully succeed or fully revert.
- `create` exits non-zero on any module failure and cleans the target directory.

## Risk Assessment

- Residual: any new write path must be routed through the journal before commit.
- Residual: keep the transaction layer small and composable; avoid AST or VCS snapshotting.

## Security / Integrity Considerations

- Atomic mutation boundaries prevent misleading project state after failed commands.
- Centralized commit order makes auditing and debugging command behavior possible.

## Rollback Plan

- Keep command orchestration wrappers thin so the transaction layer can be removed without changing CLI parsing.
- If rollback logic proves unstable, disable new command paths behind one internal switch and retain tests as failing spec until fixed.

## Next Steps

- Phase 03 can now rely on deterministic create behavior.
- Phase 04 can layer safe `init` repair/migration on top of the same journal.
