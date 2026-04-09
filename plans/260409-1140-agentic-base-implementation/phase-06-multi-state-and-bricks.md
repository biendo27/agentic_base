# Phase 6 — Multi-State & Bricks (v0.6.0)

## Context Links
- [Architecture Report](../reports/brainstorm-260409-1103-agentic-base-architecture.md) — Section 3
- [Phase 2](./phase-02-feature-and-module-system.md)

## Overview
- **Priority**: P2
- **Status**: Pending
- **Effort**: 15h
- **Depends on**: Phase 2

Add Riverpod and MobX state management options to `create` and `feature` commands. Build `brick` command for community mason bricks. Build `init` command for existing projects. Build `upgrade` command.

## Requirements

### Functional
- `agentic_base create my_app --state riverpod` generates Riverpod-based project
- `agentic_base create my_app --state mobx` generates MobX-based project
- Feature command adapts to state choice from .info/agentic.yaml
- Module wiring adapts per state management (get_it for Cubit/MobX, riverpod for Riverpod)
- `agentic_base brick add <name>` installs community mason brick
- `agentic_base brick remove <name>` removes brick
- `agentic_base brick list` lists installed bricks
- `agentic_base init` adds agentic_base to existing Flutter project (non-destructive)
- `agentic_base upgrade` upgrades Flutter SDK + packages

## Architecture

### State Management Variants

| Component | Cubit (default) | Riverpod | MobX |
|-----------|----------------|----------|------|
| State | flutter_bloc + freezed | riverpod + freezed | mobx + flutter_mobx |
| DI | get_it + injectable | riverpod_annotation | get_it + injectable |
| Testing | bloc_test + mocktail | riverpod test + mocktail | mobx test + mocktail |
| Feature template | cubit_feature brick | riverpod_feature brick | mobx_feature brick |
| Module wiring | @module (get_it) | Provider definitions | @module (get_it) |

### Brick Structure per State
```
bricks/
├── agentic_app/          # shared base (state-agnostic parts)
├── state_variants/
│   ├── cubit/            # Cubit-specific files overlay
│   ├── riverpod/         # Riverpod-specific files overlay
│   └── mobx/             # MobX-specific files overlay
├── features/
│   ├── cubit_feature/
│   ├── riverpod_feature/
│   └── mobx_feature/
└── modules/
    ├── cubit/            # Module wiring for get_it
    ├── riverpod/         # Module wiring for riverpod
    └── mobx/             # Module wiring for get_it
```

## Implementation Steps

### Step 1: State Config System
1. Update `state_config.dart` — enum StateManagement { cubit, riverpod, mobx }
2. Each state defines: packages, DI system, testing packages, code-gen packages
3. `create` command reads --state flag, passes to generator
4. `feature` command reads state from .info/agentic.yaml

### Step 2: Riverpod Variant
1. Create `bricks/state_variants/riverpod/` — Riverpod-specific overlays:
   - No get_it/injectable. Uses riverpod_annotation instead
   - ProviderScope in App widget
   - ConsumerWidget/ConsumerStatefulWidget patterns
2. Create `bricks/features/riverpod_feature/` — feature template with:
   - providers/ instead of cubit/
   - @riverpod annotation
   - AsyncNotifier pattern
3. Create module wiring bricks for Riverpod (top 8 core modules)
4. Update pubspec.yaml template for Riverpod deps
5. Test: create project with --state riverpod → compile → test pass

### Step 3: MobX Variant
1. Create `bricks/state_variants/mobx/` — MobX-specific overlays:
   - get_it + injectable (same as Cubit)
   - Store pattern with @observable, @action, @computed
   - mobx_codegen in build.yaml
2. Create `bricks/features/mobx_feature/` — feature template with:
   - store/ instead of cubit/
   - @observable annotations
3. Create module wiring bricks for MobX (same as Cubit — both use get_it)
4. Test: create project with --state mobx → compile → test pass

### Step 4: Brick Command
1. Create `brick_command.dart` with subcommands: add, remove, list
2. `brick add <name>` — uses mason_api to fetch from BrickHub/GitHub
3. `brick remove <name>` — removes brick files
4. `brick list` — shows installed community bricks
5. Write tests

### Step 5: Init Command
1. Create `init_command.dart`
2. Flow: scan existing project → detect packages (flutter_bloc? riverpod? getx?) → detect structure
3. Add missing pieces non-destructively:
   - core/ (if missing)
   - AGENTS.md, CLAUDE.md
   - tools/ scripts, Makefile
   - .info/agentic.yaml
   - build.yaml, analysis_options.yaml
4. Output manual migration steps for user
5. Write tests

### Step 6: Upgrade Command
1. Create `upgrade_command.dart`
2. Flow: check current versions → run `flutter upgrade` → run `flutter pub upgrade` → update .info/agentic.yaml
3. Warn about breaking changes if major version bump
4. Write tests

## Todo List
- [ ] State config system (enum + per-state package sets)
- [ ] Riverpod variant: app overlay + feature brick + module wiring
- [ ] MobX variant: app overlay + feature brick + module wiring
- [ ] Test: create with --state riverpod → compile + test
- [ ] Test: create with --state mobx → compile + test
- [ ] Brick command (add/remove/list community bricks)
- [ ] Init command (add to existing project)
- [ ] Upgrade command (Flutter SDK + packages)

## Success Criteria
- [ ] `create --state riverpod` generates working Riverpod project
- [ ] `create --state mobx` generates working MobX project
- [ ] `feature` adapts to project's state management choice
- [ ] `add` modules wire correctly for all 3 state options
- [ ] `brick add/remove/list` works for community bricks
- [ ] `init` adds agentic_base to existing project non-destructively
- [ ] `upgrade` updates Flutter + packages

## Risk Assessment
| Risk | Impact | Mitigation |
|------|--------|------------|
| 3x template maintenance | Slow iteration | Share base template, only override state-specific files |
| Riverpod DI differs fundamentally | Module wiring complex | Separate module bricks per state |
| Init on diverse projects | Edge cases | Support common patterns only, document limitations |

## Next Steps
→ Phase 7: Polish & Publish
