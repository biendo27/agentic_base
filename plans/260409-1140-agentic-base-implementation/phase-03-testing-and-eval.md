# Phase 3 — Testing & Eval (v0.3.0)

## Context Links
- [Architecture Report](../reports/brainstorm-260409-1103-agentic-base-architecture.md) — Section 8
- [Phase 2](./phase-02-feature-and-module-system.md)

## Overview
- **Priority**: P2
- **Status**: Pending
- **Effort**: 15h
- **Depends on**: Phase 2

Build `eval` command that runs tests per feature or all. Add spec.yaml parsing, test stub generation from specs, coverage reporting, and golden test (alchemist) setup in generated projects.

## Requirements

### Functional
- `agentic_base eval [feature]` runs tests for specific feature or all
- `agentic_base eval --coverage` generates coverage report
- spec.yaml parsed for acceptance criteria + edge cases
- Test stubs auto-generated from spec.yaml when feature is created
- Generated project includes alchemist golden test config
- Generated project includes patrol integration test setup

### Non-Functional
- Eval completes in reasonable time (depends on test count)
- Coverage report generates HTML output

## Related Code Files

### Files to Create
- `lib/src/cli/commands/eval_command.dart`
- `lib/src/generators/test_generator.dart` — generates test stubs from spec.yaml
- `lib/src/config/spec_parser.dart` — parses feature.spec.yaml files

### Files to Update
- Feature generator → include spec.yaml-based test stub generation
- agentic_app brick → add alchemist config, golden_helper, patrol setup

### Tests
- `test/src/cli/commands/eval_command_test.dart`
- `test/src/generators/test_generator_test.dart`
- `test/src/config/spec_parser_test.dart`

## Implementation Steps

### Step 1: Spec Parser
1. Create `spec_parser.dart` — reads YAML spec files
2. Extract: feature name, description, acceptance_criteria[], edge_cases[]
3. Validate spec format
4. Write tests

### Step 2: Test Generator
1. Create `test_generator.dart`
2. From spec, generate:
   - Unit test stubs (cubit state transitions from acceptance criteria)
   - Widget test stubs (page rendering)
   - Golden test stubs (alchemist snapshot)
3. Template: test names from acceptance criteria text
4. Write tests

### Step 3: Update Feature Brick
1. Add spec.yaml template to feature brick
2. Post-generation: call test_generator to create test stubs
3. Add alchemist config to generated project:
   - `test/helpers/golden_helper.dart` — alchemist GoldenTestGroup config
   - `test/goldens/.gitkeep`

### Step 4: Eval Command
1. Create `eval_command.dart`
2. `eval [feature]` — find test files for feature, run `flutter test test/features/<feature>/`
3. `eval --all` — run `flutter test`
4. `eval --coverage` — run with `--coverage` flag, generate lcov report
5. Display pass/fail summary with colors
6. Write tests

### Step 5: Patrol Setup
1. Add patrol config to generated project:
   - `integration_test/app_test.dart` — basic flow test
   - `patrol_test/` directory structure
2. Add patrol dependency to generated pubspec.yaml (dev_dependencies)
3. Document in testing-guide.md

## Todo List
- [ ] Spec parser (YAML → acceptance criteria + edge cases)
- [ ] Test generator (spec → unit/widget/golden test stubs)
- [ ] Update feature brick with spec.yaml + auto test generation
- [ ] Alchemist golden test setup in generated project
- [ ] Patrol integration test setup
- [ ] Eval command (feature, --all, --coverage)
- [ ] Update docs/06-testing-guide.md template

## Success Criteria
- [ ] `agentic_base feature auth` generates spec.yaml + test stubs
- [ ] `agentic_base eval auth` runs only auth tests
- [ ] `agentic_base eval --coverage` generates coverage report
- [ ] Generated test stubs are meaningful (not just empty `test()` blocks)
- [ ] Alchemist golden tests configured and runnable
- [ ] Patrol setup included but optional

## Risk Assessment
| Risk | Impact | Mitigation |
|------|--------|------------|
| Alchemist API changes | Golden tests break | Pin version, test in CI |
| Patrol native setup complexity | Users can't run | Make patrol optional, document setup |
| Spec parsing edge cases | Bad test generation | Validate spec format strictly |

## Next Steps
→ Phase 4: CI/CD & Deploy (can start in parallel with Phase 3 late stages)
