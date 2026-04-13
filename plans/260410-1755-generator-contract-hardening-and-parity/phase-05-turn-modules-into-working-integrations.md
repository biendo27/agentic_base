# Phase 05 — Turn Modules Into Working Integrations

## Context Links

- [Plan Overview](./plan.md)
- [Phase 02](./phase-02-add-transactional-project-mutations.md)
- [Phase 03](./phase-03-implement-full-multi-state-scaffold-parity.md)
- [Init / Module Contract Hardening Research](../reports/researcher-260410-1744-init-module-contract-hardening.md)

## Overview

- Priority: P1
- Status: Completed
- Goal: replace inert module file drops with deterministic, state-aware integrations that wire into generated bootstrap and DI seams.
- Result: modules now write live bootstrap/DI seams, analytics is integrated, and install/remove symmetry is journaled.

## Key Insights

- Current modules mostly add dependencies plus service files and print manual steps.
- There is no structured place for module bootstrap hooks or DI registration.
- App bootstrap and DI already have stable entrypoints; they should become the only legal integration seams.

## Requirements

- Extend the internal module contract to declare versioned dependencies plus integration contributions.
- Add stable generated seams for module bootstrap and dependency registration. No AST patching.
- Support both DI shapes: get_it/injectable for cubit/mobx, provider-driven seams for riverpod.
- Migrate all shipped modules to the new contract in grouped batches; do not stop at a pilot subset.

## Architecture

Data flow:
1. Module manifest declares dependency edits, generated files, DI registrations, startup tasks, and manual platform steps.
2. Transaction planner resolves prerequisite order from `ModuleRegistry`.
3. Installer writes files and updates generated bootstrap/DI registries.
4. Config records installed modules and outstanding manual steps after commit.

## Related Code Files

- Modify: `lib/src/modules/base_module.dart`
- Modify: `lib/src/modules/module_installer.dart`
- Modify: `lib/src/modules/module_registry.dart`
- Modify: all module implementations under `lib/src/modules/**`
- Modify: `bricks/agentic_app/**/lib/app/bootstrap.dart`
- Modify: `bricks/agentic_app/**/lib/core/di/injection.dart`
- Add module seam files under the app brick if needed

## Implementation Steps

1. Replace bare package-name lists with deterministic dependency maps.
2. Define minimal manifest fields for generated file writes, DI contributions, startup hooks, and persisted manual steps.
3. Add app-brick integration seams for bootstrap and DI/provider registration.
4. Migrate modules group-by-group and keep install/remove symmetric.
5. Add representative compile-time integration tests across all three state families.

## Todo List

- [x] Internal module manifest finalized
- [x] App integration seams finalized
- [x] All modules migrated
- [x] remove path symmetry validated
- [x] representative compile tests added

## Success Criteria

- Installing a module changes runtime seams, not just file inventory.
- Removing a module cleans its files, dependency entries, and bootstrap/DI registrations.
- Representative module combinations compile in cubit, riverpod, and mobx starters.

## Risk Assessment

- Residual: new modules still need manifest entries and seam support before installation is considered integrated.
- Residual: keep install/remove symmetry aligned across all state families.

## Security / Integrity Considerations

- Deterministic dependency versions improve reproducibility of generated projects.
- Structured manual steps make risky platform requirements auditable instead of ephemeral console text.

## Rollback Plan

- Keep module integration seams additive and isolated to generated registry files.
- If one migrated module fails, block shipment of the new contract rather than mixing old inert modules with new live ones.

## Next Steps

- Phase 06 converts these guarantees into permanent regression gates and doc updates.
