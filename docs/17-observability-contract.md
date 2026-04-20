# 17. Observability Contract

## Scope

This document freezes what observability means in this repo after the profile-execution wave.

The contract is local-first, repo-scoped, and additive to Harness Contract V1. It does not imply a hosted telemetry product.

## Canonical Vocabulary

Observability is split into three named subdomains:

- `runtime_observability`: structured logs, traces, and bounded metrics emitted from generated runtime seams
- `agent_legibility`: one inspect surface that derives a joined run ledger from bundle files
- `operator_reports`: human-readable Markdown output rendered from that derived ledger

## Manifest Ownership

The manifest owns only the support envelope:

```yaml
harness:
  observability:
    mode: local-first
    runtime_observability: [structured_logs, traces, metrics]
    agent_legibility: [inspect, run_ledger]
    operator_reports: [markdown]
```

The manifest does not own:

- redaction policy details
- retention policy knobs
- report layout
- remote exporter configuration

Those remain generator-owned code and docs policy so the contract stays small.

## Minimum Supported Signals

The V1.5 observability floor is:

- structured logs with safe fields only
- trace/span lifecycle with run and session correlation
- bounded counters and duration metrics
- approval-state transitions emitted into the same local evidence bundle

## Redaction Rules

Generated runtime and shell surfaces must redact:

- authorization headers
- cookies
- token-like query params or field names
- obvious API key style fields

Redaction happens before runtime telemetry is written to `telemetry/*` or mirrored to logs.

## Retention Rules

The repo guarantees a deterministic latest-run copy under:

```text
artifacts/evidence/<run-kind>/latest/
```

Historical run retention is generator-owned policy. This wave does not expose retention tuning as a manifest setting.

## Non-Goals

This contract does not add:

- a hosted dashboard
- cross-repo telemetry aggregation
- automatic HTML operator views
- remote sink guarantees

## References

- [`docs/08-harness-contract-v1.md`](./08-harness-contract-v1.md)
- [`docs/11-eval-and-evidence-model.md`](./11-eval-and-evidence-model.md)
- [`docs/18-local-operator-reporting.md`](./18-local-operator-reporting.md)
