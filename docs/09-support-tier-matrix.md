# 09. Support Tier Matrix

## Scope

This document defines the truthful support envelope for Harness Contract V1 generated repos.

The goal is not to say "`agentic_base` supports Flutter." The goal is to say which Flutter product profiles get which guarantees.

## Support Envelope

Harness Contract V1 targets mainstream Flutter product apps.

Supported profile catalog:

- `consumer-app`
- `internal-business-app`
- `subscription-commerce-app`
- `content-community-app`
- `offline-first-field-app`

Not supported as first-class V1 profiles:

- game or Flame-heavy apps
- heavy native or FFI-driven apps
- embedded or kiosk apps
- 3D or XR-first apps

## Profile Identity Rules

Every repo that claims Harness Contract V1 declares:

- one `primary_profile`
- zero or more `secondary_traits`

`primary_profile` is the authoritative identity field.

Support tier and default gate expectations are derived from the static matrix for that profile. They are summary views, not independent sources of truth.

`secondary_traits` describe modifiers such as:

- `offline-first`
- `real-time`
- `media-heavy`
- `geo-aware`
- `enterprise-auth`
- `multi-brand`
- `multi-locale`

Traits do not upgrade a tier by themselves. They add context for capability selection and advisory checks.

## Tier Semantics

### Tier 1

Tier 1 means the profile gets:

- full Harness Contract V1 core guarantees
- generator-owned starter defaults shaped for that profile
- a defined profile gate pack beyond the universal core gates
- migration priority when contract changes land

### Tier 2

Tier 2 means the profile gets:

- the same Harness Contract V1 core guarantees
- truthful starter support within the support envelope
- only the universal core gates as required
- additional profile-specific checks documented as advisory until proven and tested

Tier 2 must not silently inherit Tier 1 profile claims.

## V1 Tier Assignment

| Profile | Tier | Required Guarantees |
| --- | --- | --- |
| `consumer-app` | Tier 1 | Core gates plus app-shell and user-path smoke coverage expectations. |
| `internal-business-app` | Tier 1 | Core gates plus authenticated workflow and configuration sanity expectations. |
| `subscription-commerce-app` | Tier 1 | Core gates plus purchase-flow readiness expectations when monetization capabilities are enabled. |
| `content-community-app` | Tier 2 | Core gates required; feed, moderation, and engagement checks stay advisory. |
| `offline-first-field-app` | Tier 2 | Core gates required; sync, conflict, and degraded-connectivity checks stay advisory. |

## Universal Core Gates

Every supported profile gets these required gates:

- manifest and generated-surface validation
- deterministic setup, test, verify, build, and release-preflight entrypoints
- static analysis
- unit or widget coverage for generator-produced seams
- at least one runnable smoke path for the generated app shell
- explicit human pauses for `product-decisions`, `credential-setup`, and `final-store-publish-approval`
- evidence bundle emission for meaningful verify and release-preflight runs

## Profile-Specific Gate Policy

Tier 1 profile packs may add required checks for:

- critical-path navigation
- authenticated or entitlement-aware flows
- capability-specific smoke runs when a capability is enabled
- release-surface checks that are essential to the profile claim

Tier 2 profile packs may document the same checks, but they stay advisory until:

- the generator owns the surface
- the checks are deterministic
- the package test suite or generated CI proves them

## Claim Rules

Public product language must follow the matrix:

- "supports all Flutter apps" is forbidden
- "supports mainstream Flutter product apps with Tier 1 and Tier 2 guarantees" is allowed
- unsupported profiles may be described as future exploration, not current support

## References

- [`docs/08-harness-contract-v1.md`](./08-harness-contract-v1.md)
- [`docs/10-manifest-schema.md`](./10-manifest-schema.md)
- [`plans/260414-1126-harness-contract-v1-and-flutter-support-tiers/phase-02-define-support-tier-matrix-and-manifest-schema.md`](../plans/260414-1126-harness-contract-v1-and-flutter-support-tiers/phase-02-define-support-tier-matrix-and-manifest-schema.md)
