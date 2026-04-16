# 13. Flutter Adapter Boundaries

## Scope

Harness Contract V1 stays Flutter-first, but it must not confuse Flutter-specific concerns with reusable harness concerns.

This document defines that split.

## Three Layers

| Layer | Owns | Must Not Own |
| --- | --- | --- |
| Harness core | manifest contract, context contract, ownership model, support tiers, eval/evidence model, approval states | Flutter CLI semantics, Fastlane details, flavor tool specifics |
| Flutter adapter | `flutter create`, SDK/tool detection, build and run commands, flavors, codegen, native readiness, Fastlane wrappers | product-profile policy, generic quality semantics, non-Flutter abstractions |
| Capability packs | auth, analytics, notifications, payments, and other opt-in integrations | global ownership rules, core approval boundaries, generic SDK policy |

## Harness Core Responsibilities

Harness core remains stable even if the runtime stack changes later:

- `.info/agentic.yaml` contract semantics
- canonical docs and thin adapter expectations
- deterministic command surface names
- support tier vocabulary
- eval ladder and evidence bundle shape
- approval gate vocabulary
- generator-owned vs human-owned boundary model

## Flutter Adapter Responsibilities

Flutter adapter owns:

- environment detection for `flutter`, `dart`, and version managers
- generated app creation and overlay workflow
- state-management runtime wiring
- flavors, build targets, and entrypoints
- code generation and localization generation expectations
- iOS, Android, macOS, and web build/readiness specifics
- Fastlane wrapper semantics for supported mobile release targets

## Capability Pack Responsibilities

Capability packs own:

- files and dependencies needed for the capability
- startup hooks and DI/provider seams
- provider-specific manual platform steps
- extra advisory or required gate hooks when the support tier allows them

Capability packs must not create hidden alternative control planes.

## Boundary Rules

1. Harness core may name a gate such as `native_readiness`, but only the Flutter adapter defines what that means for Flutter targets.
2. Flutter adapter may expose commands like `./tools/build.sh`, but the command names remain part of the harness contract.
3. Capability packs may require provider declarations, but provider names must stay inspectable in the manifest.
4. Cross-stack extraction remains future work. No current doc should imply a generic adapter kernel already exists.

## Leakage To Avoid

Do not let harness core depend directly on:

- Flavorizr internals
- Fastlane lane names
- simulator or emulator selection syntax
- Gradle/Xcode project layout details

Do not let Flutter adapter redefine:

- which surfaces are human-owned
- whether final production publish is human-approved
- support tier meanings

## Extraction Rule

Future cross-stack extraction is allowed only for surfaces that remain meaningful without Flutter-specific vocabulary. If a concept stops making sense outside Flutter, it belongs in the adapter.

## References

- [`docs/08-harness-contract-v1.md`](./08-harness-contract-v1.md)
- [`docs/10-manifest-schema.md`](./10-manifest-schema.md)
- [`docs/14-sdk-and-version-policy.md`](./14-sdk-and-version-policy.md)
- [`docs/04-system-architecture.md`](./04-system-architecture.md)
