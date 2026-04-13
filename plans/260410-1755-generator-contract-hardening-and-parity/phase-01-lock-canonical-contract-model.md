# Phase 01 — Lock Canonical Contract Model

## Context Links

- [Plan Overview](./plan.md)
- [Multi-State Scaffold Parity Research](../reports/researcher-260410-1743-multi-state-scaffold-parity.md)
- [Init / Module Contract Hardening Research](../reports/researcher-260410-1744-init-module-contract-hardening.md)

## Overview

- Priority: P1
- Status: Completed
- Goal: replace raw string/map-driven generator decisions with typed state and metadata contracts that later phases can trust.
- Result: typed metadata, provenance, and scaffold profile helpers are in place for config reads, writes, and migration paths.

## Key Insights

- Public state options already exist, but scaffold/runtime contracts do not branch from one canonical profile.
- `.info/agentic.yaml` is the repo memory, but today it cannot distinguish explicit values from guesses.
- Later rollback and validation work is brittle until config/state inputs are typed.

## Requirements

- Add a typed project metadata model with `schema_version`, `project_kind`, `tool_version`, `state_management`, `ci_provider`, `platforms`, `flavors`, `modules`, and per-field provenance.
- Add an internal `ScaffoldStateProfile` derived from `StateConfig` that emits package sets, DI mode, template booleans, and contract expectations.
- Keep read compatibility with legacy `.info/agentic.yaml`.
- Do not change CLI flags or command names.

## Architecture

Data flow:
1. CLI args, `pubspec.yaml`, filesystem evidence, and existing config enter a resolver.
2. Resolver emits typed metadata plus provenance (`explicit`, `inferred`, `defaulted`, `migrated`).
3. `StateConfig` produces `ScaffoldStateProfile`.
4. Commands, generators, and contracts consume typed objects instead of raw maps/strings.

## Related Code Files

- Modify: `lib/src/config/agentic_config.dart`
- Modify: `lib/src/config/state_config.dart`
- Modify: `lib/src/cli/commands/init_command.dart`
- Modify: `lib/src/generators/project_generator.dart`
- Modify: `lib/src/generators/generated_project_contract.dart`
- Create: focused config/profile helpers under `lib/src/config/`

## Implementation Steps

1. Define schema v1 for project metadata and provenance.
2. Refactor `AgenticConfig` to read/write typed objects while preserving YAML compatibility.
3. Extract `ScaffoldStateProfile` from `StateConfig` and centralize all state-specific booleans/maps there.
4. Update generator/command entrypoints to pass typed config/profile objects only.
5. Add migration rules for legacy config reads.

## Todo List

- [x] Schema v1 fields finalized
- [x] Provenance enum/labels locked
- [x] State profile API finalized
- [x] Legacy config migration path covered by tests

## Success Criteria

- Every persisted metadata field has a trustworthy source label.
- No command needs to substring-scan raw YAML to infer state after this phase.
- State-dependent code reads from one profile object, not repeated `if (state == ...)` checks.

## Risk Assessment

- Residual: future schema migrations must preserve legacy reads and provenance labels.
- Residual: keep the scaffold profile limited to scaffold/runtime contract data only.

## Security / Integrity Considerations

- Provenance prevents silent fabrication of metadata.
- Schema versioning creates a safe place for future migrations instead of ad hoc map edits.

## Rollback Plan

- Keep legacy config reader path intact while introducing typed writes.
- If schema migration fails, revert writer changes while preserving new read helpers for diagnostics.

## Next Steps

- Phase 02 uses the typed metadata object and state profile as the only legal inputs to mutation planning.
