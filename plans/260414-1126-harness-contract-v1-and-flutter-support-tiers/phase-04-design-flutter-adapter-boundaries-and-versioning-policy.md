# Phase 04: Design Flutter Adapter Boundaries And Versioning Policy

## Context Links

- [Plan overview](./plan.md)
- [Phase 02](./phase-02-define-support-tier-matrix-and-manifest-schema.md)
- [Phase 03](./phase-03-design-eval-evidence-and-approval-model.md)
- [System architecture](../../docs/04-system-architecture.md)
- [Flutter adapter boundaries](../../docs/13-flutter-adapter-boundaries.md)
- [SDK and version policy](../../docs/14-sdk-and-version-policy.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: define what stays Flutter-specific and what remains harness core, including SDK/version policy.

## Key Insights

- Flutter has unique runtime/build/release constraints that do not generalize well too early.
- "Always latest SDK" is incompatible with harness reliability.
- Adapter boundaries must be explicit before any future cross-stack extraction.

## Requirements

- Define the Flutter adapter responsibilities.
- Define SDK manager strategy across `flutter`, `fvm`, and `puro`.
- Define version policy as newest tested, not newest available.
- Define which Flutter-specific concerns must never leak into the harness core.

## Architecture

- Harness core should stay independent of:
  - Flutter flavors
  - iOS/Android native shells
  - Fastlane specifics
  - codegen toolchain details
- Flutter adapter should own:
  - environment detection
  - SDK selection rules
  - create/build/run commands
  - native/readiness checks
  - mobile release wrapper semantics

## Related Code Files

- Modify:
  - `/Users/biendh/base/lib/src/cli/commands/doctor_command.dart`
  - `/Users/biendh/base/lib/src/cli/commands/upgrade_command.dart`
  - `/Users/biendh/base/lib/src/generators/project_generator.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/pubspec.yaml`
  - `/Users/biendh/base/docs/04-system-architecture.md`
- Create:
  - `/Users/biendh/base/docs/13-flutter-adapter-boundaries.md`
  - `/Users/biendh/base/docs/14-sdk-and-version-policy.md`
- Delete:
  - None expected

## Implementation Steps

1. Enumerate Flutter-specific concerns currently mixed into the repo contract.
2. Draw the boundary between harness core and Flutter adapter.
3. Define SDK manager selection and fallback behavior.
4. Define version-pinning and upgrade workflow expectations.
5. Document what future cross-stack extraction may reuse and what it may not.

## Todo List

- [x] Define harness-core vs Flutter-adapter boundary
- [x] Define SDK manager strategy
- [x] Define version policy
- [x] Define upgrade workflow expectations
- [x] Document future extraction boundaries

## Success Criteria

- Adapter responsibilities are explicit enough to support later extraction.
- Version policy supports reliability and upgradeability together.
- The repo no longer relies on vague "latest possible" language.

## Risk Assessment

- Risk: adapter boundary stays too fuzzy and future plans reintroduce leakage.
- Mitigation: every major concern gets assigned to either core or adapter explicitly.

## Security Considerations

- Version policy must avoid silent jumps to unverified SDKs.
- Environment checks must fail clearly when tooling is missing or inconsistent.

## Next Steps

- Phase 05 turns the architecture decisions into a real execution roadmap.
