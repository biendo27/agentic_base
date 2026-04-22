# Phase 03: Generated CI/CD Contract Hardening

## Context Links

- [Plan](./plan.md)
- [Research: Generated CI/CD And Native Runtime](./research/researcher-02-generated-cicd-native-runtime-report.md)
- Generated GitHub workflows: `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.github/workflows/*.yml`
- Generated GitLab CI: `bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab*`
- Contract validator: [`generated_project_contract.dart`](../../lib/src/generators/generated_project_contract.dart)
- Create prompts: [`prompts.dart`](../../lib/src/tui/prompts.dart)

## Overview

Priority: P0. Status: Completed.

Make generated CI/CD honest and render-safe. Interactive create must ask CI provider. Rendered workflows must not contain unresolved Mason tokens. PR CI must not build prod without real prod env.

## Key Insights

- Workflow templates reset Mason delimiters to `<% %>` but still use `{{flutter_sdk_channel}}`, `{{flutter_sdk_version}}`, and `{{evidence_dir}}`.
- Generated `ci.yml` builds `prod`, while `tools/build.sh` correctly refuses `env/prod.env.example`.
- `--ci-provider` exists but interactive create silently uses default.

## Requirements

- Functional:
  - Prompt `github` vs `gitlab` during interactive `create` when `--ci-provider` is omitted.
  - Keep `--no-interactive` default as `github`.
  - Render all generated CI variables with the active Mason delimiter.
  - Add contract test that fresh generated workflows contain no unresolved `{{...}}` tokens except valid GitHub expressions.
  - Change generated GitHub PR CI to build `dev` and `staging` only.
  - Move prod build/release proof to release/manual/protected lanes with real env/secrets.
  - Keep evidence upload stable.
- Non-functional:
  - Do not duplicate release logic outside `tools/*.sh`.
  - Generated CI must remain readable for humans.

## Architecture

Generated project gates:

| Surface | Trigger | Purpose |
| --- | --- | --- |
| `ci.yml` | PR to `main/develop`, push to `develop` | verify + credentialless dev/staging debug build |
| `cd-dev.yml` | push to `develop` or manual | dev distribution when secrets configured |
| `cd-staging.yml` | manual | protected staging deploy |
| `cd-prod.yml` | manual | protected production deploy |
| `release.yml` | tag | release artifact build/preflight |

## Related Code Files

- Modify `/Users/biendh/base/lib/src/cli/commands/create_command.dart`.
- Modify `/Users/biendh/base/lib/src/tui/prompts.dart`.
- Modify `/Users/biendh/base/test/src/cli/commands/create_command_test.dart`.
- Modify `/Users/biendh/base/test/src/tui/prompts_test.dart`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.github/workflows/*.yml`.
- Modify `/Users/biendh/base/bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab/ci/*.yml` if evidence paths are still unresolved.
- Modify `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`.
- Modify `/Users/biendh/base/test/src/generators/project_generator_test.dart`.
- Modify `/Users/biendh/base/test/integration/generated_app_smoke_test.dart` if generated workflow assertions live there.

## Implementation Steps

1. Add `CreatePrompts.promptCiProvider(defaultValue)` returning `CiProvider`.
2. In interactive create, prompt for CI provider when flag is not parsed.
3. Preserve non-interactive behavior: omitted provider resolves to `github`.
4. Replace CI template variables after delimiter reset:
   - `{{flutter_sdk_channel}}` -> `<%flutter_sdk_channel%>`
   - `{{flutter_sdk_version}}` -> `<%flutter_sdk_version%>`
   - `{{evidence_dir}}` -> `<%evidence_dir%>`
5. Preserve GitHub runtime expressions `${{ ... }}` unchanged.
6. Change generated GitHub `ci.yml` build matrix from `[dev, staging, prod]` to `[dev, staging]`.
7. Ensure prod build appears only in `release.yml` / prod CD workflows.
8. Add `GeneratedProjectContract` scan:
   - fail on unresolved `{{[a-zA-Z_][^}]*}}`
   - ignore `${{ ... }}` GitHub expressions
   - scan GitHub/GitLab generated CI files for selected provider
9. Add tests for GitHub and GitLab generated output.
10. Run a fresh generated app smoke and verify rendered workflows.

## Todo List

- [x] Add interactive CI provider prompt.
- [x] Fix Mason delimiter usage in workflow templates.
- [x] Remove prod from credentialless PR build matrix.
- [x] Add unresolved-token contract validator.
- [x] Add GitHub/GitLab scaffold tests.
- [x] Update generated deployment docs.

## Success Criteria

- Interactive `agentic_base create my_app` asks for CI provider.
- `agentic_base create my_app --no-interactive` still persists `ci_provider: github`.
- Fresh generated GitHub workflows contain real channel/version/evidence path values.
- Fresh generated GitHub PR CI does not call `./tools/build.sh prod`.
- Contract tests fail if any generated CI file contains unresolved Mason variables.

## Risk Assessment

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Regex rejects valid GitHub expression | False failure | Ignore `${{` explicitly and test common expressions |
| Removing prod from PR CI hides prod failures | Release risk | Require prod in release/manual protected lanes with real env |
| Prompt breaks non-interactive scripts | Automation breakage | Prompt only when not `--no-interactive` and flag omitted |

## Security Considerations

- Do not add secrets.
- Keep prod deployment behind provider environment protections.
- Do not print secret env values in generated scripts or docs.

## Next Steps

Phase 04 fixes iOS runtime crash and strict lint policy.
