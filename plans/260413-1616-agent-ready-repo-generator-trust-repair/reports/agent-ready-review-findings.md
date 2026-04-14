# Agent-Ready Review Findings Snapshot

## Context

User-requested brutal review on 2026-04-13 against the target architecture "generator for agent-ready repos". This file is the evidence anchor for the corrective plan in this directory.

## Findings

### P0 — `init` emits a false machine contract

- `.info/agentic.yaml` claims canonical docs plus `setup/run/verify/build/release-preflight/release` surfaces that `init` does not actually generate.
- Violates product honesty, canonical context split, deterministic harness, and human-boundary clarity.
- Refs:
  - [`lib/src/config/agent_ready_repo_contract.dart`](../../../lib/src/config/agent_ready_repo_contract.dart)
  - [`lib/src/config/agentic_config.dart`](../../../lib/src/config/agentic_config.dart)
  - [`lib/src/cli/commands/init_command.dart`](../../../lib/src/cli/commands/init_command.dart)
  - [`README.md`](../../../README.md)

### P0 — GitLab deploy wrapper is broken after generation

- `DeployCoordinator` targets `deploy_$environment`, but generated GitLab jobs are platform-specific names such as `deploy_staging_testflight`.
- Violates release honesty because the wrapper cannot hit a real manual job reliably.
- Refs:
  - [`lib/src/deploy/deploy_coordinator.dart`](../../../lib/src/deploy/deploy_coordinator.dart)
  - [`lib/src/generators/generated_project_contract.dart`](../../../lib/src/generators/generated_project_contract.dart)
  - [`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab/ci/deploy.yml`](../../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/.gitlab/ci/deploy.yml)

### P1 — Module installs are non-deterministic

- `ModuleInstaller` defaults dependency constraints to `any`, and tests assert that output as acceptable.
- Violates deterministic execution and undermines reproducibility.
- Refs:
  - [`lib/src/modules/module_installer.dart`](../../../lib/src/modules/module_installer.dart)
  - [`test/src/cli/commands/add_command_test.dart`](../../../test/src/cli/commands/add_command_test.dart)

### P1 — Firebase runtime integration is partial on default supported platforms

- Default generated platforms include `web`, but Firebase bootstrap only calls `Firebase.initializeApp()` with no explicit options strategy.
- Misleads generated repos into claiming a runtime integration they cannot prove.
- Refs:
  - [`lib/src/config/project_metadata.dart`](../../../lib/src/config/project_metadata.dart)
  - [`lib/src/modules/firebase_runtime_template.dart`](../../../lib/src/modules/firebase_runtime_template.dart)

### P2 — Some installed modules remain partial file drops

- Startup-bound modules such as notifications and remote config still rely on manual app-start steps that the generator does not own.
- Violates the rule that installable modules must be working runtime integrations, not inert scaffolds.
- Refs:
  - [`lib/src/modules/extended/notifications_module.dart`](../../../lib/src/modules/extended/notifications_module.dart)
  - [`lib/src/modules/extended/remote_config_module.dart`](../../../lib/src/modules/extended/remote_config_module.dart)
  - [`lib/src/modules/module_integration_generator.dart`](../../../lib/src/modules/module_integration_generator.dart)
  - [`bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/bootstrap.dart`](../../../bricks/agentic_app/__brick__/{{project_name.snakeCase()}}/lib/app/bootstrap.dart)

### P3 — Docs drift still exists at the package root

- README links a missing architecture review doc and understates what `upgrade` rewrites.
- Violates product honesty, though lower severity than the contract/runtime failures above.
- Refs:
  - [`README.md`](../../../README.md)
  - [`lib/src/cli/commands/upgrade_command.dart`](../../../lib/src/cli/commands/upgrade_command.dart)

## Verdict

The repo is not yet at the "agent-ready repo generator" bar. The top blocker is broken trust in the canonical machine contract and release surfaces. Until those are repaired and guarded by regression tests, docs alone cannot make the product honest.
