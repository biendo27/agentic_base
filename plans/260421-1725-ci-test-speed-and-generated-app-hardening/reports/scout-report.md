---
type: scout
created: 2026-04-21
scope: ci-test-generated-app-hardening
---

# Scout Report

## Summary

Relevant code is concentrated in root GitHub Actions, the generated app smoke test, create command/generator orchestration, generated CI templates, generated shell scripts, and the ads module.

## Findings

| Area | Files | Finding |
| --- | --- | --- |
| Root CI | `.github/workflows/ci.yml` | `dart test` runs all tests, then `generated-app-smoke` runs the integration file again. macOS native gate creates app with default verify, then runs `ci-check.sh`, causing double verification risk. |
| Test tags | `dart_test.yaml`, `test/integration/generated_app_smoke_test.dart` | Only `slow-canary` is declared. The full generated-app file is not tagged, so generic `dart test` includes it. |
| Create command | `lib/src/cli/commands/create_command.dart` | `--ci-provider` exists, but interactive create does not prompt for it. Default `github` is silently used unless flag is provided. |
| Generator verify | `lib/src/generators/project_generator.dart` | Internal `runVerify: bool` supports skipping verify in tests, but public CLI has no explicit verify mode. |
| Generated workflow templates | `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.github/workflows/*.yml` | Files start with Mason delimiter reset, but still use `{{flutter_sdk_channel}}`, `{{flutter_sdk_version}}`, and `{{evidence_dir}}`, so rendered apps can contain unresolved tokens. |
| Generated GitHub CI | `bricks/.../.github/workflows/ci.yml` | Builds `[dev, staging, prod]` in PR/push CI. `tools/build.sh` intentionally refuses prod when `env/prod.env` is absent. |
| Generated scripts | `bricks/.../tools/build.sh`, `tools/verify.sh`, `tools/ci-check.sh` | Prod env refusal is correct. `AGENTIC_VERIFY_FAST` exists but skips static/unit-widget gates, so it must be used only where another lane covers those checks. |
| Ads module | `lib/src/modules/extended/ads_module.dart` | `_ensureIosAdMobAppId` inserts before the first `</dict>`, which can place `GADApplicationIdentifier` inside `UIApplicationSceneManifest`. This caused iOS simulator launch crash in `my_app`. |
| Contract validator | `lib/src/generators/generated_project_contract.dart` | Validates provider-specific outputs, required files, docs, verify surface, and native flavor outputs. It does not yet scan generated CI for unresolved template tokens or top-level iOS AdMob metadata. |

## Reuse Points

- `GeneratedProjectContract` is the right place for structural generated-output assertions.
- `ModuleInstaller.mutateTextFile` is the right mutation path for AdMob plist repair.
- Existing `ProjectGenerator.generate(... runVerify: false)` proves tests can skip verify internally; convert this to a typed verification mode instead of adding ad hoc flags.
- Existing `AGENTIC_VERIFY_FAST` can support CI speed, but only after strict coverage is documented.

## Unresolved Questions

None.
