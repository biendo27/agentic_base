# Scout Report

## Summary

The key implementation surfaces for Harness Contract V1 already exist but stop short of the approved design.

## Relevant Existing Files

- `lib/src/config/agentic_config.dart`
- `lib/src/config/project_metadata.dart`
- `lib/src/config/agent_ready_repo_contract.dart`
- `lib/src/generators/generated_project_contract.dart`
- `lib/src/generators/project_generator.dart`
- `lib/src/cli/commands/doctor_command.dart`
- `lib/src/cli/commands/upgrade_command.dart`
- generated repo scripts under `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/`
- generated repo docs/adapters under the same brick
- `test/src/config/**`
- `test/src/cli/commands/**`
- `test/src/generators/**`
- `test/integration/generated_app_smoke_test.dart`

## Gap Summary

- no `harness:` section in current manifest implementation
- no profile/tier encoding in generated repos
- no canonical evidence bundle generation
- no machine-readable approval-state outputs
- no Puro support and only shallow FVM visibility in `doctor`
- no tested-version enforcement in `upgrade`

## Planning Implication

The next plan should not start from docs again. It should convert these specific gaps into code and regression tests.

## Unresolved Questions

- None beyond implementation detail tradeoffs.

