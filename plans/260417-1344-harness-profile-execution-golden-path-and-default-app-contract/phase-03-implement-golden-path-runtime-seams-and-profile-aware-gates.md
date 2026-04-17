# Phase 03 - Implement Golden Path Runtime Seams And Profile-Aware Gates

## Context Links

- [Phase 02](./phase-02-implement-profile-presets-and-default-module-resolution.md)
- [Eval And Evidence Model](../../docs/11-eval-and-evidence-model.md)
- [Approval State Machine](../../docs/12-approval-state-machine.md)
- [Flutter Adapter Boundaries](../../docs/13-flutter-adapter-boundaries.md)

## Overview

- Priority: P0
- Current status: Complete
- Brief description: Make the subscription-commerce golden path real in generated starter runtime seams and verify behavior without turning the universal base into a kitchen sink.

## Key Insights

- The generator already has service seams for many modules.
- The missing step is profile-owned starter behavior and gate execution differences.
- Payments must stay separated from entitlements.
- Validation fixed ads as generated-but-safe by default and payments as digital subscription first.

## Requirements

### Functional Requirements

- Add or refine the default app service seams for:
  - analytics
  - crash reporting
  - remote config
  - feature flags
  - payments
  - entitlements
  - consent
  - notifications
  - deep links
  - app review
  - app update
- Generate ads seam and provider runtime in the golden path, but keep ads inactive until consent and config gates pass.
- Harden default payments around `in_app_purchase` for digital subscription.
- Keep external checkout opt-in only.
- Make verify gates profile-aware for Tier 1.
- Keep Tier 2 extras advisory until deterministic.

### Non-Functional Requirements

- Starter remains bootable without real credentials.
- Golden-path checks stay deterministic in CI.
- Service seams remain replaceable.

## Architecture

- Universal base ships contract files and safe starter stubs.
- Golden-path preset enables runtime seams and starter usage for selected services.
- Verify gate differences should come from one gate policy resolver, not shell-script drift.
- `PaymentsService` and `EntitlementService` stay separate.
- `ConsentService` gates ads and analytics behavior where needed.

<!-- Updated: Validation Session 2 - starter runtime profile, consent and entitlement seams, and rendered gate policy now ship from generator-owned policy -->

## Related Code Files

### Files To Modify

- [lib/src/generators/agentic_app_surface_synchronizer.dart](/Users/biendh/base/lib/src/generators/agentic_app_surface_synchronizer.dart)
- [lib/src/generators/generated_project_contract.dart](/Users/biendh/base/lib/src/generators/generated_project_contract.dart)
- [bricks/agentic_app/brick.yaml](/Users/biendh/base/bricks/agentic_app/brick.yaml)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release-preflight.sh](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/release-preflight.sh)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/_common.sh](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/_common.sh)

### Files To Create

- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/commerce/entitlement_service.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/commerce/entitlement_service.dart)
- [bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/privacy/consent_service.dart](/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/privacy/consent_service.dart)
- [test/src/generators/profile_gate_contract_test.dart](/Users/biendh/base/test/src/generators/profile_gate_contract_test.dart)

### Files To Delete

- none expected

## Implementation Steps

1. Define the starter runtime seams needed for the golden path.
2. Add safe default implementations and generated docs for those seams.
3. Make verify gate execution depend on effective profile and capability set.
4. Keep unsupported or non-deterministic checks advisory only.
5. Add regression tests proving Tier 1 profiles differ from Tier 2 in required gate behavior.

## Todo List

- [x] Add missing commerce/privacy seams
- [x] Wire golden-path starter behavior
- [x] Introduce profile-aware gate resolution
- [x] Keep Tier 2 extras advisory
- [x] Add contract tests for gate differences

## Success Criteria

- The generated `subscription-commerce-app` starter exposes real golden-path seams, not only docs.
- `verify.sh` does more than print `core + profile pack`; it materially changes required behavior for Tier 1 profiles.
- Tier 2 profiles do not inherit unproven required checks.

Status: met.

## Risk Assessment

- Risk: gate logic becomes duplicated between Dart and shell.
- Mitigation: resolve gate policy in one owned place and render shell surfaces from that policy.

## Security Considerations

- Payments starter must never imply real store credentials.
- Consent must remain explicit before ad or analytics activation patterns become richer.
- Evidence must redact anything provider-sensitive.

## Next Steps

- Completed in Phase 04: the default starter UI now exposes the profile-owned seams in the trustworthy-commerce surface.
