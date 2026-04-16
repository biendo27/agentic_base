# Scout Report

## Scope

Identify the concrete files and seams that the remediation plan must touch.

## Command Surface

- [lib/src/cli/commands/eval_command.dart](/Users/biendh/base/lib/src/cli/commands/eval_command.dart)
- [lib/src/cli/commands/doctor_command.dart](/Users/biendh/base/lib/src/cli/commands/doctor_command.dart)
- [lib/src/config/flutter_toolchain_runtime.dart](/Users/biendh/base/lib/src/config/flutter_toolchain_runtime.dart)
- [lib/src/cli/commands/add_command.dart](/Users/biendh/base/lib/src/cli/commands/add_command.dart)
- [lib/src/cli/commands/remove_command.dart](/Users/biendh/base/lib/src/cli/commands/remove_command.dart)
- [lib/src/cli/commands/gen_command.dart](/Users/biendh/base/lib/src/cli/commands/gen_command.dart)
- [lib/src/cli/commands/upgrade_command.dart](/Users/biendh/base/lib/src/cli/commands/upgrade_command.dart)
- [lib/src/cli/commands/brick_command.dart](/Users/biendh/base/lib/src/cli/commands/brick_command.dart)
- [lib/src/cli/commands/deploy_command.dart](/Users/biendh/base/lib/src/cli/commands/deploy_command.dart)

## Root Docs

- [README.md](/Users/biendh/base/README.md)
- [docs/02-codebase-summary.md](/Users/biendh/base/docs/02-codebase-summary.md)
- [docs/codebase-summary.md](/Users/biendh/base/docs/codebase-summary.md)
- [docs/05-project-roadmap.md](/Users/biendh/base/docs/05-project-roadmap.md)
- [docs/08-harness-contract-v1.md](/Users/biendh/base/docs/08-harness-contract-v1.md)
- [docs/09-support-tier-matrix.md](/Users/biendh/base/docs/09-support-tier-matrix.md)
- [docs/10-manifest-schema.md](/Users/biendh/base/docs/10-manifest-schema.md)
- [docs/11-eval-and-evidence-model.md](/Users/biendh/base/docs/11-eval-and-evidence-model.md)
- [docs/12-approval-state-machine.md](/Users/biendh/base/docs/12-approval-state-machine.md)
- [docs/13-flutter-adapter-boundaries.md](/Users/biendh/base/docs/13-flutter-adapter-boundaries.md)

## Generated App Docs

- [Generated README](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/README.md>)
- [Generated Architecture Doc](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/01-architecture.md>)
- [Generated Coding Standards](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/02-coding-standards.md>)
- [Generated State Management Doc](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/03-state-management.md>)
- [Generated Theming Guide](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/05-theming-guide.md>)
- [Generated Testing Guide](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/docs/06-testing-guide.md>)

## Generated App Runtime

- [lib/app/flavors.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/flavors.dart>)
- [lib/app/locale/app_locale_contract.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/locale/app_locale_contract.dart>)
- [lib/app/theme/app_theme_controller.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/theme/app_theme_controller.dart>)
- [lib/core/theme/app_theme.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/app_theme.dart>)
- [lib/core/theme/color_schemes.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/color_schemes.dart>)
- [lib/core/theme/component_themes.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/component_themes.dart>)
- [lib/core/theme/typography.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/theme/typography.dart>)
- [lib/core/error/failures.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/error/failures.dart>)
- [lib/core/contracts/app_response.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/app_response.dart>)
- [lib/core/contracts/pagination.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/core/contracts/pagination.dart>)
- [lib/features/home/presentation/pages/home_page.dart](</Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/features/home/presentation/pages/home_page.dart>)

## Verification

- [test/src/cli/commands](</Users/biendh/base/test/src/cli/commands>)
- [test/src/config](</Users/biendh/base/test/src/config>)
- [test/src/generators/project_generator_test.dart](/Users/biendh/base/test/src/generators/project_generator_test.dart)
- [test/integration/generated_app_smoke_test.dart](/Users/biendh/base/test/integration/generated_app_smoke_test.dart)

## Summary

The remediation wave touches both package CLI code and generated app template surfaces. This is one plan, but not one small refactor. Dry-run, docs taxonomy, and generated-app architecture must be treated as a coordinated contract rollout.
