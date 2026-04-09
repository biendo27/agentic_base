# Flutter/Dart CLI Scaffolding Landscape (2024-2026)

## Executive Summary

Five major tools dominate: **very_good_cli** (opinionated, bundled mason bricks, tested), **mason** (flexible template engine), **flutter create** (baseline, minimal), **stacked_cli** (MVVM-specific), **get_cli** (GetX-specific). Dart TUI support is nascent (utopia_tui, nocterm, konsole). Key gap: seamless monorepo scaffolding, AI-assisted code generation post-gen hooks, and workspace-aware project templates.

---

## 1. Very Good CLI

**What it generates:**
- Multi-platform Flutter app (iOS/Android/Web/Windows/macOS/Linux)
- Flutter/Dart packages
- Dart CLI tools
- Flame games
- Documentation sites
- Generated with 100% test coverage baseline, BLoC state management, folder-by-feature structure

**Architecture patterns:**
- Four-layer architecture: data → domain → business logic (BLoC) → presentation
- Folder-by-feature organization (each feature = view + cubit)
- Bundled, pre-generated mason bricks (not external registry)
- Build flavors (dev, staging, prod)
- Internationalization via synthetic code gen

**Limitations:**
- Opinionated (forces BLoC + folder-by-feature; not suitable for simple apps)
- Heavy boilerplate (~150+ files minimum)
- Mason bundle regeneration required when templates change (not live updates)

**Adoption:** ✅ High—Very Good Ventures maintains actively, 1000+ public projects use pattern

---

## 2. Mason (Template System)

**How it works:**
1. Define brick templates in `.bricks/{name}/__brick__/` (Handlebars + YAML metadata)
2. CLI: `mason add brick_name` (registers from BrickHub, GitHub, or local)
3. `mason make brick_name` generates files with variable substitution
4. Hooks (pre-gen, post-gen) run Dart code before/after generation

**Key features:**
- **Variables & conditionals:** `{{variable_name}}`, `{{#if condition}}...{{/if}}` in templates
- **Hooks:** Pre-gen validates/transforms vars; post-gen runs pubspec get, dart format, tests
- **Nesting:** Sequential brick generation via post-gen hooks
- **Reuse:** BrickHub registry + GitHub sources + local bundles

**Popular bricks:**
- very_good_flutter_app (wrapper on very_good_cli)
- flutter_bloc_brick (BLoC feature scaffold)
- flutter_feature (generic feature structure)
- dart_package (Dart lib scaffold)

**Limitations:**
- Hook complexity grows with nesting (three+ sequential bricks = maintenance burden)
- No built-in CI/CD integration (hooks can call commands, but no standard patterns)
- Performance: registry lookups on every `mason add` (unless cached)
- Conditional logic in Handlebars (3-level nesting max before unreadability)

**Adoption:** ✅ Very high—Core dependency for very_good_cli, ~2K+ public bricks

---

## 3. Flutter Create (Default)

**What's included:**
- Basic app with single main.dart + test stub
- Minimal dependencies (flutter SDK only)
- Native iOS/Android skeleton + web/desktop stubs
- Single-flavor, no build variants

**What's missing:**
- State management (BLoC, GetX, Riverpod - developer choice)
- Project structure (flat vs folder-by-feature)
- Testing utilities/examples
- Internationalization
- CI/CD workflows
- Code generation setup (build_runner boilerplate)

**Use case:** Educational, proof-of-concept; unsuitable for production without heavy augmentation

---

## 4. Other Architecture-Specific CLIs

| Tool | Pattern | Status | Gap |
|------|---------|--------|-----|
| **stacked_cli** | MVVM (ViewModel-based) | Active | Niche audience; less popular than BLoC |
| **get_cli** | GetX (reactive) | Active | GetX declining adoption vs BLoC/Riverpod |
| **flutter_bloc_cli** | BLoC feature scaffold | Active | Code gen only; no full-app bootstrap |

---

## 5. Dart TUI Libraries (2025)

**Mature options:**
- **utopia_tui**: High-level components (panels, tables, inputs, progress bars), event-driven, ANSI styling, multiple themes
- **nocterm**: Flutter-like API (StatefulComponent, setState, hot reload), 45+ components, familiar to Flutter devs
- **konsole**: Component-based (boxes, buttons, spinners), lightweight

**Current state:** Early maturity; suitable for CLI tools, not mission-critical UX

**What CLI scaffold tools could leverage:** Interactive prompts beyond mason_logger's basic `chooseOne()`, file tree builders, progress visualization

---

## 6. Code Generation & CI/CD Integration

**Code generation status:**
- very_good_cli runs `dart format` + `flutter pub get` in post-gen hook
- No out-of-box build_runner integration (freezed, json_serializable still manual)
- No code-gen templating (generate models from templates)

**CI/CD patterns:**
- GitHub Actions workflows (push/PR → test → build → deploy)
- Fastlane integration for iOS/Android store deployment
- Very Good CLI has test command (aggregates tests, runs with JSON reporter)
- No scaffolding tool generates CI/CD workflows yet

---

## 7. Monorepo Support (Emerging Gap)

**Melos:** Manages multi-package monorepos (versioning, publishing, script execution across packages)

**Pub Workspaces (Dart 3.6+):** Native monorepo support via root pubspec.yaml

**Gap:** No CLI tool bootstraps a monorepo structure:
- No "very_good create --monorepo" equivalent
- Melos post-scaffolding (use Melos after flutter create)
- flutter_workspaces_cli exists but minimal adoption

---

## 8. Key Gaps All Tools Miss

| Gap | Impact | Opportunity |
|-----|--------|-------------|
| **Monorepo bootstrapping** | Large teams restart from scratch | Template with Melos + workspace setup |
| **Workspace-aware gen** | Can't scaffold package-relative paths | Add workspace context to brick vars |
| **Integrated code gen** | Manual freezed, json_serializable setup | Pre-configured build_runner + bricks |
| **AI-assisted post-gen** | Copy-paste boilerplate remains | Hook → LLM API → generate models/routes |
| **Live template updates** | Bundle stale; no hot-reload | Registry-synced bricks with version pinning |
| **CI/CD scaffolding** | Manual GitHub Actions setup | Generate .github/workflows/ from template |
| **Cross-platform parity** | Web/desktop often forgotten | Enforce platform template coverage |
| **Advanced TUI for setup** | mason_logger is minimal | Use utopia_tui/nocterm for interactive install |

---

## 9. Recommended Hierarchy

For new tool ("Agentic CLI"):
1. **Foundation:** mason (proven, extensible)
2. **Patterns:** very_good_cli structure (production-tested)
3. **Differentiation:**
   - Monorepo-first templates
   - Integrated code-gen (freezed, json_serializable pre-configured)
   - AI-assisted post-gen (LLM for model/route scaffolding)
   - Workspace-aware brick variables
   - GitHub Actions + Fastlane template generation
   - utopia_tui/nocterm for rich interactive setup

---

## 10. Adoption Risk Summary

| Tool | Maturity | Breaking Changes | Maintenance |
|------|----------|------------------|-------------|
| flutter create | Stable | Rare | Flutter team |
| mason | Stable | Rare | Very Good Ventures (active) |
| very_good_cli | Stable | Rare | Very Good Ventures (active) |
| stacked_cli | Stable | Occasional | FilledStack (active) |
| get_cli | Stable | Occasional | GetX team (moderately active) |
| utopia_tui | Early | Possible | Single maintainer (active) |
| nocterm | Early | Possible | Single maintainer (emerging) |

---

## Sources

- [Very Good CLI Documentation](https://cli.vgv.dev/)
- [Very Good CLI 1.0.0 Release](https://verygood.ventures/blog/very-good-cli-1-0-flutter-testing-mcp-semantic-versioning/)
- [Very Good Ventures Architecture Blog](https://verygood.ventures/blog/very-good-flutter-architecture/)
- [Mason: A Complete Guide for Flutter Developers](https://medium.com/simform-engineering/mason-a-complete-guide-for-flutter-developers-a1764a27ab1a)
- [Using Mason and Bricks - Codemagic](https://blog.codemagic.io/mason-cli/)
- [Stacked CLI Documentation](https://stacked.filledstacks.com/docs/tooling/stacked-cli/)
- [Utopia TUI GitHub](https://github.com/utopia-dart/utopia_tui)
- [Nocterm - Flutter-like TUI Framework](https://nocterm.dev/)
- [Flutter Code Generation with build_runner](https://dasroot.net/posts/2026/01/flutter-code-generation-freezed-json-serializable-build-runner/)
- [Flutter CI/CD with GitHub Actions](https://www.freecodecamp.org/news/how-to-build-a-production-ready-flutter-ci-cd-pipeline-with-github-actions-quality-gates-environments-and-store-deployment/)
- [Melos - Monorepo Management](https://melos.invertase.dev/)
- [Pub Workspaces Documentation](https://dart.dev/tools/pub/workspaces)
- [Flutter at Scale: Monorepo Playbook](https://tomasrepcik.dev/blog/2025/2025-07-01-flutter-monorepo/)

---

**Unresolved questions:**
- Should new tool fork very_good_cli codebase or build adjacent?
- AI integration: LLM provider (Claude, Gemini, local Ollama)?
- Monorepo template: Melos or native pub workspaces priority?
- Publishing: pub.dev or GitHub releases only?
