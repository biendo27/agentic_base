# Phase 05: Default Module Runtime Safety

## Context Links

- `/Users/biendh/base/lib/src/modules/extended/ads_module.dart`
- `/Users/biendh/base/lib/src/modules/extended/deep_link_module.dart`
- `/Users/biendh/base/lib/src/modules/core/crashlytics_module.dart`
- `/Users/biendh/base/lib/src/modules/extended/remote_config_module.dart`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/bootstrap.dart`
- `/Users/biendh/base/docs/15-default-app-service-matrix.md`

## Overview

Priority: P1. Status: Complete.

Convert the manual fixes proven in `/Users/biendh/StudioProjects/my_app` into generator-owned templates and tests.

## Key Insights

- `uni_links` broke Android build.
- `google_mobile_ads` crashed natively without an AdMob application id.
- Firebase-backed modules crashed until runtime became no-op-safe.
- Bootstrap had a Flutter zone mismatch until binding init and `runApp` were in the same zone.
- Some generated lint infos required template cleanup.

## Requirements

- Deep link module uses only `app_links`.
- Ads module injects safe sample AdMob app ids for dev/default generated apps.
- Dev/staging may use official sample app ids to prevent native provider crash.
- Prod release-preflight fails if sample or placeholder ad ids remain.
- Ads service must not load/request ads until consent and config gates pass.
- iOS AdMob plist key is handled where required.
- Firebase analytics/crashlytics/remote-config no-op when Firebase readiness is false.
- RemoteConfig does not eagerly instantiate before Firebase is ready.
- Crashlytics platform error hook uses unawaited/future-safe handling.
- Bootstrap has one zone for binding initialization and `runApp`.
- Generated templates pass `dart analyze --fatal-infos`.

## Architecture

```text
app boot -> bootstrap zone -> configure DI -> startup hooks
  -> provider ready? yes -> real service
  -> provider ready? no  -> observability warning + no-op
```

## Related Code Files

- Modify `/Users/biendh/base/lib/src/modules/extended/deep_link_module.dart`.
- Modify `/Users/biendh/base/lib/src/modules/extended/ads_module.dart`.
- Modify `/Users/biendh/base/lib/src/modules/core/analytics_module.dart`.
- Modify `/Users/biendh/base/lib/src/modules/core/crashlytics_module.dart`.
- Modify `/Users/biendh/base/lib/src/modules/extended/remote_config_module.dart`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/bootstrap.dart`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/AndroidManifest.xml` surface if present; otherwise patch via module installer.
- Modify tests under `/Users/biendh/base/test/src/cli/commands/` and `/Users/biendh/base/test/integration/`.

## Implementation Steps

1. Remove all `uni_links` references.
2. Add AdMob Android manifest metadata during ads module install.
3. Add iOS AdMob config support if plugin requires it for generated run.
4. Port safe Firebase runtime behavior:
   - readiness cache
   - `Future<bool>`
   - debug/observability warning
5. Port safe analytics/crashlytics/remote-config implementations.
6. Update bootstrap template to avoid zone mismatch.
7. Fix template lint infos:
   - documented `one_member_abstracts` ignores only where justified
   - `unawaited` for intentionally ignored futures
   - cascade/style fixes surfaced by fatal infos
8. Add regression tests for each previously observed failure.

## Todo List

- [x] Remove `uni_links`.
- [x] Add only regression tests for `uni_links`; Phase 02 owns actual dependency removal.
- [x] Add AdMob native metadata generation.
- [x] Port safe Firebase runtime/templates.
- [x] Fix bootstrap zone template.
- [x] Fix generated lint infos.
- [x] Add regression tests.

## Success Criteria

- Fresh default profile Android build has no `:uni_links` failure.
- Fresh default profile Android app does not crash in `MobileAdsInitProvider`.
- Prod release-preflight rejects sample or placeholder ad ids.
- Fresh default profile app logs Firebase not configured and continues.
- No Flutter zone mismatch appears on launch.
- `dart analyze --fatal-infos` passes inside generated app.

## Risk Assessment

- AdMob sample ids are safe for dev but must not be presented as production config.
- Over-broad lint ignores could hide real issues; keep them local and documented.
- Ads initialization before consent/config would be a policy regression even if native boot succeeds.

## Security Considerations

- Do not generate real ad ids or Firebase credentials.
- Log provider-not-configured state without leaking local file paths or account names.

## Next Steps

Phase 06 verifies these changes through package tests and real generated app runs.
