# Phase 01 - Lock Generated App Ownership Boundary

## Context Links

- Repo docs: `README.md`, `docs/02-codebase-summary.md`, `docs/03-code-standards.md`, `docs/04-system-architecture.md`, `docs/07-design-guidelines.md`
- Generator: `lib/src/generators/project_generator.dart`
- Brick docs: `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`, `docs/01-architecture.md`, `AGENTS.md`, `CLAUDE.md`
- Research: `./research/current-state-and-tooling-contracts.md`

## Overview

- Priority: P1
- Status: completed
- Effort: 5h
- Blocked by: none
- File ownership for this phase:
  - `lib/src/generators/project_generator.dart`
  - Brick contract docs that define generated structure and ownership

## Key Insights

- `flutter create` + brick overlay + post-overlay `flutter_flavorizr` currently produce overlapping ownership.
- Generated `my_app` proves the drift: brick-owned `lib/app/*` coexists with tool-generated `lib/app.dart`, `lib/flavors.dart`, and `lib/pages/*`.
- The fix is not more templates. The fix is one ownership contract plus generator-side cleanup and validation.

## Requirements

- Brick must own Flutter-layer bootstrap files: `lib/app/**`, `lib/main*.dart`, `.vscode/**`, shared `.idea/runConfigurations/**`.
- `flutter create` stays responsible for native shell directories.
- `flutter_flavorizr` must never be allowed to reclaim Dart/UI ownership.
- Critical create-flow steps must be blocking by contract: `flutter pub get`, `flutter_flavorizr`, `build_runner`, layout assertions, analyze, and tests.
- Generated-project docs must describe the final ownership contract, not the old `lib/l10n` story.

## Architecture

### Data Flow

- Input: `agentic_base create` args (`projectName`, `org`, `platforms`, `flavors`, `stateManagement`, `primaryColor`).
- Transform:
  1. `flutter create` emits native project shell.
  2. Mason brick overlays the approved Flutter-layer source of truth.
  3. Generator runs post-process tools.
  4. Generator cleanup validates ownership and deletes forbidden Flutter-layer outputs from tools.
- Output: one generated app tree with clear tool boundaries and no dual shell.

### Boundary Contract

- Brick-owned: `lib/app/**`, `lib/main*.dart`, `assets/i18n/**`, `env/*.env.example`, `.vscode/**`, `.idea/runConfigurations/**`, generated-app docs.
- Tool-owned: native platform folders from `flutter create`; native flavor artifacts from `flutter_flavorizr`.
- Forbidden after generation: `lib/app.dart`, `lib/flavors.dart`, `lib/pages/**`, shared `.idea/workspace.xml`, SDK library XMLs.

### Failure Contract

- Blocking:
  - `flutter pub get`
  - `flutter_flavorizr`
  - `build_runner`
  - forbidden-file cleanup/assertions
  - required-file assertions
  - analyze
  - test
- Non-blocking:
  - cosmetic fixups only, if explicitly listed
- Any blocking failure aborts generation and triggers rollback for the fresh create output.

### Execution Surface Matrix

| Surface | Contract |
| --- | --- |
| Plain CLI | `flutter run` resolves through brick-owned `lib/main.dart` alias |
| Flavored CLI | `flutter run --flavor <name> -t lib/main_<name>.dart --dart-define-from-file=env/<name>.env.example` |
| VS Code | launch configs mirror flavored CLI |
| JetBrains | shared run configs mirror flavored CLI |
| Scripts/Makefile | same target/define contract as flavored CLI |
| CI/create smoke | same target/define contract as flavored CLI where flavor-specific boot is needed |
| Docs/next steps | describe the same commands, no alternate path |

## Related Code Files

- Modify:
  - `lib/src/generators/project_generator.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/01-architecture.md`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/AGENTS.md`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/CLAUDE.md`
- Create:
  - none required if contract lives inside existing files
- Delete during generation:
  - `<generated-app>/lib/app.dart`
  - `<generated-app>/lib/flavors.dart`
  - `<generated-app>/lib/pages/**`

## Implementation Steps

1. Add an explicit ownership manifest to `ProjectGenerator` for allowed brick-owned Flutter-layer files and forbidden post-tool outputs.
2. Insert a generator validation step after all post-processing tools run; fail loudly if forbidden files remain or required brick files are missing.
3. Scope cleanup to fresh `create` output only. Never make the cleanup reusable for `init`.
4. Move create-flow failure semantics from warning behavior to explicit blocking behavior with rollback.
5. Update generated-app docs to state the new ownership boundary and the new i18n location contract introduced in phase 2.

## Todo List

- [ ] Define generator-side forbidden file list
- [ ] Define required brick-owned file list
- [ ] Add post-generation validation and cleanup
- [ ] Add explicit blocking/non-blocking command matrix
- [ ] Add execution-surface run matrix
- [ ] Update generated-app ownership docs

## Success Criteria

- Fresh generated app has zero duplicate app shell files.
- Generator logs make ownership failures obvious and actionable.
- Create flow cannot report success if flavor/codegen/layout/analyze/test failed.
- Generated-app docs describe brick vs tool ownership with no ambiguity.
- Phase can be merged without touching runtime architecture yet.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Cleanup deletes a valid file | Low | High | Restrict cleanup to explicit forbidden paths in fresh create flow only |
| Brick gains new required files later and manifest drifts | Medium | Medium | Keep manifest near tests in phase 5 and document update rule |
| Ownership docs drift from code | Medium | Medium | Treat doc updates as same-phase acceptance gate |

## Security Considerations

- Never allow cleanup to resolve outside generated project root.
- Do not log env contents or generated secrets during validation.
- Keep shared IDE files limited to non-user-specific config only.

## Rollback

- Revert ownership manifest and cleanup step only.
- Restore prior generated-app docs if rollout fails before later phases land.

## Next Steps

- Phase 02 can start after ownership rules are merged.
- Phase 05 must add regression coverage for this manifest.
