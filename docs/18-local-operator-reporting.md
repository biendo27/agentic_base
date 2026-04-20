# 18. Local Operator Reporting

## Scope

Operator reporting in this repo is a derived local read model, not a second persisted truth.

## Canonical Read Path

The package-side entrypoint is:

```bash
agentic_base inspect --kind verify
agentic_base inspect --kind release-preflight --format json
```

Generated repos also ship:

```bash
./tools/inspect-evidence.sh verify
./tools/inspect-evidence.sh release-preflight latest json
```

## Inputs

`inspect` derives its output from:

- `summary.json`
- `checks/*.json`
- `commands.ndjson`
- `telemetry/runtime-context.json`
- `telemetry/events.ndjson`
- `telemetry/metrics.json`

## Outputs

Supported outputs today:

- Markdown for humans
- JSON for scripts and agents

Both are derived from the same in-memory run ledger.

## Timeline Model

The derived run ledger joins:

- approval transitions
- command invocations
- gate outcomes
- runtime logs and span records

The bundle files remain canonical. The ledger is a read model.

## Guardrails

- no hosted service dependency
- no hidden alternate schema
- no implication that Markdown is the source of truth

## References

- [`docs/17-observability-contract.md`](./17-observability-contract.md)
- [`docs/11-eval-and-evidence-model.md`](./11-eval-and-evidence-model.md)
