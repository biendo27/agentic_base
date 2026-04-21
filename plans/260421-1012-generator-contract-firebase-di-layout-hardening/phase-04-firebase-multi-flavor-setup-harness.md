# Phase 04: Firebase Multi-Flavor Setup Harness

## Context Links

- Research: [Firebase, DI, Layout Report](./research/researcher-firebase-di-layout-report.md)
- `/Users/biendh/base/lib/src/modules/firebase_runtime_template.dart`
- `/Users/biendh/base/lib/src/modules/core/analytics_module.dart`
- `/Users/biendh/base/lib/src/modules/core/crashlytics_module.dart`
- `/Users/biendh/base/lib/src/modules/extended/remote_config_module.dart`
- `/Users/biendh/StudioProjects/meup/lib/config/services/firebase`
- `/Users/biendh/StudioProjects/meup/flavorizr.yaml`
- Firebase Flutter setup: https://firebase.google.com/docs/flutter/setup
- Crashlytics Flutter setup: https://firebase.google.com/docs/crashlytics/flutter/get-started
- flutter_flavorizr Firebase config: https://pub.dev/packages/flutter_flavorizr

## Overview

Priority: P1. Status: Complete.

Add an explicit Firebase setup path for generated apps with `dev/staging/prod` flavors, while keeping generated apps bootable without credentials.

## Key Insights

- Firebase setup is credential-boundary work and must remain human-approved.
- `flutterfire configure` can emit Dart options and native config files with `--out`, `--android-out`, and `--ios-out`.
- `flutter_flavorizr` supports per-flavor Firebase native config paths.
- Generated apps should not crash if setup has not run.

## Requirements

- Add `agentic_base firebase setup` command or equivalent command group.
- Add generated `tools/setup-firebase.sh` wrapper for discoverability.
- `agentic_base firebase setup` runs from a generated repo root by default and supports `--project-dir`.
- Command loads `.info/agentic.yaml` through `AgenticConfig` and fails before mutation if the contract is invalid.
- Command resolves Flutter/Dart through the same project toolchain resolver used by `add`, `gen`, and `eval`.
- Command checks for `firebase`, `flutterfire`, and login/project availability.
- If tools are missing, command exits with install guidance and no partial mutation.
- Support same Firebase project for all flavors and per-flavor project mapping.
- Support default generated platforms Android/iOS/web. Unsupported selected platforms fail before mutation unless implemented.
- Generate per-flavor options under `lib/services/firebase/options/`.
- Generate selector facade `lib/services/firebase/firebase_options.dart`.
- Generate safe runtime `lib/services/firebase/firebase_runtime.dart` returning readiness state, not throwing during app boot.
- Update `flavorizr.yaml` with `firebase.config` paths for Android/iOS flavors.
- Extract and write iOS Google sign-in variables when available.
- All Firebase setup mutations must be staged or journaled. Use `ProjectMutationJournal` or temp-output-then-commit for Dart options, native config files, `.info/agentic.yaml`, and `flavorizr.yaml`.
- On any failed configure/flavorizr/gen step, restore every touched file.

## Architecture

```text
human -> agentic_base firebase setup
      -> check firebase/flutterfire tools
      -> configure dev/staging/prod
      -> write Dart options + native config
      -> patch flavorizr.yaml
      -> run flutter_flavorizr / gen as needed
      -> verify Firebase readiness
```

## Related Code Files

- Create `/Users/biendh/base/lib/src/cli/commands/firebase_command.dart`.
- Modify `/Users/biendh/base/lib/src/cli/cli_runner.dart`.
- Create Firebase setup helper files under `/Users/biendh/base/lib/src/firebase/` or `/Users/biendh/base/lib/src/generators/firebase/`.
- Modify `/Users/biendh/base/lib/src/modules/firebase_runtime_template.dart`.
- Modify Firebase-backed modules under `/Users/biendh/base/lib/src/modules/core/` and `/Users/biendh/base/lib/src/modules/extended/`.
- Create `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/setup-firebase.sh`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/flavorizr.yaml`.
- Modify `/Users/biendh/base/test/src/cli/commands/` with Firebase command tests.
- Modify `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`.

## Implementation Steps

1. Add command surface:
   - `agentic_base firebase setup`
   - options for `--project-dir`, `--project`, `--project-dev`, `--project-staging`, `--project-prod`, `--platforms`, `--yes`
2. Load and validate target repo contract from `.info/agentic.yaml`.
3. Resolve toolchain through existing project resolver.
4. Implement environment checks:
   - `firebase --version`
   - `flutterfire --help`
   - Firebase auth/project listing where possible
5. Stage all file mutations through journal/temp outputs.
6. For each flavor, compute:
   - Android package name from `.info.org/project_name/flavor`
   - iOS bundle id from flavor contract
   - Dart options path
   - native config paths
7. Run `flutterfire configure` per flavor with explicit outputs.
8. Patch `flavorizr.yaml` with Firebase config paths.
9. Add option selector facade:
   - `DefaultFirebaseOptionsForFlavor.currentPlatform`
   - switch on `FlavorConfig.instance.flavor`
10. Add tests for missing tools, generated paths, rollback, migration warnings, and YAML mutation.

## Todo List

- [x] Add Firebase command group.
- [x] Add setup wrapper script.
- [x] Add staged mutation/rollback implementation.
- [x] Generate per-flavor options layout.
- [x] Patch flavorizr YAML.
- [x] Make Firebase runtime credential-safe.
- [x] Test missing tools and happy-path command construction.

## Success Criteria

- Fresh generated app with Firebase-backed modules runs without Firebase config.
- `agentic_base firebase setup` can configure all flavors when tools/auth/project are available.
- Missing Firebase tools produce clear install guidance.
- `flavorizr.yaml` contains per-flavor Firebase config paths after setup.
- Firebase options no longer live at root `lib/firebase_options.dart`.
- Forced failure after the first flavor leaves tracked files byte-for-byte equivalent.
- Existing root `lib/firebase_options.dart` and native Firebase config files are migrated with compatibility facade or preserved with explicit warning.

## Risk Assessment

- FlutterFire CLI behavior can change; tests should mock process calls and assert command args.
- iOS plist variable extraction can be brittle. Treat it as best-effort with clear warnings.
- Running flavorizr can rewrite native files; command must be idempotent and evidence-backed.
- Partial setup is worse than no setup; rollback tests are blocking.

## Security Considerations

- Do not commit service account files or Firebase tokens.
- Generated docs must say Firebase config identifiers are not secrets, but credentials/tokens are.
- Command must preserve human credential boundary.

## Next Steps

Phase 05 hardens runtime modules and native config requirements around this setup flow.
