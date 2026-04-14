# Phase 04: Finish Runtime Bootstrap Integrations And Firebase Seams

## Context Links

- [Plan overview](./plan.md)
- [Phase 03](./phase-03-make-module-installation-deterministic-and-versioned.md)
- [Review findings snapshot](./reports/agent-ready-review-findings.md)
- [`docs/04-system-architecture.md`](../../docs/04-system-architecture.md)

## Overview

- Priority: P0
- Status: Proposed
- Goal: convert partial module file drops into working bootstrap/runtime integrations or explicit preflight failures.

## Key Insights

- The current runtime gap is concentrated in startup-bound seams: Firebase initialization, notifications bootstrap, remote config warmup, and crash/error ordering.
- A generator-owned module is not complete if the user still has to guess where app-start hooks belong.
- Silent partial integration is worse than a hard failure because it looks installed but is not trustworthy.

## Requirements

- Define an explicit Firebase initialization strategy for the default supported platforms, including web/options behavior.
- Expand module runtime seams beyond bare `init()` discovery where startup hooks need ordering or arguments.
- Make notifications, remote config, crash reporting, and related Firebase-backed modules install as working integrations or fail via preflight/setup checks.
- Preserve generator-owned boundaries; do not auto-rewrite arbitrary user app logic outside the owned bootstrap seam.

## Architecture

- Promote bootstrap ownership into a first-class generator seam with ordered hook stages.
- Module metadata should declare required bootstrap stage, prerequisites, and failure conditions.
- Firebase runtime helpers should centralize initialization, options selection, and error-reporting handoff.

## Related Code Files

- Modify:
  - `/Users/biendh/base/lib/src/modules/firebase_runtime_template.dart`
  - `/Users/biendh/base/lib/src/modules/module_integration_generator.dart`
  - `/Users/biendh/base/lib/src/modules/core/analytics_module.dart`
  - `/Users/biendh/base/lib/src/modules/core/auth_module.dart`
  - `/Users/biendh/base/lib/src/modules/core/crashlytics_module.dart`
  - `/Users/biendh/base/lib/src/modules/extended/notifications_module.dart`
  - `/Users/biendh/base/lib/src/modules/extended/remote_config_module.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/bootstrap.dart`
  - `/Users/biendh/base/test/src/modules/**/*.dart`
  - `/Users/biendh/base/test/src/generators/**/*.dart`

## Implementation Steps

1. Define the owned bootstrap stages and the module metadata each stage requires.
2. Centralize Firebase bootstrap behavior, including explicit options/preflight rules.
3. Update startup-bound modules to register against the new stages instead of manual TODO text.
4. Add generated-app smoke coverage for at least one Firebase-backed module and one non-Firebase startup module.
5. Ensure failures surface as explicit setup/preflight errors, not silent partial wiring.

## Todo List

- [ ] Define ordered bootstrap stages
- [ ] Centralize Firebase init/options behavior
- [ ] Rework startup-bound module metadata and generation
- [ ] Add runtime smoke coverage across module classes
- [ ] Replace silent partial integrations with explicit failures

## Success Criteria

- Default generated repos have a clear, tested Firebase bootstrap strategy.
- Notifications, remote config, and similar modules wire through owned seams without manual app-start guessing.
- Unsupported runtime states fail loudly before release-preflight or smoke verification passes.

## Risk Assessment

- Risk: bootstrap abstraction becomes too generic and hard to reason about.
- Mitigation: keep stages small, explicit, and limited to real startup needs already present in the module catalog.

## Security Considerations

- Error reporting and crash hooks must not swallow bootstrap failures.
- Preflight must distinguish missing credentials/config from code-generation errors.

## Next Steps

- Phase 05 locks these fixes behind regression gates and product-facing docs.
