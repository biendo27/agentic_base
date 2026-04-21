# Researcher Report: Run Contract, Flavor Naming, Dependency Policy

## Scope

Investigated generated run-script contract, canonical flavor naming, and dependency freshness policy for `/Users/biendh/base`.

## Findings

- Replace `tools/run-dev.sh` with a hard `tools/run.sh` contract. Avoid a wrapper because this repo is still early enough to keep generated surfaces clean.
- Keep canonical flavor names `dev`, `staging`, `prod` everywhere. Accept `stg` only as a `tools/run.sh` alias and normalize it to `staging` before target/env selection.
- `GeneratedProjectContract` currently pins `tools/run-dev.sh` in required paths and README checks. One stale string will break generated-app verification.
- Dependency freshness should be "latest verified compatible", not live pub.dev lookup during normal module install. Live resolution makes generated apps time-dependent and weakens offline/deterministic harness behavior.
- `module_dependency_catalog.dart` remains useful as a checked-in release-time catalog, but it needs a verified refresh workflow and tests that do not duplicate hard-coded expected versions.

## Files To Cover

- `/Users/biendh/base/lib/src/config/agent_ready_repo_contract.dart`
- `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`
- `/Users/biendh/base/lib/src/cli/commands/create_command.dart`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/run-dev.sh`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/Makefile`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/AGENTS.md`
- `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/CLAUDE.md`
- `/Users/biendh/base/lib/src/modules/module_dependency_catalog.dart`
- `/Users/biendh/base/lib/src/modules/module_installer.dart`
- `/Users/biendh/base/test/src/generators/project_generator_test.dart`
- `/Users/biendh/base/test/integration/generated_app_smoke_test.dart`

## Risks

- Hard contract rename requires synchronized docs, tests, manifest defaults, and create-command next steps.
- Dependency catalog refresh must include full generated-app verification, otherwise "latest" means "latest unknown".
- If `stg` leaks into `.info/agentic.yaml`, CI, flavorizr, or native bundle IDs, agent reasoning becomes inconsistent.

**Status:** DONE_WITH_CONCERNS

