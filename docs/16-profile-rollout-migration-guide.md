# 16. Profile Rollout Migration Guide

## Scope

This guide is for generated Flutter repos created before the profile-execution rollout completed on 2026-04-17.

Use it when an existing repo still reflects the older metadata-only profile model, the older starter theme contract, or the older provider-neutral monetization demo.

## What Changed

The shipped default lane now assumes:

- `subscription-commerce-app` is the CLI default profile
- profile presets resolve default modules and providers in generator code
- generated starter apps render profile-owned seams and gate packs through `starter_runtime_profile.dart`
- verify and release-preflight emit profile-aware gate expectations
- the starter commerce lane separates `PaymentsService`, `EntitlementService`, and `ConsentService`
- the default theme family is `trustworthy-commerce`, using Lexend plus Source Sans 3 via `google_fonts`
- the default payments dependency is `in_app_purchase`

## Who Should Migrate

Review this guide if your generated repo was created or last upgraded before the rollout landed and any of these are true:

- `.info/agentic.yaml` still assumes `consumer-app` as the default profile
- `tools/verify.sh` does not mention `starter-commerce`, `starter-journey`, `starter-settings`, or `profile-advisory`
- the generated starter still describes a provider-neutral monetization demo
- `pubspec.yaml` still wires `purchases_flutter` instead of `in_app_purchase`
- the generated theme docs do not mention `trustworthy-commerce`

## Recommended Path

Prefer a generator-owned sync over ad hoc manual edits:

```bash
agentic_base upgrade
```

If the repo never had the agent-ready scaffold repaired cleanly, run:

```bash
agentic_base init
```

Use manual edits only when the project intentionally diverged from the generated starter and you need to preserve those customizations.

## Manual Checklist

1. Confirm the declared profile in `.info/agentic.yaml`.
   The default should now be `subscription-commerce-app` unless your product intentionally uses another supported profile.
2. Review the generated capability and provider set.
   Expect the golden-path default pack to include analytics, crashlytics, remote config, feature flags, payments, ads, notifications, deep links, in-app review, and app update when you keep the default profile-owned modules.
3. Inspect starter runtime files.
   Confirm `lib/core/starter/starter_runtime_profile.dart`, `lib/core/commerce/entitlement_service.dart`, and `lib/core/privacy/consent_service.dart` exist and that the starter UI references them.
4. Inspect monetization dependencies.
   Confirm `in_app_purchase` is the active generated default and remove stale RevenueCat-specific starter code unless your product intentionally depends on it.
5. Inspect verify and release-preflight scripts.
   Confirm `tools/verify.sh` and `tools/release-preflight.sh` mention the expected gate pack and emit explicit advisory skips for Tier 2 profiles.
6. Inspect the theme layer.
   Confirm `google_fonts` is present, the typography uses Lexend plus Source Sans 3, and the docs mention `trustworthy-commerce`.
7. Rerun the starter evidence flow.
   Expect the evidence summary to include the profile-aware gate id for the generated repo.

## Verification Commands

Run the normal local contract checks after syncing:

```bash
dart analyze --fatal-infos
dart test
./tools/verify.sh
./tools/release-preflight.sh
```

For package maintainers working in this repo, the rollout was validated with targeted preset, generator, docs, and generated-app smoke coverage in addition to `dart analyze --fatal-infos`.

## What Is Not Migrated Automatically

- real store, ad, notification, or crash-reporting credentials
- consent copy, legal review, or privacy-policy changes
- product-specific entitlement logic
- production release approval state

The generator keeps those surfaces explicit on purpose. Do not assume credential carry-over just because the starter seam exists.

## References

- [`docs/15-default-app-service-matrix.md`](./15-default-app-service-matrix.md)
- [`docs/11-eval-and-evidence-model.md`](./11-eval-and-evidence-model.md)
- [`README.md`](../README.md)
