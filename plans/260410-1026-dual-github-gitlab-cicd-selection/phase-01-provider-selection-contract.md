# Phase 01 — Provider Selection Contract

## Context Links
- [Plan Overview](./plan.md)
- [Deployment Guide](../../docs/06-deployment-guide.md)
- [Create Command](../../lib/src/cli/commands/create_command.dart)
- [Init Command](../../lib/src/cli/commands/init_command.dart)
- [AgenticConfig](../../lib/src/config/agentic_config.dart)
- [App Brick](../../bricks/agentic_app/brick.yaml)

## Overview
- **Priority**: P1
- **Status**: Completed
- **Effort**: 3h
- **Depends on**: None
- **File ownership**: `lib/src/cli/commands/create_command.dart`, `lib/src/cli/commands/init_command.dart`, `lib/src/tui/prompts.dart`, `lib/src/config/agentic_config.dart`, `lib/src/generators/project_generator.dart`, `bricks/agentic_app/brick.yaml`, `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.info/agentic.yaml`
- **Description**: Add one provider-selection contract that downstream tooling can trust.

## Key Insights
- `create` already validates and normalizes generation inputs before calling `ProjectGenerator`.
- `.info/agentic.yaml` is the current source of truth for generated-project state; `deploy` already depends on it.
- `init` creates config directly and currently has no CI-provider concept.
- Current generated config has no CI field, so legacy projects need a fallback path.

## Requirements

### Functional Requirements
- Support exactly two persisted values: `github`, `gitlab`.
- Add `--ci-provider` to `create` and `init`.
- Default to `github` when omitted.
- Persist provider to `.info/agentic.yaml`.
- Do not allow `deploy`-time provider override; the project owns one provider.

### Non-Functional Requirements
- Keep create/init UX backwards compatible.
- Keep provider parsing centralized to avoid string drift.
- Do not require a migration command for existing projects.

## Architecture

### Data Flow
1. User input enters via `create --ci-provider` or `init --ci-provider`.
2. CLI normalizes input against one shared provider list.
3. `ProjectGenerator.generate(... ciProvider)` and `AgenticConfig.createInitial(... ciProvider)` persist the choice.
4. Mason receives `ci_provider` as a brick var.
5. Later commands read the same field from `.info/agentic.yaml`.

### Contract Decisions
- Persist provider as `ci_provider`, not nested config.
- Default value: `github`.
- Legacy resolution rule for missing field:
  - first infer from checked-in CI files when possible
  - otherwise assume `github` and warn once in deploy/docs

## Related Code Files

### Files to Modify
- `lib/src/cli/commands/create_command.dart`
- `lib/src/cli/commands/init_command.dart`
- `lib/src/tui/prompts.dart`
- `lib/src/config/agentic_config.dart`
- `lib/src/generators/project_generator.dart`
- `bricks/agentic_app/brick.yaml`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.info/agentic.yaml`

### Files to Create
- Optional: `lib/src/config/ci_provider.dart` if shared parsing/constants would otherwise bloat command files

### Files to Delete
- None

## Implementation Steps
1. Define shared provider constants and validation rules.
2. Add `--ci-provider` to `create`; keep `github` as the non-interactive default.
3. Add `--ci-provider` to `init`; if omitted, inspect `.github/workflows` and `.gitlab-ci.yml` before falling back to `github`.
4. Extend `ProjectGenerator.generate` and `AgenticConfig.createInitial` to accept and persist `ci_provider`.
5. Add `ci_provider` to Mason vars so the app brick can render the correct provider assets later.
6. Keep all provider resolution rules in one place so `deploy`, tests, and docs use the same contract.

## Todo List
- [x] Shared provider constants added
- [x] `create` accepts and validates `--ci-provider`
- [x] `init` accepts and validates `--ci-provider`
- [x] `.info/agentic.yaml` persists `ci_provider`
- [x] Brick input includes `ci_provider`
- [x] Legacy missing-field fallback documented in code comments/tests

## Success Criteria
- New project config includes `ci_provider: github|gitlab`.
- Invalid provider values fail before generation begins.
- Existing projects without the field still resolve to a usable provider path.
- No second deploy selection surface is introduced.

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Missing-field legacy projects break deploy | Medium | High | Add deterministic fallback: infer from files, then default to GitHub |
| Provider strings drift across commands/tests/templates | Medium | Medium | Centralize allowed values/constants |
| `create` and `init` diverge in defaults | Low | Medium | Route both through the same parser/helper |

## Security Considerations
- Provider choice is non-secret metadata and safe for `.info/agentic.yaml`.
- Do not store provider tokens or secrets in config; docs must continue pointing to CI variables/secrets.

## Test Matrix
- **Unit**: provider normalization, invalid input rejection, config persistence, legacy fallback resolution.
- **Integration**: init/create flows write the correct provider field in temp directories.

## Rollback Plan
- Remove `--ci-provider` flags and `ci_provider` field handling.
- Keep GitHub as the implicit default so existing workflows continue unchanged.

## Next Steps
- Phase 02 consumes `ci_provider` to emit provider-exclusive templates and route deploy behavior.

## Unresolved Questions
- None. V1 keeps the default contract simple: omitted provider resolves to `github`.
