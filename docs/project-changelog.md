# Project Changelog

## 2026-04-21

- Completed generator contract hardening.
- Replaced generated `tools/run-dev.sh` with `tools/run.sh [dev|staging|stg|prod]`.
- Added explicit `agentic_base firebase setup` and generated `tools/setup-firebase.sh`.
- Moved installed module services to `lib/services/<capability>/`.
- Split DI startup: injectable owns registrations; `module_startup.dart` owns ordered hooks; Riverpod providers live in `module_providers.dart`.
- Removed `uni_links`; deep-link module uses `app_links` only.
- Added no-op-safe Firebase runtime stubs and AdMob sample metadata guards for generated apps.
- Added focused regression coverage for dependency catalog, module integration, Firebase setup rollback, add/remove flows, and generated contract validation.
- Fixed Android-only generated app validation/readiness so incidental iOS scaffolding does not trigger iOS flavor checks.
- Android native launch evidence recorded in `plans/reports/native-260421-1104-android-launch-log.txt`.
- Split root CI into fast package tests, conditional generated-app/native gates, and an always-running aggregate `ci-required` status.
- Added generated `--verify-mode` support for `full`, `fast`, and `none` create flows.
- Fixed generated CI/CD template rendering, removed prod from credentialless GitHub PR build matrices, and added unresolved-token validation.
- Repaired iOS AdMob plist insertion so `GADApplicationIdentifier` is root-level and idempotent.
- Added generated `./tools/lint.sh --strict` for fatal-info lint checks.
