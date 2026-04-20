# Phase 02 - Implement Profile Presets And Default Module Resolution

## Context Links

- [Phase 01](./phase-01-freeze-product-contract-and-service-matrix.md)
- [System Architecture](../../docs/04-system-architecture.md)
- [Support Tier Matrix](../../docs/09-support-tier-matrix.md)
- [Manifest Schema](../../docs/10-manifest-schema.md)

## Overview

- Priority: P0
- Current status: Complete
- Brief description: Turn profile selection into deterministic create/init behavior by resolving default modules, providers, starter seams, and manifest values from a profile preset model.

## Key Insights

- Current profile handling is mostly metadata plus summaries.
- The generator needs one profile preset resolver, not scattered conditional logic.
- Thin base must remain reusable even while the default profile is more opinionated.

## Requirements

### Functional Requirements

- `create` must resolve profile-owned default-on modules when the user does not explicitly override them.
- `init` must preserve honesty for existing repos and never fabricate module/provider claims.
- Manifest output must show the effective capability set and providers.

### Non-Functional Requirements

- Deterministic
- Additive where possible
- No silent kitchen-sink behavior

## Architecture

- Add one profile preset source of truth in generator code.
- Separate:
  - universal base capability policy
  - profile default-on capability policy
  - user explicit module overrides
- Effective capability set should be:
  - user explicit modules if provided
  - otherwise profile default-on modules
  - always filtered through registry constraints and prerequisites

<!-- Updated: Validation Session 2 - preset resolution now owns default modules, provider maps, starter toggles, and rendered gate intent -->

## Related Code Files

### Files To Modify

- [lib/src/cli/commands/create_command.dart](/Users/biendh/base/lib/src/cli/commands/create_command.dart)
- [lib/src/cli/commands/init_command.dart](/Users/biendh/base/lib/src/cli/commands/init_command.dart)
- [lib/src/config/harness_metadata.dart](/Users/biendh/base/lib/src/config/harness_metadata.dart)
- [lib/src/config/init_project_metadata_resolver.dart](/Users/biendh/base/lib/src/config/init_project_metadata_resolver.dart)
- [lib/src/generators/project_generator.dart](/Users/biendh/base/lib/src/generators/project_generator.dart)
- [lib/src/modules/module_registry.dart](/Users/biendh/base/lib/src/modules/module_registry.dart)

### Files To Create

- [lib/src/config/profile_preset.dart](/Users/biendh/base/lib/src/config/profile_preset.dart)
- [test/src/config/profile_preset_test.dart](/Users/biendh/base/test/src/config/profile_preset_test.dart)

### Files To Delete

- none expected

## Implementation Steps

1. Create a profile preset model containing:
   - default modules
   - provider map overrides
   - starter runtime seam toggles
   - verify gate intent
2. Resolve effective modules during `create`.
3. Keep explicit user module selection authoritative over preset defaults.
4. Update `init` so it can infer profile safely without pretending existing repos already match the golden path.
5. Add unit tests for preset resolution and precedence rules.

## Todo List

- [x] Introduce profile preset model
- [x] Resolve create-time default modules from preset
- [x] Preserve user override precedence
- [x] Keep init inference honest by keeping existing repos on explicit or inferred capability truth instead of backfilling preset claims
- [x] Add preset resolution tests

## Success Criteria

- `subscription-commerce-app` materially changes the generated capability set when no explicit module override is passed.
- Other profiles can resolve different effective defaults without duplicating generator logic.
- `init` does not fabricate unsupported claims.

Status: met.

## Risk Assessment

- Risk: profile logic leaks across many files.
- Mitigation: one preset resolver, one precedence policy, one manifest contract.

## Security Considerations

- Provider defaults must remain secret-free.
- Ads, analytics, remote config, and payments should not imply live credentials.

## Next Steps

- Completed in Phase 03: preset toggles now feed generated starter seams and verify/release-preflight behavior.
