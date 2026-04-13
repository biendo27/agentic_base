# CLAUDE.md

Thin Claude adapter for `{{project_name.titleCase()}}`.

## Source Of Truth

- Machine contract: `.info/agentic.yaml`
- Human-readable context: `README.md` plus `docs/01-06`
- State runtime: `{{state_display_name}}`
- CI provider: `{{ci_provider}}`

## Commands

- `./tools/setup.sh`
- `./tools/run-dev.sh`
- `./tools/verify.sh`
- `./tools/build.sh <dev|staging|prod> [apk|appbundle|ipa|all]`
- `./tools/release-preflight.sh <dev|staging|prod> <target>`
- `./tools/release.sh <dev|staging|prod> <target>`

## Boundaries

- never edit generated files such as `*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`
- never commit secrets or non-example env files
- final store publish stays human-approved even when uploads are automated
