# 11. Eval And Evidence Model

## Scope

Harness Contract V1 requires a repo to prove trustworthiness through named gates and inspectable artifacts.

`analyze + test` stays necessary. It stops being sufficient as the only story.

Status:

- design target for future implementation waves
- until generator code lands, the gate ladder and evidence bundle below define the contract to earn, not a currently shipped generated-repo guarantee

## Eval Ladder

| Level | Name | Purpose |
| --- | --- | --- |
| L0 | Contract Surface | Validate manifest, generated docs, thin adapters, scripts, and provider-specific CI surfaces. |
| L1 | Static | Run formatting, generation freshness, and static analysis checks. |
| L2 | Unit And Widget | Verify package seams and generated runtime boundaries. |
| L3 | Smoke And Integration | Exercise at least one critical app-shell path and capability-aware smoke paths when relevant. |
| L4 | Native Readiness | Verify native shell or simulator/device readiness required by the claimed profile and target platform. |
| L5 | Release Readiness | Verify release-preflight inputs, artifact creation, and upload preconditions without implying final publish authority. |

Generated repos do not need every ladder level on every run. They need a derived gate expectation based on profile, capability set, and release target.

## Default Gate Expectations

### `core`

Required for every supported repo:

- L0 contract surface
- L1 static
- L2 unit/widget
- one L3 app-shell smoke path

### Tier 1 Profile Packs

Extends `core` with:

- profile-specific L3 smoke expectations
- L4 native readiness for supported target platforms
- L5 release-preflight before upload flows

### Tier 2 Profile Packs

Required:

- `core`

Advisory only:

- profile-specific smoke packs
- sync, moderation, community, or domain-heavy extras

## Evidence Bundle Contract

Meaningful verify and release-preflight runs should emit a bundle under the contract once the implementation waves land:

```text
artifacts/evidence/<run-kind>/<timestamp>-<run-id>/
```

Minimum bundle shape:

```text
summary.json
checks/
  contract-surface.json
  static.json
  unit-widget.json
commands.ndjson
logs/
  verify.log
artifacts/
  ...
```

## Required Outputs

### `summary.json`

Must include:

- run id
- timestamp
- repo manifest snapshot reference
- derived gate expectation id
- executed gates
- pass, fail, blocked, or skipped state per gate
- quality dimension states
- next required human action, if any

### `checks/*.json`

One file per executed gate with:

- command or tool name
- inputs or target
- exit status
- short result summary
- artifact references

### `commands.ndjson`

Append-only execution log with one record per invoked script or tool.

### `logs/*`

Human-readable logs safe to inspect locally or in CI. Secrets must be redacted.

## Quality Model

V1 uses multiple internal dimensions instead of one public scalar:

- `correctness`
- `release_readiness`
- `observability`
- `ux_confidence`

Each dimension should use discrete states:

- `pass`
- `risk`
- `blocked`
- `not_run`

This avoids fake precision while still letting the harness summarize risk honestly.

## CI And Local Parity

The same gate names should work:

- locally through `tools/verify.sh` and related scripts
- in generated CI workflows
- in future richer harness wrappers

CI may attach more artifacts, but it should not invent a second gate vocabulary.

## Guardrails

- evidence bundles must not capture secrets by default
- screenshots, logs, and command outputs must be redactable
- skipped gates must be explicit in the summary
- a passed release-preflight still does not mean final production publish is approved

## References

- [`docs/08-harness-contract-v1.md`](./08-harness-contract-v1.md)
- [`docs/12-approval-state-machine.md`](./12-approval-state-machine.md)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh](<../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh>)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release-preflight.sh](<../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release-preflight.sh>)
