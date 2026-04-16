# Phase 02 — Implement Dry-Run And End-To-End Toolchain Honesty

## Context Links

- [plan.md](./plan.md)
- [docs-and-command-contract-review](./research/docs-and-command-contract-review.md)
- [EvalCommand](</Users/biendh/base/lib/src/cli/commands/eval_command.dart>)
- [DoctorCommand](</Users/biendh/base/lib/src/cli/commands/doctor_command.dart>)
- [Flutter Toolchain Runtime](</Users/biendh/base/lib/src/config/flutter_toolchain_runtime.dart>)

## Overview

- Priority: P0
- Status: Pending
- Goal: make command behavior match manifest/toolchain claims and add a truthful `--dry-run` contract across the CLI surface.

## Key Insights

- `eval` still shells out to bare `flutter`.
- `doctor` still partially assumes bare `dart`.
- generated docs still teach bare `flutter test`.
- dry-run cannot be bolted on command by command with inconsistent semantics.
<!-- Updated: Validation Session 1 - dry-run is preview-only and executes nothing, even for read-only commands -->

## Requirements

- Every command supports `--dry-run`.
- Dry-run never mutates files, executes checks, spawns builds/tests, or triggers remote side effects.
- Read-only commands still expose useful dry-run output.
- Toolchain resolution uses one shared contract path.

## Architecture

- Add one CLI-level dry-run abstraction:
  - command flag parsing
  - shared formatter for “would run / would read / would write / would delete / would call”
  - shared exit semantics
- Add one execution abstraction for toolchain-aware commands:
  - resolve project toolchain once
  - pass command specs to runners
  - dry-run serializes command specs without executing
- Apply to:
  - `create`
  - `init`
  - `upgrade`
  - `add`
  - `remove`
  - `feature`
  - `gen`
  - `eval`
  - `deploy`
  - `doctor`
  - `brick`

## Related Code Files

- Modify:
  - [lib/src/cli/cli_runner.dart](/Users/biendh/base/lib/src/cli/cli_runner.dart)
  - [lib/src/cli/commands/create_command.dart](/Users/biendh/base/lib/src/cli/commands/create_command.dart)
  - [lib/src/cli/commands/init_command.dart](/Users/biendh/base/lib/src/cli/commands/init_command.dart)
  - [lib/src/cli/commands/upgrade_command.dart](/Users/biendh/base/lib/src/cli/commands/upgrade_command.dart)
  - [lib/src/cli/commands/add_command.dart](/Users/biendh/base/lib/src/cli/commands/add_command.dart)
  - [lib/src/cli/commands/remove_command.dart](/Users/biendh/base/lib/src/cli/commands/remove_command.dart)
  - [lib/src/cli/commands/feature_command.dart](/Users/biendh/base/lib/src/cli/commands/feature_command.dart)
  - [lib/src/cli/commands/gen_command.dart](/Users/biendh/base/lib/src/cli/commands/gen_command.dart)
  - [lib/src/cli/commands/eval_command.dart](/Users/biendh/base/lib/src/cli/commands/eval_command.dart)
  - [lib/src/cli/commands/doctor_command.dart](/Users/biendh/base/lib/src/cli/commands/doctor_command.dart)
  - [lib/src/cli/commands/deploy_command.dart](/Users/biendh/base/lib/src/cli/commands/deploy_command.dart)
  - [lib/src/cli/commands/brick_command.dart](/Users/biendh/base/lib/src/cli/commands/brick_command.dart)
  - shared runners under `lib/src/deploy/` or `lib/src/cli/`
- Add:
  - shared dry-run utility/module
  - command tests for dry-run output and zero-side-effect guarantees

## Implementation Steps

1. Define dry-run semantics by command category, with one invariant: preview only and zero execution.
2. Add shared command flag plumbing and output formatter.
3. Refactor `eval` to resolve toolchain from `.info/agentic.yaml` and print resolved specs in dry-run mode.
4. Refactor `doctor` to validate through the same toolchain contract and dry-run check plan.
5. Extend mutating commands to preview intended file/process operations before execution.
6. Extend deploy/brick flows so dry-run previews remote commands and file mutations without running them.
7. Update docs and help text to reflect one uniform dry-run contract.

## Todo List

- [ ] define dry-run output contract
- [ ] make `eval` manager-aware
- [ ] make `doctor` manager-aware end to end
- [ ] add dry-run to mutating commands
- [ ] add preview-only dry-run to read-only and remote commands
- [ ] update tests and command help text

## Success Criteria

- `eval` and `doctor` no longer bypass manifest toolchain resolution.
- All commands accept `--dry-run`.
- Dry-run test coverage proves zero side effects.
- Generated docs and CLI help stop teaching bare toolchain paths where manifest-aware wrappers exist.

## Risk Assessment

- Dry-run output can drift if command logic duplicates preview and real execution paths.
- `brick` and `deploy` may require special-case preview logic because they cross process or remote boundaries.

## Security Considerations

- Dry-run must never print sensitive env values or secrets.
- Deploy dry-run must not authenticate or trigger remote jobs.

## Next Steps

- Feed final dry-run wording back into README/docs in Phase 05.
- Reuse toolchain-honest command helpers when generated scripts/docs are synchronized.
