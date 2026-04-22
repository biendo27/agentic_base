# Agentic Development Flow

## Start Here

The Harness Engineer loop starts from one finite context surface:

- machine contract: `.info/agentic.yaml`
- entrypoint docs: `README.md` plus `docs/01-07`
- thin adapters: `AGENTS.md`, `CLAUDE.md`

If those surfaces drift, follow `README.md` and `docs/`.

## Harness Engineer Loop

1. Read the change request, then confirm the declared profile, CI provider, state runtime, and toolchain in `.info/agentic.yaml`.
2. Read only the docs needed for the task:
   - architecture: `docs/01-architecture.md`
   - coding rules: `docs/02-coding-standards.md`
   - state runtime: `docs/03-state-management.md`
   - network/contracts: `docs/04-network-layer.md`
   - testing: `docs/06-testing-guide.md`
3. Edit generator-owned or app-owned files according to the ownership boundary.
4. Run `./tools/test.sh` for focused checks while iterating.
5. Run `./tools/verify.sh` before claiming a change is ready.
6. Run `./tools/inspect-evidence.sh verify` before summarizing verify or release-preflight results.
7. Inspect `{{{evidence_dir}}}` directly only when debugging the raw bundle files.
8. Run `./tools/release-preflight.sh <flavor> <target>` before any upload-oriented release work.
9. Stop at human pauses for product decisions, credential setup, and final production publish.

## Ownership Boundary

Generator-owned surfaces include:

- `README.md`
- `docs/`
- `AGENTS.md`
- `CLAUDE.md`
- `tools/`
- CI wrappers and Fastlane files

Human-owned surfaces include:

- feature code under `lib/features/`
- reusable app code under `lib/shared/`
- secrets and non-example env files
- store credentials and signing material

## Verification Loop

Use the wrapper surfaces in this order:

1. `./tools/test.sh` for local focused checks
2. `./tools/verify.sh` for the pre-review gate
3. `./tools/inspect-evidence.sh` for the latest derived run report
4. `./tools/release-preflight.sh` before any upload-oriented release work

The wrapper scripts stay manager-aware. They resolve the declared Flutter runtime from `.info/agentic.yaml` instead of assuming one local toolchain layout.
`inspect-evidence.sh` stays local-first and reads the existing bundle files instead of requiring a hosted console.
Use `./tools/lint.sh --strict` for fatal-info analysis. Default verify keeps normal analyzer strictness so Flutter/lint-version info churn does not block every local loop.

## CI/CD Boundary

Generated GitHub PR CI verifies the app and builds credentialless `dev` and `staging` artifacts only. Production builds require `env/prod.env` and run through release or production deploy workflows with protected environments and real credentials.

GitLab deploy jobs are manual and should be attached to protected environments in project settings. Native validation requires a macOS runner with Xcode; Linux runners do not satisfy the iOS/native gate.

The iOS simulator native-readiness gate does not prove physical-device signing. A physical iPhone run still requires an Apple signing team, provisioning profile, and device UDID managed outside this scaffold.

## Human Approval Boundary

Agents may prepare builds and uploads, but they must stop for:

- `product-decisions`
- `credential-setup`
- `final-store-publish-approval`

`./tools/release.sh` does not remove the final production publish approval step.

## Recommended Default Gitflow

Recommended default Gitflow for teams that want one shared branch model:

- `feature/*` -> `develop`
- `release/*` -> `main`
- `hotfix/*` -> `main`
- back-merge `release/*` and `hotfix/*` into `develop` after production promotion

This workflow is recommended default guidance, not part of `.info/agentic.yaml`.
