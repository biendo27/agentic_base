# AGENTS.md

Thin adapter for coding agents working in `{{project_name.titleCase()}}`.

## Start Here

- Machine contract: `.info/agentic.yaml`
- Harness Contract: `v1`
- Primary profile: `{{app_profile}}` ({{app_profile_label}})
- Support tier: `{{support_tier_label}}`
- Evidence directory: `{{{evidence_dir}}}`
- Declared Flutter toolchain: `{{flutter_sdk_manager}}` / `{{flutter_sdk_channel}}` / `{{flutter_sdk_version}}`
- Canonical context:
  - `README.md`
  - `docs/01-architecture.md`
  - `docs/02-coding-standards.md`
  - `docs/03-state-management.md`
  - `docs/04-network-layer.md`
  - `docs/05-theming-guide.md`
  - `docs/06-testing-guide.md`
- If this file conflicts with `README.md` or `docs/`, follow `README.md` and `docs/`.

## Deterministic Commands

```bash
./tools/setup.sh
./tools/run-dev.sh
./tools/verify.sh
./tools/build.sh <dev|staging|prod> [apk|appbundle|ipa|all]
./tools/release-preflight.sh <dev|staging|prod> <firebase|testflight|play-internal|play-production|app-store>
./tools/release.sh <dev|staging|prod> <firebase|testflight|play-internal|play-production|app-store>
```

## Guardrails

- Generator-owned surfaces: `AGENTS.md`, `CLAUDE.md`, `README.md`, `docs/`, `tools/`, CI files, Fastlane files
- Human-owned surfaces: feature code, secrets, non-example env files, store credentials
- `./tools/verify.sh` and `./tools/release-preflight.sh` write inspectable evidence to `{{{evidence_dir}}}`
- Human approval is required before any final production store publish
