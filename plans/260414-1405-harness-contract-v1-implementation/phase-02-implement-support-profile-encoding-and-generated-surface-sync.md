# Phase 02: Implement Support Profile Encoding And Generated Surface Sync

## Context Links

- [Plan overview](./plan.md)
- [Support tier matrix](../../docs/09-support-tier-matrix.md)
- [Manifest schema](../../docs/10-manifest-schema.md)
- [README](../../README.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: encode app profile identity and support-tier semantics into generated repos and keep generated docs/adapters honest.

## Key Insights

- Profile identity is the new truthful replacement for vague "supports all Flutter apps" language.
- The generated surface must stay in sync with manifest claims, or the contract will drift immediately.
- Tier 2 must remain core-gates-only and should not inherit Tier 1 promises by accident.

## Requirements

- Introduce `primary_profile` and `secondary_traits` into generation flows.
- Ensure create/init/upgrade can preserve or infer profile data when allowed.
- Update generated README/adapters/docs to reflect support tiers and contract language.
- Keep profile-derived values inspectable without duplicating sources of truth.

## Architecture

- Profile is stored in the harness manifest.
- Generated repo docs should summarize the profile and support level using manifest-derived values.
- `init` may infer profile only when there is enough evidence and provenance can record inference honestly.
- Read-model fields like `support_tier` should remain derived, not authoritative.

## Related Code Files

- Modify:
  - `/Users/biendh/base/lib/src/generators/project_generator.dart`
  - `/Users/biendh/base/lib/src/cli/commands/create_command.dart`
  - `/Users/biendh/base/lib/src/cli/commands/upgrade_command.dart`
  - `/Users/biendh/base/lib/src/config/init_project_metadata_resolver.dart`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/AGENTS.md`
  - `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/CLAUDE.md`
  - `/Users/biendh/base/docs/01-project-overview-pdr.md`
  - `/Users/biendh/base/README.md`
  - `/Users/biendh/base/test/src/cli/commands/create_command_test.dart`
  - `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`
- Create:
  - None expected
- Delete:
  - None expected

## Implementation Steps

1. Add profile inputs/defaulting rules for create/init.
2. Encode profile and traits in the harness manifest.
3. Update generated human-readable surfaces to summarize profile semantics honestly.
4. Add contract checks to ensure generated docs and manifest agree.
5. Add smoke coverage for profile-aware generated output.

## Todo List

- [x] Add profile inputs and defaults
- [x] Write profile data into the harness manifest
- [x] Sync generated docs/adapters with profile claims
- [x] Add contract checks for generated-surface parity
- [x] Add profile-aware smoke coverage

## Success Criteria

- Generated repos expose a truthful profile identity and tier semantics.
- Tier-2 repos only claim core required gates.
- Generated docs and manifest stay aligned.

## Risk Assessment

- Risk: inferred profile behavior becomes guessy and undermines trust.
- Mitigation: prefer explicit profile selection; record inference provenance only when justified.

## Security Considerations

- Profile selection must not imply capability enablement that would silently require credentials.
- Human approval boundaries must remain unchanged across tiers.

## Next Steps

- Completed. Phase 03 makes the eval/evidence/approval model executable.
