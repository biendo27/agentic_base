# Phase 01: Repair Runtime Honesty And Toolchain Contract

## Context Links

- [Plan overview](./plan.md)
- [Research summary](./research/research-summary.md)
- [Generator gap analysis](../reports/researcher-260415-0946-generator-gap-analysis.md)
- [SDK policy doc](../../docs/14-sdk-and-version-policy.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: make the declared Flutter SDK contract executable, not just writable.

## Key Insights

- current drift is mostly in command execution, not manifest shape
- generated repos should not be stamped as honest if the selected manager cannot run
- test runtime is downstream of this phase because subprocess resolution is centralized here

## Requirements

- resolve an executable Flutter/Dart toolchain before writing repo metadata
- persist both `preferred` and `resolved` manager/version state in an honest traceable form
- make `create`, `init`, `add`, `remove`, `gen`, and `upgrade` respect the resolved toolchain
- implement this fallback order:
  1. preferred manager if executable
  2. repo-local inferred manager if executable
  3. system Flutter
  4. fail if no Flutter SDK is available
- keep legacy-repo migration explicit and testable
- align public claims only after end-to-end enforcement exists
<!-- Updated: Validation Session 1 - preferred/resolved toolchain values stay manifest-facing, not README-facing -->

## Architecture

- introduce one manager-aware executable resolution path for Flutter and Dart subprocesses
- separate user preference (`preferred`) from actual executable selection (`resolved`)
- keep fallback selection deterministic and inspectable
- make command tests prove the resolved manager is actually used
- keep `preferred` vs `resolved` visibility primarily in manifest/runtime metadata so agents can reason about it without cluttering human-facing generated docs

## Related Code Files

- Modify:
  - `/Users/biendh/base/lib/src/config/flutter_sdk_contract.dart`
  - `/Users/biendh/base/lib/src/config/init_project_metadata_resolver.dart`
  - `/Users/biendh/base/lib/src/generators/project_generator.dart`
  - `/Users/biendh/base/lib/src/cli/commands/create_command.dart`
  - `/Users/biendh/base/lib/src/cli/commands/init_command.dart`
  - `/Users/biendh/base/lib/src/cli/commands/add_command.dart`
  - `/Users/biendh/base/lib/src/cli/commands/remove_command.dart`
  - `/Users/biendh/base/lib/src/cli/commands/gen_command.dart`
  - `/Users/biendh/base/lib/src/cli/commands/upgrade_command.dart`
  - `/Users/biendh/base/test/src/cli/commands/create_command_test.dart`
  - `/Users/biendh/base/test/src/cli/commands/add_command_test.dart`
  - `/Users/biendh/base/test/src/cli/commands/remove_command_test.dart`
- Create:
  - manager-aware command coverage where missing
- Delete:
  - none expected

## Implementation Steps

1. Introduce one reusable toolchain-runner abstraction for Flutter and Dart subprocesses.
2. Make `create` and `init` resolve the requested preference into an actual executable manager before writing metadata.
3. Route generator and command subprocesses through the resolved manager.
4. Clarify fallback behavior and failure messages, including preferred-vs-resolved traceability.
5. Update tests to assert manager-aware execution, not hard-coded `flutter` / `dart`.

## Todo List

- [x] Add manager-aware subprocess abstraction
- [x] Resolve preferred manager into a concrete executable selection
- [x] Persist preferred and resolved toolchain values
- [x] Route all relevant commands through the abstraction
- [x] Add negative-path tests for missing `fvm` / `puro`
- [x] Sync docs claims only after tests are green

## Execution Notes

- Added `resolveFlutterToolchain(...)` so create/init/add/remove/gen/upgrade all build Flutter and Dart subprocesses from one fallback-aware resolver.
- `FlutterSdkContract` now persists resolved `manager` / `version` plus manifest-facing `preferred_manager` / `preferred_version`.
- `ProjectGenerator`, `InitProjectMetadataResolver`, and the touched CLI commands now update metadata with honest resolved values after command execution.
- Added regression coverage for fallback order, manager-aware command shapes, init metadata honesty, and command-level execution paths.

## Verification

- `dart analyze --fatal-infos`
- `dart test`

## Success Criteria

- generated repos cannot claim a resolved manager they cannot execute
- command tests prove the resolved manager is used end to end
- legacy upgrade behavior remains explicit and non-deceptive

## Risk Assessment

- Risk: migration behavior becomes confusing for older repos
- Mitigation: keep one clearly documented migration path and test both strict and legacy cases

## Security Considerations

- toolchain validation must not shell-expand untrusted user input
- no credentials or host secrets may be written into manifest fallback states

## Next Steps

- Phase 02 defines the generated app contracts that will sit on top of the repaired runtime base.
