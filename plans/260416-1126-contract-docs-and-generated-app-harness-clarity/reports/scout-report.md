---
title: "Scout Report — Contract Docs and Generated App Harness Clarity"
created: 2026-04-16
status: complete
---

# Scout Report

## Summary

The remaining work is concentrated in three clusters:

- root canonical docs
- generated app docs
- generated shared contracts

## Hot Files

- [`README.md`](../../../README.md)
- [`docs/02-codebase-summary.md`](../../../docs/02-codebase-summary.md)
- [`docs/08-harness-contract-v1.md`](../../../docs/08-harness-contract-v1.md)
- [`docs/09-support-tier-matrix.md`](../../../docs/09-support-tier-matrix.md)
- [`docs/10-manifest-schema.md`](../../../docs/10-manifest-schema.md)
- [`docs/11-eval-and-evidence-model.md`](../../../docs/11-eval-and-evidence-model.md)
- [`docs/12-approval-state-machine.md`](../../../docs/12-approval-state-machine.md)
- [`docs/13-flutter-adapter-boundaries.md`](../../../docs/13-flutter-adapter-boundaries.md)
- [`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`](../../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md)
- [`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/01-architecture.md`](../../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/01-architecture.md)
- [`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/06-testing-guide.md`](../../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/06-testing-guide.md)
- [`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_result.dart`](../../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_result.dart)
- [`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_response.dart`](../../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_response.dart)
- [`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/pagination.dart`](../../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/pagination.dart)

## Structural Notes

1. Root docs are broad but not finite enough for “canonical context” use. The biggest noise source is duplicated status/overview language, not missing content.
2. Generated app docs are better scoped, but the harness development flow is implied across README + architecture + testing rather than stated once.
3. `lib/core/contracts` currently exposes only three files. That keeps the starter simple, but it does not yet answer the stated need for shared response/request/multi-language contracts.
4. Current generated docs already teach the verify ladder, release boundary, and runtime ownership. The missing piece is agent workflow guidance, not raw technical detail.

## Risk Hotspots

- deleting too much root docs context and making the package harder to navigate
- importing `meup` runtime coupling into the scaffold core contracts
- expanding the generated app with too many abstract base models that no day-0 flow actually exercises

## Unresolved Questions

- none beyond the validation interview items
