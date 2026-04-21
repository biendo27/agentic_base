# 15. Default App Service Matrix

## Scope

This document freezes the product contract for the active harness-profile rollout.

It defines what `thin base`, `golden path`, and the default V1 product lane mean, and that contract is now implemented in generator-owned create, starter-runtime, and verify behavior.

## Terminology

- `primary_profile`: the declared product identity in `.info/agentic.yaml`
- support tier: a derived summary of guarantee and gate strength for that profile
- capability: a generator-owned feature seam recorded in the manifest
- module: the install/remove unit that wires one or more capabilities
- service: the runtime contract exposed inside the generated app
- provider: the package or concrete implementation backing a capability

## Frozen V1 Decisions

- the canonical default V1 profile is `subscription-commerce-app`
- the canonical V1 golden path is the `subscription-commerce-app` lane
- thin base and golden path are separate concepts
- `evidence_quality` is the quality dimension for run evidence; it does not imply agent telemetry

## Thin Base Versus Golden Path

### Thin Base

The thin base is the universal surface every supported generated repo gets:

- machine contract in `.info/agentic.yaml`
- canonical docs plus thin adapters
- deterministic `tools/` entrypoints
- flavor and environment shell
- router, DI, network, error, result, theme, and i18n seams
- one honest starter journey proving the shell works
- evidence bundle output and explicit human approval pauses

Thin base is not a default module pack.

### Golden Path

The golden path is the most heavily hardened Tier 1 product lane.

For V1, that lane is `subscription-commerce-app`.

Golden path means the profile receives the strongest preset resolution, starter-runtime shaping, and required gate hardening. It does not mean the thin base becomes a kitchen sink.

## Service Matrix

| Bucket | Meaning | Canonical contents |
| --- | --- | --- |
| Thin base | Universal harness and app-shell surface. | docs, adapters, scripts, manifest, starter shell, network/error/result/theme/i18n seams, evidence output |
| `subscription-commerce-app` default-on | Profile-owned capability and service pack for the golden path. | analytics, crashlytics, remote config, feature flags, payments, entitlement seam, consent seam, notifications, deep links, in-app review, app update, ads seam generated but inactive until consent and config gates pass |
| Opt-in only | Everything not required by thin base or the golden path. | auth, social login, secure storage, local storage, permissions, connectivity, maps, location, camera, image picker, video player, QR scanner, biometric, file manager, webview, share, external checkout, other future packs |

## Policy Notes

- `primary_profile` remains authoritative. Tier and gate-pack summaries stay derived.
- Thin base must stay bootable without product credentials.
- Firebase-backed golden-path modules must stay bootable before credentials by using no-op-safe runtime stubs and explicit `agentic_base firebase setup`.
- Golden-path payments default to digital subscription expectations; external checkout remains opt-in only.
- Ads may exist in the golden path, but they stay inactive until consent and configuration checks say otherwise.
- Production release-preflight rejects sample AdMob application IDs and requires a real `env/prod.env`.
- Docs, starter output, and verify behavior should ship from the same policy and be updated together.

## Rollout Rule

This matrix drove phases 02-05 of the harness-profile rollout and is now the shipped default contract for the V1 golden-path lane.

## References

- [`README.md`](../README.md)
- [`docs/08-harness-contract-v1.md`](./08-harness-contract-v1.md)
- [`docs/09-support-tier-matrix.md`](./09-support-tier-matrix.md)
- [`docs/10-manifest-schema.md`](./10-manifest-schema.md)
- [`docs/16-profile-rollout-migration-guide.md`](./16-profile-rollout-migration-guide.md)
- [`plans/260417-1344-harness-profile-execution-golden-path-and-default-app-contract/phase-01-freeze-product-contract-and-service-matrix.md`](../plans/260417-1344-harness-profile-execution-golden-path-and-default-app-contract/phase-01-freeze-product-contract-and-service-matrix.md)
