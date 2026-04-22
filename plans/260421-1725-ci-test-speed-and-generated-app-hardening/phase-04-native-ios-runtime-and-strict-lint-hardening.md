# Phase 04: Native iOS Runtime And Strict Lint Hardening

## Context Links

- [Plan](./plan.md)
- [Research: Generated CI/CD And Native Runtime](./research/researcher-02-generated-cicd-native-runtime-report.md)
- Ads module: [`ads_module.dart`](../../lib/src/modules/extended/ads_module.dart)
- Generated contract: [`generated_project_contract.dart`](../../lib/src/generators/generated_project_contract.dart)
- Generated lint script: [`tools/lint.sh`](../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/lint.sh)
- Generated verify script: [`tools/verify.sh`](../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh)

## Overview

Priority: P0. Status: Completed.

Fix the iOS AdMob launch crash in generated apps and make generated-app lint strictness explicit. CI should prove simulator readiness; physical device readiness remains a signing/provisioning boundary.

## Key Insights

- `my_app` iOS simulator crashed because `GADApplicationIdentifier` was nested under `UIApplicationSceneManifest`.
- Root cause is `_ensureIosAdMobAppId` inserting before the first `</dict>`.
- Physical iPhone run failed because no local provisioning profile includes the device UDID. That is not a generator-code failure.
- Generated app currently passes normal analyze, but `dart analyze --fatal-infos` reported info-level issues. The policy is not explicit enough.

## Requirements

- Functional:
  - Insert or repair iOS AdMob application ID at root plist dictionary level.
  - Keep mutation idempotent.
  - Remove/repair the previously generated nested sample entry when encountered.
  - Add unit tests for nested plist and already-correct plist.
  - Add generated contract assertion for top-level AdMob app ID when ads module is installed.
  - Add macOS simulator smoke coverage for the ads/native path when relevant.
  - Define generated lint policy: default verify plus optional strict mode, or strict-by-default after generated info debt is fixed.
- Non-functional:
  - Do not require physical iOS device in CI.
  - Do not require real AdMob IDs for dev/staging; sample IDs remain safe for generated starter.

## Architecture

AdMob plist mutation should be root-dict-aware:

```text
Info.plist
  <plist>
    <dict>                 # root
      ... existing keys ...
      <key>UIApplicationSceneManifest</key>
      <dict>...</dict>     # nested
      <key>GADApplicationIdentifier</key>
      <string>sample-ios-app-id</string>
    </dict>
  </plist>
```

Preferred implementation: small deterministic token scanner that finds the closing `</dict>` matching the root `<dict>`. Avoid fragile first-match replacement.

## Related Code Files

- Modify `/Users/biendh/base/lib/src/modules/extended/ads_module.dart`.
- Modify `/Users/biendh/base/test/src/modules/module_integration_generator_test.dart` or add focused ads module test under `/Users/biendh/base/test/src/modules/`.
- Modify `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`.
- Modify `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/lint.sh`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh` if strict lint becomes a verify option.
- Modify `/Users/biendh/base/.github/workflows/ci.yml` for macOS simulator conditional gate.
- Modify generated docs under `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/`.

## Implementation Steps

1. Add focused tests for `_ensureIosAdMobAppId` behavior:
   - no key exists, nested dict present
   - top-level key already exists
   - generated sample key exists inside nested dict
   - malformed plist fails with actionable error or leaves file unchanged with warning
2. Refactor plist mutation into a small helper in `ads_module.dart` or a module utility if reuse is justified.
3. Ensure Android metadata mutation remains idempotent.
4. Add contract validation for ads-installed generated projects:
   - iOS `GADApplicationIdentifier` exactly once
   - top-level position before root `</dict>`
5. Add generated-app smoke assertion for ads module plist output.
6. Add macOS conditional native job:
   - generate app with ads/default profile
   - build or run iOS simulator dev target
   - skip physical device signing
7. Decide lint policy:
   - preferred: fix generated info-level issues so `tools/lint.sh --strict` passes
   - default `tools/verify.sh` can stay normal analyze if strict infos are noisy across Flutter/lint versions
8. Add `tools/lint.sh --strict` path and root contract test for it.
9. Document physical iOS signing failure mode and required human setup.

## Todo List

- [x] Add plist mutation tests.
- [x] Fix iOS AdMob root-dict insertion.
- [x] Add generated contract assertion.
- [x] Add conditional iOS simulator smoke.
- [x] Define and test strict lint mode.
- [x] Document physical device signing boundary.

## Success Criteria

- Fresh generated ads app has `GADApplicationIdentifier` at top-level `Info.plist`.
- iOS simulator dev launch/build no longer crashes with `GADInvalidInitializationException`.
- Physical iOS signing errors are documented as credential/provisioning blockers, not app-code blockers.
- Generated app strict lint policy is testable by command.
- If strict lint is claimed, generated output passes `dart analyze --fatal-infos`.

## Risk Assessment

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Text plist parser misses edge case | iOS crash persists | Cover nested dict and malformed cases; prefer root-depth scanner |
| macOS simulator gate slows PRs | CI latency | Run only on native/module/template changes, nightly, manual, release |
| Strict lint brittle across Flutter versions | False failures | Use explicit `--strict`; keep default verify stable unless debt is fixed |

## Security Considerations

- AdMob sample app IDs are non-secret.
- Do not collect device UDIDs or signing identities in CI logs beyond error classification.

## Next Steps

Phase 05 updates docs and runs complete validation.
