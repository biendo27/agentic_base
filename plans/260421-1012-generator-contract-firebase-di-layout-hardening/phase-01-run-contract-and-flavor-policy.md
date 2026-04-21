# Phase 01: Run Contract And Flavor Policy

## Context Links

- Research: [Run, Flavor, Dependency Report](./research/researcher-run-flavor-dependency-report.md)
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/run-dev.sh`
- `/Users/biendh/base/lib/src/config/agent_ready_repo_contract.dart`
- `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`
- `/Users/biendh/base/lib/src/cli/commands/create_command.dart`

## Overview

Priority: P1. Status: Complete.

Replace the generated `run-dev.sh` contract with `run.sh`, keep `dev/staging/prod` canonical, and support `stg` only as an operator alias.

## Key Insights

- Current generated app can only run dev through `tools/run-dev.sh`.
- `staging` is already the generated `main_staging.dart` and env file name.
- Keeping a `run-dev.sh` wrapper preserves compatibility but keeps the contract noisier. Hard cut is better now.

## Requirements

- `./tools/run.sh` defaults to `dev`.
- Supported inputs: `dev`, `staging`, `stg`, `prod`.
- `stg` maps to `staging` internally and never appears in `.info/agentic.yaml`.
- Script chooses `lib/main_<flavor>.dart`.
- Script chooses `env/<flavor>.env` if present, else `env/<flavor>.env.example` with warning.
- If first arg is `dev|staging|stg|prod`, normalize and `shift`; otherwise default to `dev` and forward all args to Flutter.
- Unknown flavor-like first args fail with usage text.
- Tests cover `./tools/run.sh -d <id>` and `./tools/run.sh staging -d <id>`.
- Remove generated `tools/run-dev.sh`.
- Update all docs, Makefile, next-step output, manifest execution contract, and generated validator checks.
- Build/release-preflight must fail for prod when `env/prod.env` is absent.

## Architecture

```text
operator -> tools/run.sh [flavor alias] -> normalize flavor -> flutter run
                                              |-> target lib/main_<flavor>.dart
                                              |-> dart-define env/<flavor>.env(.example)
```

## Related Code Files

- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/run-dev.sh` -> replace with `tools/run.sh`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/Makefile`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/AGENTS.md`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/CLAUDE.md`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/01-architecture.md`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/setup.sh`.
- Modify `/Users/biendh/base/lib/src/config/agent_ready_repo_contract.dart`.
- Modify `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`.
- Modify `/Users/biendh/base/lib/src/cli/commands/create_command.dart`.
- Modify `/Users/biendh/base/test/src/generators/project_generator_test.dart`.
- Modify `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`.

## Implementation Steps

1. Add `tools/run.sh` template with flavor normalization and env file fallback.
2. Delete generated `tools/run-dev.sh` from the brick.
3. Update Makefile target to `run` or keep `run-dev` only if tests prove a make alias is valuable. Preferred: `make run FLAVOR=staging`.
4. Update `.info.execution.run` default to `./tools/run.sh`.
5. Update CLI next steps to print `./tools/run.sh`.
6. Update contract validator required script list.
7. Update generated README/docs/adapters.
8. Add tests for default dev, `staging`, `stg`, and `prod` command composition.

## Todo List

- [x] Create `tools/run.sh` template.
- [x] Remove `tools/run-dev.sh` template and contract references.
- [x] Update generated manifest execution contract.
- [x] Update docs and Makefile.
- [x] Update tests and validator.
- [x] Add argument parser regression tests for default, explicit flavor, alias, and forwarded device args.

## Success Criteria

- Generated app contains `tools/run.sh` and does not contain `tools/run-dev.sh`.
- `./tools/run.sh`, `./tools/run.sh staging`, `./tools/run.sh stg`, and `./tools/run.sh prod` build the correct command.
- `./tools/run.sh staging -d emulator-id` forwards only `-d emulator-id` to Flutter after flavor selection.
- `.info/agentic.yaml` lists `run: ./tools/run.sh`.
- No stale `run-dev.sh` references remain outside historical plans.
- Prod build/release-preflight does not use `env/prod.env.example` silently.

## Risk Assessment

- High stale-string risk because docs, validator, tests, and templates all mention `run-dev.sh`.
- Keep the alias in script input only; do not add a fourth flavor.

## Security Considerations

- Prod run should not silently use `.env.example` for release paths. For `flutter run`, fallback is acceptable with warning; for build/release, enforce real env in a later phase if needed.

## Next Steps

Phase 02 depends on this only for docs and generated validation flow, not for code architecture.
