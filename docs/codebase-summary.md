# Codebase Summary

## Snapshot

Generated from `repomix-output.xml` on 2026-04-13.

| Metric | Value |
| --- | ---: |
| Files | 271 |
| Tokens | 202,387 |
| Chars | 860,329 |

The repository root is the package root. Evergreen docs live in `docs/`; implementation plans and reports live in `plans/`.

## Main Code Areas

| Area | Responsibility |
| --- | --- |
| `lib/src/cli/` | Command runner plus individual CLI commands. |
| `lib/src/config/` | `.info/agentic.yaml` state, init metadata inference and repair, state profile config. |
| `lib/src/generators/` | Project, feature, and contract generation orchestration. |
| `lib/src/modules/` | Module contract, registry, rollback journal, integration generator, install/uninstall helpers. |
| `bricks/agentic_app` | Main app starter brick plus Mason hooks and state-conditional scaffolding. |
| `bricks/agentic_feature` | Feature scaffold brick with cubit/riverpod/mobx branches. |
| `test/src/` | Unit tests around CLI metadata, parsers, registry logic, and generators. |
| `test/integration/` | Generated-app smoke tests plus module wiring coverage. |

## Contract Highlights

- `ScaffoldStateProfile` keeps cubit, riverpod, and mobx scaffolds aligned across app and feature generation.
- `InitProjectMetadataResolver` infers project metadata from `pubspec.yaml`, CI files, Android/iOS bundle IDs, and flavor files, then repairs existing metadata with provenance.
- `ProjectMutationJournal` makes module add/remove flows rollback-safe.
- `ModuleIntegrationGenerator` emits live DI/provider registries from discovered service contracts.
- `AnalyticsModule` is a working integration with an `AnalyticsService` contract and Firebase implementation.
- `GeneratedProjectContract` validates state-specific starter-app shape, CI provider outputs, and forbidden leftovers.

## Operational Facts

- Repo CI is GitHub-hosted only.
- Generated projects can scaffold GitHub or GitLab CI from one persisted provider contract.
- Package release/publish automation is not checked in.
- Several command/orchestration files still exceed the 200 LOC target.
