# Phase 02: Dependency Freshness And Module Catalog

## Context Links

- Research: [Run, Flavor, Dependency Report](./research/researcher-run-flavor-dependency-report.md)
- `/Users/biendh/base/lib/src/modules/module_dependency_catalog.dart`
- `/Users/biendh/base/lib/src/modules/module_installer.dart`
- `/Users/biendh/base/lib/src/modules/extended/deep_link_module.dart`
- Dart docs: https://dart.dev/tools/pub/cmd/pub-add
- Dart dependency docs: https://dart.dev/tools/pub/dependencies
- Flutter upgrade docs: https://docs.flutter.dev/install/upgrade

## Overview

Priority: P1. Status: Complete.

Make dependency freshness explicit and verified. Remove known-broken stale dependencies and add a maintainable way to refresh generated-app dependency constraints.

## Key Insights

- `uni_links` caused a real Android AGP namespace failure and is unused because provider is `app_links`.
- Live dependency resolution during every module install would make output non-deterministic.
- Static catalog without refresh will drift. The right policy is release-time latest verified stable compatible.

## Requirements

- Remove `uni_links` from catalog and deep-link module.
- Keep module dependency resolution deterministic by default.
- Add an explicit dependency-refresh workflow for maintainers.
- Refresh all baseline brick `pubspec.yaml` dependencies and module catalog constraints to newest stable compatible with the tested Flutter/Dart SDK.
- Make tests derive expected module constraints from the catalog instead of duplicating pins.
- Keep independent forbidden-package assertions, including no `uni_links`.
- Add evidence output or report from `flutter pub outdated` / upgrade flow.

## Architecture

```text
maintainer -> refresh dependency catalog -> update pubspec/catalog -> generated app verify
end user   -> create/add module          -> deterministic known-good constraints
```

## Related Code Files

- Modify `/Users/biendh/base/lib/src/modules/module_dependency_catalog.dart`.
- Modify `/Users/biendh/base/lib/src/modules/module_installer.dart` only if helper API needed.
- Modify `/Users/biendh/base/lib/src/modules/extended/deep_link_module.dart`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/pubspec.yaml`.
- Modify `/Users/biendh/base/test/src/modules/module_dependency_catalog_test.dart`.
- Modify `/Users/biendh/base/test/src/cli/commands/add_command_test.dart`.
- Create `/Users/biendh/base/tool/refresh-dependency-catalog.dart` or equivalent maintainer script if no existing maintenance command fits.
- Update `/Users/biendh/base/docs/14-sdk-and-version-policy.md`.

## Implementation Steps

1. Remove `uni_links` from `module_dependency_catalog.dart`.
2. Update `DeepLinkModule` dependency list and description to `app_links` only.
3. Audit baseline brick dependencies and module catalog against newest stable compatible versions.
4. Add `tool/refresh_dependency_catalog.dart`:
   - reads package names from brick pubspec and module catalog
   - resolves latest stable compatible constraints in a temp Flutter project
   - runs report-only by default
   - requires `--write` for mutations
   - records SDK version, date, before/after constraints, major jumps, and generated-app verification result
5. Update tests so version expectations reference the catalog.
6. Add tests for catalog coverage, parsable constraints, forbidden packages, and generated pubspec/catalog sync.
7. Run package tests plus generated-app smoke after refresh.

## Todo List

- [x] Remove `uni_links`.
- [x] Refresh dependency constraints.
- [x] Add/define catalog refresh workflow.
- [x] Update tests to avoid duplicated hard-coded package versions.
- [x] Preserve independent forbidden-package tests.
- [x] Document policy as latest verified compatible.

## Success Criteria

- `agentic_base create` no longer generates `uni_links`.
- Generated Android app no longer fails on `:uni_links` namespace.
- Dependency versions in generated `pubspec.yaml` are newest verified compatible for the current `agentic_base` release.
- Refresh workflow is repeatable before future pub.dev releases.

## Risk Assessment

- Major-version upgrades can break generated code, Gradle, or iOS pods.
- Refresh must run full generated-app verification, not just `dart test`.

## Security Considerations

- Do not add dependency overrides silently.
- Dependency refresh report must highlight major-version jumps for review.

## Next Steps

Phase 05 will validate actual generated app runtime after dependency changes.
