# Phase 06: Validation, Docs, And Release Evidence

## Context Links

- `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`
- `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`
- `/Users/biendh/base/docs/02-codebase-summary.md`
- `/Users/biendh/base/docs/03-code-standards.md`
- `/Users/biendh/base/docs/04-system-architecture.md`
- `/Users/biendh/base/docs/14-sdk-and-version-policy.md`
- `/Users/biendh/base/docs/15-default-app-service-matrix.md`

## Overview

Priority: P1. Status: Complete.

Validate the entire new contract, update docs, and prove a freshly generated app runs on Android with the default profile.

## Key Insights

- Existing generated app verification did not catch Android runtime crashes before manual device run.
- Contract docs must change with `.info.execution.run`, Firebase setup, and service layout.
- Generated app smoke should include the failure modes found in `/Users/biendh/StudioProjects/my_app`.

## Requirements

- Package validation passes:
  - `dart pub get`
  - `dart analyze --fatal-infos`
  - `dart format --set-exit-if-changed lib bin test`
  - `dart test`
- Generated app validation passes:
  - states: `cubit`, `riverpod`, `mobx`
  - modules: default profile, `analytics`, `crashlytics`, `remote_config`, `notifications`, `ads`, `deep_link`
  - flavors: `dev`, `staging`, `prod` command composition
  - `GeneratedProjectContract.validate(..., stateManagement: <state>)` for every state
  - `dart analyze --fatal-infos`
  - `flutter test`
- Android native launch smoke is blocking. If no emulator/device is available, mark Phase 06 BLOCKED and do not claim runtime crash fixes verified.
- Android evidence must include:
  - exact `./tools/run.sh dev -d <device>` command
  - device/emulator id
  - captured log window
  - assertions for no `FATAL EXCEPTION`, no `Zone mismatch`, no `Unhandled Exception`
- Docs reflect `run.sh`, Firebase setup flow, dependency policy, DI/startup split, and `lib/services`.
- Evidence notes generated app native run result.

## Architecture

```text
repo tests -> generated app smoke -> native Android run -> docs/evidence update
```

## Related Code Files

- Modify `/Users/biendh/base/docs/02-codebase-summary.md`.
- Modify `/Users/biendh/base/docs/03-code-standards.md`.
- Modify `/Users/biendh/base/docs/04-system-architecture.md`.
- Modify `/Users/biendh/base/docs/10-manifest-schema.md`.
- Modify `/Users/biendh/base/docs/14-sdk-and-version-policy.md`.
- Modify `/Users/biendh/base/docs/15-default-app-service-matrix.md`.
- Modify `/Users/biendh/base/README.md`.
- Modify generated app brick docs under `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/`.

## Implementation Steps

1. Update repo docs and README.
2. Update generated app docs and adapters.
3. Add or update generated-app smoke tests:
   - no `run-dev.sh`
   - `run.sh` exists
   - Firebase options under `lib/services/firebase`
   - no root `lib/firebase_options.dart`
   - no `module_registrations.dart` for GetIt
   - service modules under `lib/services`
   - AdMob metadata present
   - no `uni_links`
4. Add state-management matrix validation for cubit, riverpod, and mobx.
5. Run package validation.
6. Generate a fresh default app in temp or `/Users/biendh/StudioProjects`.
7. Run generated app validation.
8. Run Android native smoke on emulator/device and inspect logcat for:
   - no `FATAL EXCEPTION`
   - no `Zone mismatch`
   - no `Unhandled Exception`
9. Record remaining non-blockers in docs or release notes.

## Todo List

- [x] Update repo docs.
- [x] Update generated docs.
- [x] Add generated app smoke assertions.
- [x] Run package validation.
- [x] Run fresh generated app validation.
- [x] Run blocking Android device/emulator smoke.

## Success Criteria

- All package tests pass.
- Fresh generated default app builds and runs.
- Fresh generated default app launches on Android without fatal native or Flutter boot errors.
- Generated app contract matches docs.
- Known manual fixes from `my_app` are covered by automated tests.

## Risk Assessment

- Full generated-app smoke can be slow. Keep unit tests fast and native run optional/local if CI lacks device.
- Docs can drift if tests do not assert generated file paths and command names.

## Security Considerations

- Ensure docs preserve credential boundary.
- Do not ask users to commit Firebase tokens, service accounts, keystores, or real production ad ids.

## Next Steps

After this phase, implementation should be ready for gitflow review and release planning.
