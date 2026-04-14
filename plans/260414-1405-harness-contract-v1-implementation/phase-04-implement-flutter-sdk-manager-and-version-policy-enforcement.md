# Phase 04: Implement Flutter SDK Manager And Version Policy Enforcement

## Context Links

- [Plan overview](./plan.md)
- [Flutter adapter boundaries](../../docs/13-flutter-adapter-boundaries.md)
- [SDK and version policy](../../docs/14-sdk-and-version-policy.md)
- [System architecture](../../docs/04-system-architecture.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: make the declared Flutter toolchain contract executable in doctor/create/upgrade flows.

## Key Insights

- Current environment checks only treat FVM as an optional tool and do not model Puro at all.
- Current upgrade behavior upgrades packages but does not enforce or migrate the Flutter SDK contract.
- Reliability requires explicit manager and tested-version policy, not "whatever Flutter is installed".

## Requirements

- Support declared manager modes: `system`, `fvm`, `puro`.
- Persist manager and version policy in the harness manifest.
- Make doctor report both declared and discovered toolchains.
- Prevent silent SDK jumps during upgrade and release-preflight.

## Architecture

- Add typed SDK metadata to the harness manifest.
- Doctor should compare manifest-declared toolchain against the local environment.
- Create/init should select or infer a supported toolchain strategy honestly.
- Upgrade should sync generator-owned surfaces without silently changing the declared Flutter manager or tested version.

## Related Code Files

- Modify:
  - `/Users/biendh/base/lib/src/cli/commands/doctor_command.dart`
  - `/Users/biendh/base/lib/src/cli/commands/upgrade_command.dart`
  - `/Users/biendh/base/lib/src/generators/project_generator.dart`
  - `/Users/biendh/base/lib/src/config/init_project_metadata_resolver.dart`
  - `/Users/biendh/base/lib/src/config/project_metadata.dart`
  - `/Users/biendh/base/lib/src/config/agentic_config.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/pubspec.yaml`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/_common.sh`
  - `/Users/biendh/base/test/src/cli/commands/upgrade_command_test.dart`
  - `/Users/biendh/base/test/src/generators/project_generator_test.dart`
- Create:
  - None expected
- Delete:
  - None expected

## Implementation Steps

1. Extend manifest and metadata models with SDK manager fields.
2. Update doctor to resolve and compare `system`, `fvm`, and `puro`.
3. Update create/init to write the declared policy.
4. Update upgrade and preflight flows to preserve and validate the toolchain contract.
5. Add unit and integration coverage for manager detection and mismatch failures.

## Todo List

- [x] Extend manifest with SDK manager fields
- [x] Implement manager detection and comparison
- [x] Persist manager policy during create/init
- [x] Preserve policy during upgrade/preflight
- [x] Add toolchain mismatch tests

## Success Criteria

- Repos can declare and validate a tested Flutter toolchain.
- Doctor reports meaningful mismatch states.
- Upgrade does not silently move the repo onto an unverified SDK.

## Risk Assessment

- Risk: environment handling becomes too platform-specific and brittle.
- Mitigation: keep manager detection narrow, explicit, and separately testable.

## Security Considerations

- Toolchain mismatch failures must block release-preflight where appropriate.
- Manager metadata must remain declarative and free of machine-specific secrets.

## Next Steps

- Completed. Phase 05 locks the rollout behind regression tests and claim-safe docs.
