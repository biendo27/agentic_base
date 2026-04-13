# Phase 04 — Make Init Honest And Safe

## Context Links

- [Plan Overview](./plan.md)
- [Phase 01](./phase-01-lock-canonical-contract-model.md)
- [Phase 02](./phase-02-add-transactional-project-mutations.md)
- [Init / Module Contract Hardening Research](../reports/researcher-260410-1744-init-module-contract-hardening.md)

## Overview

- Priority: P1
- Status: Completed
- Goal: make `init` a trustworthy retrofit path that records what it truly knows, repairs missing support files safely, and never breaks analysis on first run.
- Result: init now resolves metadata from evidence, persists provenance, and writes a safe analyzer template when the include contract is absent.

## Key Insights

- `init` currently defaults org/platforms/flavors and calls them truth.
- Existing `.info/agentic.yaml` short-circuits the command, so helper files are never repaired or migrated.
- `analysis_options.yaml` currently includes `package:very_good_analysis/...` without guaranteeing the dependency/setup contract.

## Requirements

- Resolve metadata from trustworthy evidence in this order: existing config/migration data, explicit `--ci-provider`, project files, `pubspec.yaml`, filesystem/native artifacts, then contract defaults.
- Persist provenance for every field.
- Treat existing `.info/agentic.yaml` as a migration/repair entrypoint, not an immediate exit.
- Write `analysis_options.yaml` only when absent, and make it self-contained unless the target project already has the external include contract.

## Architecture

Data flow:
1. `init` loads existing config if present.
2. Resolver inspects `pubspec.yaml`, platform directories, CI files, flavor entrypoints, and native identifiers.
3. Resolver emits typed metadata plus warnings/default provenance.
4. Mutation journal backfills config and helper files safely.

## Related Code Files

- Modify: `lib/src/cli/commands/init_command.dart`
- Modify: `lib/src/config/agentic_config.dart`
- Modify: `lib/src/config/ci_provider.dart`
- Modify: `test/src/cli/commands/init_command_test.dart`
- Add retrofit fixtures under `test/`

## Implementation Steps

1. Extract metadata resolver helpers from `init_command.dart`.
2. Add migration/backfill behavior for existing config.
3. Replace substring state detection with dependency-key detection backed by `StateConfig`.
4. Replace the external-include analyzer template with a safe self-contained template unless the include contract already exists.
5. Add retrofit fixture tests across GitHub/GitLab, mixed platforms, custom flavors, and legacy config cases.

## Todo List

- [x] Honest metadata resolution order implemented
- [x] Existing config migration/backfill implemented
- [x] Safe analysis-options policy implemented
- [x] Retrofit fixtures added
- [x] provenance assertions added

## Success Criteria

- `init` never records an inferred value unless evidence exists.
- `init` on a repo without `very_good_analysis` does not create an immediate analyzer failure.
- Existing initialized repos can be repaired/migrated without losing module/config data.

## Risk Assessment

- Residual: future retrofits must preserve evidence order and warning/default provenance.
- Residual: downstream commands still need coverage whenever migration logic changes.

## Security / Integrity Considerations

- Honest provenance reduces the chance of later commands acting on fake metadata.
- Non-destructive file writes preserve user-managed project structure.

## Rollback Plan

- Keep helper-file writes additive only.
- If migration logic is unstable, disable config rewrites while leaving read-only diagnostics in place until fixed.

## Next Steps

- Phase 06 must include retrofit fixtures and analyzer-safety checks as permanent regressions.
