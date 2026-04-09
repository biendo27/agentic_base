# Phase 7 — Polish & Publish (v1.0.0)

## Context Links
- [Architecture Report](../reports/brainstorm-260409-1103-agentic-base-architecture.md) — Section 14
- All previous phases

## Overview
- **Priority**: P2
- **Status**: Pending
- **Effort**: 10h
- **Depends on**: Phases 1-6

Comprehensive tool testing, pub.dev score optimization (140+ points), documentation, example projects, CHANGELOG, CI/CD for the tool itself, and final publish to pub.dev.

## Requirements

### Functional
- All 11 commands work correctly with all flag combinations
- Example projects for each state management option (Cubit, Riverpod, MobX)
- Comprehensive README with usage examples, GIFs
- CHANGELOG follows keepachangelog.com format
- CI/CD for the tool: tests on PR, publish on tag

### Non-Functional
- pub.dev score: 140+ points (pana analysis pass)
- dart doc generates clean API documentation
- All public APIs documented
- Zero analyzer warnings
- Test coverage >80%

## Implementation Steps

### Step 1: Tool Test Suite
1. Unit tests for all commands (create, add, remove, feature, gen, eval, brick, deploy, upgrade, doctor, init)
2. Integration test: full create → add modules → feature → eval → deploy flow
3. Test all --state variants (cubit, riverpod, mobx)
4. Test module conflict scenarios
5. Test edge cases: invalid args, missing Flutter SDK, corrupt agentic.yaml

### Step 2: pub.dev Score Optimization
1. Run `dart pub publish --dry-run` to check issues
2. Run `pana` (pub analysis tool) locally
3. Fix: dartdoc comments on all public APIs
4. Fix: example/ directory with minimal usage example
5. Fix: proper pubspec fields (description, homepage, repository, issue_tracker)
6. Fix: LICENSE file (MIT)
7. Fix: CHANGELOG.md
8. Target: 140+ points

### Step 3: Example Projects
1. Generate 3 example projects (one per state management)
2. Each includes 2-3 modules installed
3. Store in `example/` directory
4. Verify each compiles and tests pass

### Step 4: Documentation
1. Comprehensive README.md:
   - Installation, quick start, all commands with examples
   - State management comparison table
   - Module catalog
   - Contributing guide
2. CHANGELOG.md covering v0.1.0 through v1.0.0
3. dartdoc comments on public API

### Step 5: Tool CI/CD
1. GitHub Actions for the tool itself:
   - `ci.yml` — lint + test on every PR
   - `publish.yml` — publish to pub.dev on version tag
2. Test matrix: Dart stable + Flutter stable
3. Automated version bump + tag workflow

### Step 6: Final Verification
1. Clean install test: `dart pub global activate agentic_base`
2. Full workflow: create → add modules → feature → gen → eval → deploy
3. Verify on macOS + Linux (CI)
4. Review generated AGENTS.md effectiveness: give to Claude Code, ask it to add a feature
5. Publish to pub.dev

## Todo List
- [ ] Comprehensive tool test suite (all commands + edge cases)
- [ ] pub.dev score optimization (pana, dartdoc, example/)
- [ ] Example projects (3 state management options)
- [ ] README.md with full documentation
- [ ] CHANGELOG.md
- [ ] Tool CI/CD (test on PR, publish on tag)
- [ ] Clean install verification
- [ ] AI agent effectiveness test (AGENTS.md)
- [ ] Publish to pub.dev

## Success Criteria
- [ ] pub.dev score ≥140 points
- [ ] All tool tests pass (>80% coverage)
- [ ] 3 example projects compile + test pass
- [ ] README covers all 11 commands with examples
- [ ] `dart pub global activate agentic_base` works
- [ ] Claude Code can add feature to generated project using only AGENTS.md
- [ ] Published on pub.dev

## Risk Assessment
| Risk | Impact | Mitigation |
|------|--------|------------|
| pub.dev score below 140 | Can't publish well | Run pana early, fix incrementally |
| Example projects stale | Bad first impression | Generate fresh in CI |
| dartdoc incomplete | Score penalty | Lint for missing docs |

## Next Steps
- Post-v1.0: Signals state management, more community bricks, VSCode extension, documentation site
