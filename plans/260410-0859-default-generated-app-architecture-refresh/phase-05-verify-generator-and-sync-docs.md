# Phase 05 - Verify Generator And Sync Docs

## Context Links

- Root docs to update: `README.md`, `docs/02-codebase-summary.md`, `docs/03-code-standards.md`, `docs/04-system-architecture.md`, `docs/07-design-guidelines.md`
- Generated-app docs: brick `README.md`, `docs/01-architecture.md`, `AGENTS.md`, `CLAUDE.md`
- Current test gap: no `ProjectGenerator` coverage under `test/src/generators/`
- Sample app baseline: `my_app/`

## Overview

- Priority: P1
- Status: completed
- Effort: 5h
- Blocked by: phases 01-04
- File ownership for this phase:
  - Repo docs, brick docs, generator regression tests, sample-app verification notes

## Key Insights

- Repo docs still advertise `lib/l10n` and do not describe the new ownership boundary.
- Package tests do not cover `ProjectGenerator`, so architecture drift can slip back in silently.
- Verification must cover both fixture app refresh (`my_app`) and a clean temp app generated from scratch.

## Requirements

- Add regression coverage for generator ownership, flavor config, and i18n path contracts.
- Define a verification matrix spanning unit, integration, and end-to-end smoke checks.
- Regenerate `my_app` deterministically from the real create flow or a checked scriptable equivalent before treating it as verified fixture output.
- Sync only canonical root docs and stale generated-app docs to the final architecture.
- Leave a rollback path that can revert docs/tests independently from runtime changes.

## Architecture

### Test Matrix

| Layer | Goal | Likely Files |
| --- | --- | --- |
| Unit | Validate app-id generation, forbidden file manifest, generator sequencing helpers | `test/src/generators/project_generator_test.dart` |
| Integration | Generate temp app and assert file tree, `build.yaml`, `flavorizr.yaml`, IDE config presence | `test/integration/generated_app_smoke_test.dart` or equivalent scripted harness |
| End-to-end smoke | Run codegen, `flutter analyze`, `flutter test` on one fresh temp generated app, then refresh/verify `my_app` fixture | CI/local script step; may reuse `tools/setup.sh` / `tools/gen.sh` |

### Data Flow

- Input: refreshed brick, generator code, refreshed `my_app`.
- Transform:
  1. Repo tests validate pure helpers and file manifests.
  2. Smoke workflow generates a temp app.
  3. Temp app and `my_app` run codegen, analyze, test.
  4. Docs update to match verified output only.
- Output: enforceable architecture contract plus aligned docs.

## Related Code Files

- Modify:
  - `README.md`
  - `docs/02-codebase-summary.md`
  - `docs/03-code-standards.md`
  - `docs/04-system-architecture.md`
  - `docs/07-design-guidelines.md`
  - brick `README.md`, `docs/01-architecture.md`, `AGENTS.md`, `CLAUDE.md`
  - `bricks/agentic_app/hooks/post_gen.dart`
  - `my_app/README.md`, `my_app/AGENTS.md`, `my_app/CLAUDE.md`
- Create:
  - `test/src/generators/project_generator_test.dart`
  - optional integration smoke harness under `test/integration/`

## Implementation Steps

1. Add generator-focused tests for ownership cleanup, app-id generation, forbidden IDE artifacts, feature i18n scaffolding, and expected template paths.
2. Add one smoke workflow that generates a temp app and asserts no forbidden files exist.
3. In the same smoke workflow, assert:
   1. `lib/app/i18n` output exists after codegen
   2. no legacy root shell files exist
   3. no forbidden `.idea` files exist
4. Regenerate `my_app` from the verified flow, then run:
   1. `flutter pub get`
   2. `dart run build_runner build --delete-conflicting-outputs`
   3. `flutter analyze`
   4. `flutter test`
5. Update canonical root docs and only stale generated-app docs after the smoke workflow passes.
6. Capture rollback notes in plan execution summary or changelog.

## Todo List

- [ ] Add `ProjectGenerator` tests
- [ ] Add generated-app smoke harness
- [ ] Regenerate and verify `my_app` fixture
- [ ] Sync canonical repo docs
- [ ] Sync only stale generated-app docs

## Success Criteria

- Tests cover the new architecture contract, not just happy-path codegen.
- Smoke run proves no duplicate root app files or legacy `l10n/` paths exist.
- Smoke run proves no forbidden `.idea` files exist.
- Docs consistently describe `assets/i18n`, `lib/app/i18n`, native-only `flutter_flavorizr`, and IDE ownership.
- Team can regenerate a starter app and get the same contract without manual cleanup.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Smoke tests are slow or flaky | Medium | Medium | Keep unit tests fast; isolate slow smoke step and reuse temp directories carefully |
| Docs still miss one stale path reference | Medium | Medium | Add grep-based doc sweep for `lib/l10n`, `lib/app.dart`, `lib/flavors.dart` |
| `my_app` fixture diverges from fresh generation | Medium | High | Regenerate fixture from the verified smoke flow before accepting it |

## Security Considerations

- Never commit non-example env files or secrets while refreshing `my_app`.
- Smoke harness must use example env files only.
- Generated docs must not instruct users to commit private runtime config.

## Rollback

- Revert docs and tests independently if needed.
- If smoke workflow exposes unresolved code issues, keep this phase open and do not mark the overall plan complete.

## Next Steps

- No further phases.
- Unresolved questions: none.
