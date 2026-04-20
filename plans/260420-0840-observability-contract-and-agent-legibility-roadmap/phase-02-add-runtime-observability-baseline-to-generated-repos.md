# Phase 02 - Add Runtime Observability Baseline To Generated Repos

## Context Links

- [Phase 01](./phase-01-freeze-observability-contract-and-support-envelope.md)
- [System Architecture](../../docs/04-system-architecture.md)
- [Default App Service Matrix](../../docs/15-default-app-service-matrix.md)

## Overview

- Priority: P0
- Current status: Pending
- Brief description: Add generator-owned runtime observability seams to generated Flutter repos without turning the thin base into backend-heavy infrastructure.

## Key Insights

- Generated repos already ship logging, crash reporting seams, network interceptors, and evidence scripts.
- The missing piece is one owned runtime observability layer that ties app boot, navigation, network, and service work into inspectable signals.
- Payments, entitlements, consent, and ads starter flows should emit observability context from day 0.

## Requirements

### Functional Requirements

- Add generator-owned app runtime seams for:
  - session/run correlation ids
  - structured log events
  - trace/span lifecycle
  - bounded counters and duration metrics
  - redaction-safe field filtering
- Wire startup, navigation, network, and golden-path starter surfaces through those seams.
- Keep starter runtime bootable without any remote telemetry backend.

### Non-Functional Requirements

- Provider-neutral
- Replaceable sinks
- Cheap enough for local development and CI smoke

## Architecture

- Generated app gains a `core/observability/` surface owned by the brick.
- Default sink writes local structured artifacts and mirrors safe console output.
- Existing logging and crash-report seams integrate with observability context instead of bypassing it.
- Network interceptor chain emits correlation and duration events from one shared policy.

## Related Code Files

### Files To Modify

- [bricks/agentic_app/brick.yaml](/Users/biendh/base/bricks/agentic_app/brick.yaml)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/bootstrap.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/bootstrap.dart)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/network/interceptors/error_interceptor.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/network/interceptors/error_interceptor.dart)
- [lib/src/modules/core/logging_module.dart](/Users/biendh/base/lib/src/modules/core/logging_module.dart)
- [lib/src/modules/core/crashlytics_module.dart](/Users/biendh/base/lib/src/modules/core/crashlytics_module.dart)

### Files To Create

- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/observability/observability_service.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/observability/observability_service.dart)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/observability/trace_context.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/observability/trace_context.dart)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/observability/redaction_policy.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/observability/redaction_policy.dart)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/network/interceptors/observability_interceptor.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/network/interceptors/observability_interceptor.dart)

### Files To Delete

- none expected

## Implementation Steps

1. Add the brick-owned runtime observability package surface.
2. Thread correlation ids through app boot and starter flows.
3. Emit structured logs, spans, and bounded metrics from network and lifecycle seams.
4. Keep local sink default and remote exporters optional.

## Todo List

- [ ] Add observability core surface to the generated app brick
- [ ] Wire bootstrap and lifecycle correlation
- [ ] Add network observability interceptor
- [ ] Integrate logging and crash-report seams with shared context
- [ ] Cover starter flows with observability events

## Success Criteria

- Generated repos expose one owned runtime observability seam.
- Starter journeys emit inspectable runtime signals locally.
- No remote backend is required for the default generated app.

## Risk Assessment

- Risk: runtime overhead or noisy starter logs make smoke tests flaky.
- Mitigation: keep signal set bounded and make sinks cheap by default.

## Security Considerations

- Redaction happens before artifact write or console mirror.
- Default sinks must not capture secrets from headers, tokens, or credentials.

## Next Steps

- Export the new runtime signals into inspectable evidence and query surfaces.
