# CLAUDE.md

Thin Claude adapter for `{{project_name.titleCase()}}`.

## Source Of Truth

- Machine contract: `.info/agentic.yaml`
- Harness Contract: `v1`
- Primary profile: `{{app_profile}}` ({{app_profile_label}})
- Support tier: `{{support_tier_label}}`
- Evidence directory: `{{{evidence_dir}}}`
- Declared Flutter toolchain: `{{flutter_sdk_manager}}` / `{{flutter_sdk_channel}}` / `{{flutter_sdk_version}}`
- Human-readable context: `README.md` plus `docs/01-07`
- State runtime: `{{state_display_name}}`
- CI provider: `{{ci_provider}}`

## Commands

- `./tools/setup.sh`
- `./tools/run-dev.sh`
- `./tools/test.sh`
- `./tools/verify.sh`
- `./tools/build.sh <dev|staging|prod> [apk|appbundle|ipa|all]`
- `./tools/release-preflight.sh <dev|staging|prod> <target>`
- `./tools/release.sh <dev|staging|prod> <target>`

## Recommended Default Gitflow

Recommended default Gitflow:

- `feature/*` -> `develop`
- `release/*` -> `main`
- `hotfix/*` -> `main`

See `docs/07-agentic-development-flow.md` for the full workflow and back-merge rule.

## Boundaries

- never edit generated files such as `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`
- never commit secrets or non-example env files
- inspect `{{{evidence_dir}}}` before claiming that verify or release-preflight passed
- final store publish stays human-approved even when uploads are automated
