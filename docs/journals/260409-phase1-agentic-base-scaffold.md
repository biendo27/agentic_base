# Phase 1 Complete: Agentic Base Dart CLI Scaffold

**Date**: 2026-04-09 14:15
**Severity**: Informational
**Component**: agentic_base Core Infrastructure
**Status**: Resolved

## What Happened

Completed Phase 1 of `agentic_base`: Dart CLI tool generating production Flutter codebases optimized for AI-agent-driven development. Tool outputs clean architecture projects with DI, state management, M3 theming, and agent-ready documentation.

## Technical Deliverables

**CLI Package** (8 Dart files, 0 warnings)
- `create` command: Mason brick orchestration with project generation
- `doctor` command: Dependency validation
- `gen` command: Generic brick invocation

**Mason Brick** (~65 template files)
- Generated project: 3-layer clean arch, Cubit state, auto_route v11, Dio, get_it/injectable
- M3 theme system: 19 component themes with Material You semantics
- Includes: AGENTS.md, CLAUDE.md, Makefile, 9 shell scripts, 6 markdown docs
- Output: Zero `dart analyze` errors, 3/3 tests pass, 11 build_runner outputs

## Critical Design Decisions

- **Version Pinning**: Updated all packages to latest stable (auto_route v11, bloc_test v10, get_it v9, very_good_analysis v10)
- **Freezed JSON Models**: Switched to per-class `@JsonSerializable()` annotations. Global `from_json/to_json` in build.yaml caused json_serializable failures on non-JSON freezed classes
- **Abstract vs Sealed**: freezed v3 requires `abstract class` for JSON models, `sealed class` for state classes — not interchangeable
- **Brick Nesting Fix**: Mason generates `{{project_name.snakeCase()}}/` root, generator outputs to parent directory to avoid double nesting

## Metrics

- Tool compilation: 0 errors, 0 analyzer warnings
- Generated project: 0 analysis errors post-build_runner
- Test suite: 3/3 passing
- Single-session delivery

## What Broke (And Why It Matters)

Initial Mason brick tried global JSON serialization config. Failed silently: state classes (sealed, non-JSON) inherited `@JsonSerializable()`, causing build_runner to skip codegen on valid models. Root cause: misunderstanding freezed v3 annotation scope. Solution: explicit per-class annotations forced visibility of problem.

## Lessons Extracted

1. **Freezed Constraints**: Version 3 enforces strict class type semantics. Always test both abstract and sealed variants before committing
2. **Build Runner Silence**: Missing codegen doesn't error — watch for file existence, not compile success
3. **Template Testing**: Even trivial generators need post-generation validation (analyze, test, build_runner), not just syntax checks
4. **Package Version Coordination**: 11 packages across two projects; always pin stables together, not individually

## Next Steps

Phase 2: Feature & Module System
- Feature scaffold command (create feature/{name} structure)
- Module add/remove commands
- 8 core modules: Local Storage, Push Notifications, Analytics, Networking Extensions, UI Kit, Error Handling, Logging, Device Info
- Dependency graph validation

**Owner**: Engineering  
**Timeline**: Next phase immediately available — no blockers

