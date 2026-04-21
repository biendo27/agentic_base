# Generator Contract Firebase DI Layout Hardening

**Date**: 2026-04-21 13:32
**Severity**: High
**Component**: CLI generator, Flutter app brick, Firebase setup, DI modules
**Status**: Resolved

## What Happened

Completed the generator contract hardening plan in `/Users/biendh/base`. Generated apps now use `tools/run.sh` for `dev/staging/prod`, keep `stg` as an operator alias only, put installed services under `lib/services`, split injectable registration from module startup, and make Firebase setup an explicit post-create command.

## Technical Details

Added `agentic_base firebase setup`, generated `tools/setup-firebase.sh`, per-flavor Firebase stubs, rollback-safe setup journaling, and Firebase no-config guards across default modules. Removed `uni_links` in favor of `app_links`. Hardened Ads sample-ID gates, prod preflight checks, bootstrap zone setup, and optional plugin DI constructors. Fixed Android-only create/verify by making native flavor validation and generated iOS readiness platform-aware.

## Review Fixes

Follow-up review caught two real blockers: rollback missed external tool side effects, and Crashlytics could emit a second async error from the global platform handler. The journal now snapshots tracked directories with byte-safe file states, Firebase setup tracks native/codegen output surfaces before fallible tools run, and Crashlytics records platform errors through a safe caught helper.

## Validation

Fresh validation passed: `dart analyze --fatal-infos`, full `test/src` suite with 282 tests, focused Firebase/Add/generator tests, slow generated-app canary, Android-only create plus generated verify, and Android native launch evidence in `plans/reports/native-260421-1104-android-launch-log.txt`.

## Lessons Learned

Directory presence is not a platform contract. Generated validators and scripts must use declared metadata first, because Flutter tooling can leave incidental scaffolding behind. Rollback also needs to treat external tools as broad mutators, not as single-file writers.

## Unresolved Questions

None.
