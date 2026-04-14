# 10. Manifest Schema

## Scope

Harness Contract V1 keeps `.info/agentic.yaml` as the single machine-readable source of truth.

This document defines the additive schema shape needed for support tiers, evidence, approval, and SDK policy.

Status:

- design target for future generator changes
- existing repos should not claim Harness Contract V1 until the generator writes the `harness` section and validators prove the required fields

## Design Rules

- keep one file: `.info/agentic.yaml`
- keep current top-level metadata fields
- add harness-specific fields under one stable `harness` section
- never store secrets, tokens, or credentials in the manifest
- keep config short; put explanations in docs

## Current Baseline

Today the manifest already stores:

- repo metadata such as project name, org, CI provider, platforms, flavors, state management, and modules
- context pointers
- execution surface names
- approval checkpoints
- ownership boundaries

That baseline should remain compatible.

## Proposed V1 Shape

The example below is a downstream generated-repo manifest. Its `context.canonical_docs` values therefore use the generated app doc surface (`docs/01-06` inside the generated repo), not this package repo's own numbered docs.

```yaml
schema_version: 3
project_kind: agent_ready_flutter_repo
tool_version: 0.2.0
project_name: sample_app
org: com.example
ci_provider: github
state_management: cubit
platforms: [android, ios, web]
flavors: [dev, staging, prod]
modules: [auth, analytics]
metadata_provenance:
  project_name: explicit
  ci_provider: inferred

context:
  canonical_docs:
    - README.md
    - docs/01-architecture.md
  thin_adapters: [AGENTS.md, CLAUDE.md]
  state_runtime: cubit
  ci_provider: github

execution:
  setup: ./tools/setup.sh
  run: ./tools/run-dev.sh
  verify: ./tools/verify.sh
  build: ./tools/build.sh
  release_preflight: ./tools/release-preflight.sh
  release: ./tools/release.sh
  default_run_flavor: dev

checkpoints:
  requires_human:
    - product-decisions
    - credential-setup
    - final-store-publish-approval

ownership:
  generator_owned: [docs/, tools/, AGENTS.md, CLAUDE.md]
  human_owned: [lib/features/, lib/shared/, env/*.env]

harness:
  contract_version: 1
  app_profile:
    primary_profile: consumer-app
    secondary_traits: [multi-locale]
  capabilities:
    enabled: [auth, analytics]
  providers:
    auth: firebase_auth
    analytics: firebase_analytics
  eval:
    evidence_dir: artifacts/evidence
    quality_dimensions:
      - correctness
      - release_readiness
      - observability
      - ux_confidence
  approvals:
    pause_on:
      - product-decisions
      - credential-setup
      - final-store-publish-approval
  sdk:
    manager: system
    channel: stable
    version: 3.29.0
    policy: newest_tested
```

## Field Semantics

| Field | Meaning |
| --- | --- |
| `harness.contract_version` | Version of the harness contract, not the package version. |
| `harness.app_profile.primary_profile` | Exactly one supported profile. |
| `harness.app_profile.secondary_traits` | Optional traits that inform capability packs and advisory checks. |
| `harness.capabilities.enabled` | Capabilities the repo expects the generator to own or wire. |
| `harness.providers` | Selected provider implementation for each relevant capability. |
| `harness.eval.evidence_dir` | Canonical output directory for verify and release evidence bundles. |
| `harness.approvals.pause_on` | Named human approval interrupts. |
| `harness.sdk.*` | Declared Flutter toolchain manager and tested version contract. |

Derivation rules:

- `primary_profile` is authoritative
- support tier is derived from the support matrix for the declared `primary_profile`
- the default eval pack is derived from the same profile plus enabled capabilities
- if future summary fields such as `support_tier` or `default_gate_pack` are emitted, validators must treat them as derived read models and reject drift

## Tier 2 Example

```yaml
harness:
  app_profile:
    primary_profile: offline-first-field-app
    secondary_traits: [geo-aware, enterprise-auth]
  eval:
    evidence_dir: artifacts/evidence
```

The important rule is that Tier 2 still records the profile honestly, but only the universal core gate pack is required.

## Migration Rules

Migration from the current manifest should be additive:

1. keep current top-level metadata fields unchanged
2. keep current `context`, `execution`, `checkpoints`, and `ownership` sections
3. add `harness` only when the generator and validators know how to read and write it
4. existing repos without a validated `harness` section remain on the legacy scaffold contract and should not claim Harness Contract V1
5. `contract_version: 1` should only be written once required V1 fields are present and validated
6. inferred `primary_profile` is allowed only when the generator has enough evidence and records it as inferred provenance
7. no provider claim should be written unless a capability/provider mapping is generator-owned
8. treat missing new fields as absent or defaulted, not silently verified

## Validation Rules

V1 validators should reject:

- more than one `primary_profile`
- unsupported profile names
- undeclared provider keys for disabled capabilities
- secrets or obvious credential-like values under `providers`, `approvals`, or `sdk`
- summary fields that disagree with the derived support matrix

## References

- [`docs/08-harness-contract-v1.md`](./08-harness-contract-v1.md)
- [`docs/09-support-tier-matrix.md`](./09-support-tier-matrix.md)
- [`lib/src/config/agentic_config.dart`](../lib/src/config/agentic_config.dart)
- [`lib/src/config/project_metadata.dart`](../lib/src/config/project_metadata.dart)
