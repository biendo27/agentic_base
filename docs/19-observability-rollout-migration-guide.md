# 19. Observability Rollout Migration Guide

## Scope

This guide covers older generated repos that predate the local-first observability wave.

## Safe Migration Rules

1. Keep the existing Harness Contract V1 fields intact.
2. Add `harness.observability` only through generator-owned flows.
3. Treat missing telemetry files as legacy-compatible, not as proof of success.
4. Do not copy secrets or raw credentials into observability config or evidence files.

## Minimum Upgrade Checklist

- regenerate the repo-owned scaffold so `tools/inspect-evidence.sh` and `lib/core/observability/*` land
- verify `.info/agentic.yaml` now includes `harness.observability`
- run `./tools/verify.sh`
- inspect the latest run with `./tools/inspect-evidence.sh verify`
- confirm `telemetry/runtime-context.json`, `telemetry/events.ndjson`, and `telemetry/metrics.json` exist

## Legacy Behavior

Older bundles may only contain:

- `summary.json`
- `checks/*.json`
- `commands.ndjson`
- `logs/*`

`agentic_base inspect` must still render a partial ledger for those bundles with `telemetry_present: false`.

## Rollout Order

- phase 1: contract/docs/validators
- phase 2: generated runtime seams
- phase 3: evidence export
- phase 4: inspect/report reader
- phase 5: tests and migration guardrails

## References

- [`plans/260420-0840-observability-contract-and-agent-legibility-roadmap/plan.md`](../plans/260420-0840-observability-contract-and-agent-legibility-roadmap/plan.md)
- [`docs/17-observability-contract.md`](./17-observability-contract.md)
