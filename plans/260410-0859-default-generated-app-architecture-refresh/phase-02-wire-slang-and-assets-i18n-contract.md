# Phase 02 - Wire Slang And Assets I18n Contract

## Context Links

- Brick files: `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/build.yaml`, `pubspec.yaml`, `tools/gen.sh`, `tools/setup.sh`
- Current drift: `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/l10n/strings_en.i18n.yaml`, `my_app/l10n/strings_en.i18n.yaml`
- Runtime files: `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/app.dart`, `lib/features/home/**`
- Research: `./research/current-state-and-tooling-contracts.md`

## Overview

- Priority: P1
- Status: completed
- Effort: 6h
- Blocked by: phase 01
- File ownership for this phase:
  - Brick `pubspec.yaml`, `build.yaml`, i18n assets, starter runtime wiring, codegen scripts/docs

## Key Insights

- Today the template ships one YAML file under `l10n/` and no Slang wiring.
- Approved direction is strict: source translations centralized under `assets/i18n`, split by module, no `slang.yaml`, generated code under `lib/app/i18n`.
- The starter app must use the generated translations on day 0, otherwise the contract will rot.

## Requirements

- Add Slang dependencies and builder config using `build.yaml` only.
- Replace `l10n/` with `assets/i18n/<module>/...` source files.
- Generate typed localization code into `lib/app/i18n`.
- Keep translation files centralized; no feature-local deep translation folders.
- Prove the chosen module-split layout with at least two modules and two locales before freezing it as the contract.
- Extend feature scaffolding so newly generated features can create module i18n stubs in the same contract.
- Update docs and scripts so `build_runner` remains the single entrypoint for codegen.

## Architecture

### Data Flow

- Input: YAML translation assets under `assets/i18n/<module>/`.
- Transform:
  1. `build_runner` invokes Slang and existing builders from `build.yaml`.
  2. Slang aggregates module translation assets.
  3. Generated Dart lands in `lib/app/i18n`.
  4. `App` and starter UI read typed translations from generated code.
- Output: generated app with centralized source translations and typed runtime access.

### Asset Contract

- Proposed starter layout:
  - `assets/i18n/app/en.i18n.yaml`
  - `assets/i18n/home/en.i18n.yaml`
  - `assets/i18n/app/vi.i18n.yaml`
  - `assets/i18n/home/vi.i18n.yaml`
- Generated output:
  - `lib/app/i18n/*.g.dart`
  - optional wrapper/helper under `lib/app/i18n/` if needed for bootstrap ergonomics

## Related Code Files

- Modify:
  - `lib/src/generators/feature_generator.dart`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/pubspec.yaml`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/build.yaml`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/AGENTS.md`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/CLAUDE.md`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/gen.sh`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/setup.sh`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/app.dart`
  - starter home feature files under `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/**`
  - `bricks/agentic_feature/brick.yaml`
  - `bricks/agentic_feature/__brick__/**`
- Create:
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/assets/i18n/app/en.i18n.yaml`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/assets/i18n/home/en.i18n.yaml`
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/i18n/` helpers if needed
- Delete:
  - `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/l10n/strings_en.i18n.yaml`

## Implementation Steps

1. Add `slang` and `slang_flutter` dependencies and extend `build.yaml` without breaking `json_serializable`.
2. Prove the module-split layout with two locales and fail on collisions or missing defaults before freezing the path contract.
3. Move starter strings from legacy `l10n` into module-split assets under `assets/i18n`.
4. Wire the generated translations into `App` and the starter home surface.
5. Extend feature scaffolding so a new feature can generate its own `assets/i18n/<feature>/` starter files without deep colocated folders.
6. Update setup/gen scripts, README, AGENTS, and CLAUDE so they point to `build_runner` and the new paths.
7. Remove all generated-doc references to `lib/l10n`.

## Todo List

- [ ] Add Slang deps
- [ ] Extend `build.yaml` only
- [ ] Prove module-split contract with two locales
- [ ] Create centralized asset tree
- [ ] Wire starter runtime to generated translations
- [ ] Extend feature scaffolder to emit module i18n stubs
- [ ] Remove old `l10n/` contract from docs

## Success Criteria

- `dart run build_runner build --delete-conflicting-outputs` generates code under `lib/app/i18n`.
- No `slang.yaml` exists anywhere in the template.
- No `l10n/` directory remains in the generated app contract.
- Starter app renders at least app name and home strings from typed translations.
- Fresh generated feature scaffolding can follow the same `assets/i18n/<feature>` rule.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| Slang output path collides with existing generated files | Medium | Medium | Use explicit builder output path and cover with smoke test |
| Assets not registered, runtime misses translations | Medium | High | Add `pubspec.yaml` asset entry and run generated-app smoke test |
| Team later reintroduces feature-local translations | Medium | Medium | Document centralized contract in README and generated AI guides |

## Security Considerations

- Translation assets must contain public UI strings only.
- Do not store environment values or secrets in i18n YAML.
- Keep generated localization code deterministic; never hand-edit generated files.

## Rollback

- Restore the legacy `l10n` file and remove Slang wiring if codegen blocks the refresh.
- Keep phase-1 ownership checks intact while reverting i18n only.

## Next Steps

- Phase 03 consumes the new env + launch contract alongside the i18n-aware starter app.
- Phase 04 cleans the starter UI around the final i18n API.
