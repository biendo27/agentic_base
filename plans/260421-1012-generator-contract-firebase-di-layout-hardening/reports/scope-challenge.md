# Scope Challenge

## Existing Code

- Run contract exists but is hard-coded to `tools/run-dev.sh`.
- Flavor contract already uses `dev`, `staging`, `prod`.
- Module dependencies are centralized in `module_dependency_catalog.dart`, but freshness is manual.
- Module install and generated startup are centralized in `ModuleIntegrationGenerator`, but DI and startup are conflated.
- Firebase-backed modules already generate a runtime stub, but current behavior is not credential-safe enough.
- Generated `lib/core` already contains too many service/provider folders.

## Minimum Change Set

- Rename generated run contract to `tools/run.sh` and remove `run-dev.sh`.
- Keep canonical flavor names and accept `stg` only as CLI alias.
- Remove broken/dead `uni_links` dependency from deep-link module.
- Make Firebase-backed runtime no-op safely until setup is explicit.
- Add Firebase setup command/script for multi-flavor native and Dart options.
- Split module DI from startup; stop generating GetIt registrations beside injectable.
- Move new module services to `lib/services` and update tests/contracts.
- Add verification that generated app can run native Android/default profile without credentials.

## Complexity

- Expected to touch more than 8 files. This is justified because the contract spans CLI, brick, modules, tests, docs, and generated validation.
- New abstractions are justified only if they remove current heuristics: dependency refresh policy, Firebase setup orchestration, module startup metadata.
- Scope mode: HOLD SCOPE. The user asked for all identified issues; no expansion beyond these seams.

## Not In Scope

- Full redesign of generated UI.
- Store signing, real Firebase project creation, or production credential provisioning.
- Live package lookup during every end-user module install without a verified fallback.

