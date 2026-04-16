# Scout Report

## Summary

Local scouting confirms that the next plan must target a small set of hot surfaces, not the whole repo. The critical cluster is command execution + generator + bricks + smoke suite.

## Findings

### Runtime honesty cluster

- `lib/src/cli/commands/create_command.dart`
- `lib/src/cli/commands/init_command.dart`
- `lib/src/cli/commands/add_command.dart`
- `lib/src/cli/commands/remove_command.dart`
- `lib/src/cli/commands/gen_command.dart`
- `lib/src/cli/commands/upgrade_command.dart`
- `lib/src/config/flutter_sdk_contract.dart`
- `lib/src/generators/project_generator.dart`

Why this cluster matters:

- these files decide whether the declared toolchain contract is real or decorative
- they also shape test runtime because they own the heavy subprocess pipeline

### Generated app contract cluster

- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/pubspec.yaml`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/test`

Observed issues:

- theme is still seed-based and hard-coded around a narrow token set
- `intl: any` remains in the generated pubspec
- starter app flow is one-screen and router/module wiring is minimal
- generated tests prove boot, not rich seam behavior

### Feature brick cluster

- `bricks/agentic_feature/__brick__`
- `lib/src/cli/commands/feature_command.dart`
- `lib/src/generators/feature_generator.dart`
- `lib/src/config/spec_parser.dart`
- `lib/src/generators/test_generator.dart`

Observed issues:

- feature spec files exist, but the production feature flow does not fully consume them
- generated feature files still rely on tuple-style repository/use-case results
- `library` + `part` can only help selectively here; broad use would make generated features harder to navigate

### Test-speed cluster

- `test/integration/generated_app_smoke_test.dart`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/verify.sh`
- `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/tools/_common.sh`

Observed issues:

- integration tests repeatedly perform full real project generation
- downstream verify runs static analysis, full test suite, app-shell smoke, and native readiness
- this is good for confidence, but too much of it is duplicated across permutations

## Recommended Sequencing

1. Runtime honesty and command execution.
2. Shared contracts and feature/app brick structure.
3. Theme/token refresh.
4. Starter flow and feature wiring.
5. Verification depth.
6. Test-speed optimization.
7. Docs refresh.

## Resolution Note

No unresolved planning questions remain. The remaining fixture-reuse topic is an implementation-time measurement concern, not a plan blocker.
