# Phase 01: Implement Harness Manifest And Contract Validators

## Context Links

- [Plan overview](./plan.md)
- [Harness Contract V1](../../docs/08-harness-contract-v1.md)
- [Manifest schema](../../docs/10-manifest-schema.md)
- [Code standards](../../docs/03-code-standards.md)

## Overview

- Priority: P0
- Status: Completed
- Goal: make the generator read, write, and validate the additive `harness` manifest section without breaking existing repos.

## Key Insights

- `.info/agentic.yaml` is already the machine-readable source of truth.
- The new contract is additive; existing metadata fields must remain compatible.
- The validator layer must reject drift instead of allowing docs to outrun implementation again.

## Requirements

- Extend project metadata and config handling to support the `harness` section.
- Keep `.info/agentic.yaml` as the only machine-readable source of truth.
- Implement validator rules for supported profiles, provider/capability consistency, approval fields, and SDK policy shape.
- Avoid claiming Harness Contract V1 for repos that do not yet have validated `harness` data.

## Architecture

- `ProjectMetadata` should own typed harness metadata or a typed nested submodel.
- `AgenticConfig` should round-trip new harness fields without destructive rewrites.
- `GeneratedProjectContract` should validate:
  - contract version presence
  - supported profile names
  - provider/capability consistency
  - required harness sub-sections
  - drift between derived values and stored read-model fields, if any exist

## Related Code Files

- Modify:
  - `/Users/biendh/base/lib/src/config/project_metadata.dart`
  - `/Users/biendh/base/lib/src/config/agentic_config.dart`
  - `/Users/biendh/base/lib/src/config/agent_ready_repo_contract.dart`
  - `/Users/biendh/base/lib/src/generators/generated_project_contract.dart`
  - `/Users/biendh/base/test/src/config/agentic_config_test.dart`
  - `/Users/biendh/base/test/src/config/project_metadata_test.dart`
  - `/Users/biendh/base/test/src/generators/project_generator_test.dart`
- Create:
  - `/Users/biendh/base/test/src/config/project_metadata_test.dart`
- Delete:
  - None expected

## Implementation Steps

1. Introduce typed harness metadata models or equivalent typed config helpers.
2. Extend config read/write paths to preserve harness fields.
3. Add `buildAgentReadyConfigMap()` support for the new harness contract structure.
4. Extend generated project validation with manifest-schema rules.
5. Add unit coverage for valid, missing, and invalid harness manifests.

## Todo List

- [x] Add typed harness metadata support
- [x] Extend config read/write
- [x] Extend generator-owned config map output
- [x] Add manifest validation rules
- [x] Add config and validator unit tests

## Success Criteria

- The generator can write a valid harness section into `.info/agentic.yaml`.
- Invalid harness manifests fail clearly.
- Existing repos without harness fields remain readable and non-destructively upgradeable.

## Risk Assessment

- Risk: metadata modeling becomes too complex and brittle.
- Mitigation: keep the harness model additive, typed, and minimal.

## Security Considerations

- Validators must reject obvious credential-like fields in manifest sections that should stay declarative.
- No secrets should ever be written into the harness manifest.

## Next Steps

- Completed. Phase 02 wires profile semantics into generation, retrofit, and generated docs.
