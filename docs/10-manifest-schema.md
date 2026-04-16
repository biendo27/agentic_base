# 10. Manifest Schema

## Scope

Harness Contract V1 keeps `.info/agentic.yaml` as the single machine-readable source of truth.

This document defines the additive schema shape used for support tiers, evidence, approvals, and SDK policy.

## Design Rules

- keep one file: `.info/agentic.yaml`
- keep current top-level metadata fields
- keep harness-specific fields under one stable `harness` section
- never store secrets, tokens, credentials, or branch-policy rules in the manifest
- keep config short; put narrative explanations in docs

## Current Baseline

The manifest stores:

- repo metadata such as project name, org, CI provider, platforms, flavors, state management, and modules
- context pointers
- execution surface names
- approval checkpoints
- ownership boundaries
- harness profile, provider, evidence, approval, and SDK metadata

That baseline is the live V1 contract for generated and repaired repos.

## V1 Shape

The example below is a downstream generated-repo manifest. Its `context.canonical_docs` values therefore use the generated app doc surface (`docs/01-07` inside the generated repo), not this package repo's numbered docs.

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
    - docs/02-coding-standards.md
    - docs/03-state-management.md
    - docs/04-network-layer.md
    - docs/05-theming-guide.md
    - docs/06-testing-guide.md
    - docs/07-agentic-development-flow.md
  thin_adapters: [AGENTS.md, CLAUDE.md]
  state_runtime: cubit
  ci_provider: github

execution:
  setup: ./tools/setup.sh
  run: ./tools/run-dev.sh
  test: ./tools/test.sh
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
- Gitflow guidance stays in human-readable docs and thin adapters, not in `.info/agentic.yaml`
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

Migration from pre-V1 manifests stays additive:

1. keep current top-level metadata fields unchanged
2. keep current `context`, `execution`, `checkpoints`, and `ownership` sections
3. let generator-owned `create`, `init`, and `upgrade` flows write or repair `harness`
4. treat repos without a validated `harness` section as legacy until repair succeeds
5. write `contract_version: 1` only when required V1 fields are present and validated
6. allow inferred `primary_profile` only when provenance records the inference honestly
7. do not write provider claims unless the capability/provider mapping is generator-owned
8. treat missing new fields as absent or defaulted, not silently verified

## Validation Rules

V1 validators reject:

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
