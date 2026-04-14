# Phase 03: Make Module Installation Deterministic And Versioned

## Context Links

- [Plan overview](./plan.md)
- [Phase 01](./phase-01-repair-init-contract-truth-and-canonical-context.md)
- [Review findings snapshot](./reports/agent-ready-review-findings.md)
- [`docs/03-code-standards.md`](../../docs/03-code-standards.md)

## Overview

- Priority: P1
- Status: Proposed
- Goal: stop emitting `any` dependency constraints and make module install output reproducible.

## Key Insights

- A repo cannot be called deterministic if dependency versions float with pub.dev state at install time.
- The current problem is baked into both implementation and tests, so silent regression is likely.
- Version policy must be repo-owned and updateable without editing dozens of modules manually.

## Requirements

- Replace `any` defaults with explicit version constraints for runtime and dev dependencies.
- Centralize dependency version ownership so module definitions stay consistent.
- Update tests and fixtures to assert exact constraints, not floating placeholders.
- Document how dependency versions are updated when generator support changes.

## Architecture

- Introduce one package-owned dependency catalog for module-added packages.
- `ModuleInstaller` reads from that catalog and rejects missing versions instead of falling back to `any`.
- Module definitions keep semantic intent; version resolution stays centralized.

## Related Code Files

- Modify:
  - `/Users/biendh/base/lib/src/modules/module_installer.dart`
  - `/Users/biendh/base/lib/src/modules/module_registry.dart`
  - `/Users/biendh/base/lib/src/modules/**/*.dart`
  - `/Users/biendh/base/test/src/cli/commands/add_command_test.dart`
  - `/Users/biendh/base/test/src/modules/**/*.dart`
  - `/Users/biendh/base/README.md`

## Implementation Steps

1. Inventory every dependency currently added through module installation.
2. Add a central version source and migrate module install logic to it.
3. Remove `any` fallbacks and fail fast when a module requests an unversioned package.
4. Rewrite affected tests to assert deterministic constraints.
5. Document the maintenance path for updating catalog entries.

## Todo List

- [ ] Inventory module-added packages
- [ ] Create a central dependency version source
- [ ] Remove `any` fallback behavior
- [ ] Update tests to assert explicit constraints
- [ ] Document version maintenance workflow

## Success Criteria

- No module install path writes `any` into `pubspec.yaml`.
- Fresh installs from the same package version produce the same dependency constraints.
- Missing version metadata fails loudly in tests and runtime.

## Risk Assessment

- Risk: pinned versions drift from supported Flutter/Firebase constraints.
- Mitigation: keep the catalog audited in tests and tie updates to module support changes.

## Security Considerations

- Deterministic versions reduce accidental intake of unreviewed dependency changes.
- Version policy must not encourage hidden network-time resolution behavior.

## Next Steps

- Phase 04 uses the deterministic dependency baseline to finish runtime bootstrap ownership.
