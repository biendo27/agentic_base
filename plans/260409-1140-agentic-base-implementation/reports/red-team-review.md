# Red-Team Review: agentic_base Implementation Plan

**Reviewer**: code-reviewer | **Date**: 2026-04-09 | **Verdict**: HIGH RISK — plan has structural flaws that will cause pain

---

## 1. CRITICAL: Wrong Package — mason_api vs mason

Phase 1 lists `mason_api` as a dependency. **mason_api is a BrickHub registry API client** (login/logout/auth). The package for programmatic brick generation is `mason` (provides `MasonGenerator`, `MasonBundle`). This confusion appears in Step 7 ("Generate via `mason_api`") and pubspec dependencies. If implemented as-written, generation will not work at all.

**Fix**: Replace `mason_api` with `mason: ^0.1.2` everywhere. Use `MasonGenerator.fromBundle()` + `DirectoryGeneratorTarget`.

## 2. CRITICAL: pub.dev Score Target is Wrong

Plan targets "140+ points." Actual maximum is **160 points** (confirmed via mason's score page: 160/160). A target of 140 is achievable but the plan doesn't know what it's scoring against. The six categories and their maxes:
- Dart file conventions: 30
- Documentation: 20
- Platform support: 20
- Static analysis: 50
- Up-to-date dependencies: 40
- (sixth varies)

Phase 7 doesn't address platform support (pure Dart CLI = native+web compatibility matters). This is where mason itself loses 10 points.

## 3. CRITICAL: Effort Estimates Are Fantasy

| Phase | Planned | Realistic | Why |
|-------|---------|-----------|-----|
| 1 | 30h | 60-80h | ~60 Mustache template files, each needs compile-test. M3 theme alone is 6 files with 15 typography styles + ALL component themes. Post-gen hooks that run flutter pub get + build_runner must handle every failure mode. |
| 2 | 25h | 40-50h | 8 modules x (contract + impl + DI wiring + brick + tests) = ~40 files minimum. pubspec.yaml manipulation is notoriously fragile. |
| 5 | 15h | 40-60h | 17 modules. That's <1h per module including brick, contract, impl, DI wiring, tests, and conflict matrix. Absurd. |
| 6 | 15h | 50-70h | 3x state management variants means 3x feature bricks + 3x app overlays + rewiring 25 modules for Riverpod (fundamentally different DI). Init command on arbitrary existing projects is an open-ended problem. |

**Total realistic: 250-350h vs planned 120h.** Plan is 2-3x underestimated.

## 4. Architecture Holes

### 4a. Mustache Template Hell
~60 template files with Mustache conditionals for platforms, flavors, state management, primary color. Mustache is logic-less — complex conditionals require pre_gen.dart hook gymnastics. When you need `{{#is_cubit}}...{{/is_cubit}}{{#is_riverpod}}...{{/is_riverpod}}{{#is_mobx}}...{{/is_mobx}}` in 60+ files, maintainability collapses. Plan mentions no strategy for template testing or template linting.

### 4b. pubspec.yaml Manipulation is Unsafe
Phase 2 plans to modify user's pubspec.yaml with the `yaml` package. The `yaml` package **parses** YAML but does NOT preserve comments, formatting, or key ordering when writing back. Doing `yamlDoc.toString()` will mangle the file. Need `yaml_edit` package (preserves formatting) or string-based manipulation.

### 4c. DI Wiring Injection is Under-specified
"Wire into DI" for modules means modifying existing Dart source files — inserting import statements and registration calls. Plan says "Injectable handles order via annotation scan" but injectable needs `@module` annotations in specific files. The plan doesn't explain how `add analytics` modifies `injection.dart` or creates a new `@module` class. This is AST manipulation or fragile regex — neither is mentioned.

### 4d. State Management Abstraction is Missing
Phase 6 creates 3 separate brick sets but Phase 2's 8 core modules only have Cubit bricks (`bricks/modules/cubit/`). Phase 6 says "Create module wiring bricks for Riverpod (top 8 core modules)" — that's 8 more bricks. Phase 5's 17 extended modules? Plan is silent on Riverpod/MobX variants for those. That's potentially 17x3 = 51 module bricks total, not mentioned anywhere.

## 5. Missing Steps

1. **No `mason bundle` step in CI** — brick bundling produces a `.dart` bundle file that must be committed or generated in CI. Plan mentions Step 9 manual bundle but no automation.
2. **No Windows support testing** — tool targets pub.dev (cross-platform) but all scripts are `.sh`. Windows users get broken `tools/` and `Makefile`.
3. **No version pinning strategy** — generated pubspec.yaml must pin compatible versions of ~30 packages. A single bad `^` range + pub resolution = broken project 3 months later.
4. **No `--no-interactive` / CI mode** — create command uses prompts (Phase 1 `prompts.dart`) but no flag for CI/scripted usage.
5. **No cleanup on failure** — if `flutter pub get` fails in post_gen, user has a half-generated broken directory. No rollback.
6. **No update command for the tool itself** — `pub_updater` is in deps but no `update` command implementation.

## 6. Dependency Risks

| Dependency | Risk |
|-----------|------|
| `mason` 0.1.2 | Pre-1.0, API may break. Last update 4 months ago. |
| `mason_api` 0.1.1 | Wrong package for this use case (see #1). 13 months stale. |
| `purchases_flutter` (RevenueCat) | Requires RevenueCat account + API keys. Module "install" can't actually work without config. |
| `google_mobile_ads` | Requires AdMob app ID in AndroidManifest.xml. Module install must handle platform config files. |
| `google_maps_flutter` | Requires API key in both platform manifests. Same problem. |
| `firebase_*` packages (3 modules) | Require `firebase_core` init + `google-services.json` / `GoogleService-Info.plist`. Module system doesn't address Firebase project setup. |
| `camerawesome` | Niche package. 1 verified publisher. Risk of abandonment. |
| `alchemist` (golden tests) | Check if still maintained / compatible with latest Flutter. |

## 7. Integration Risks

- **Phase 2 + Phase 6 collision**: Phase 2 builds 8 modules for Cubit only. Phase 6 retroactively needs to support those same modules for Riverpod/MobX. This means Phase 2's module contract must be state-agnostic from day 1, but the plan's `AgenticModule.wireIntoDI()` assumes a single DI strategy.
- **Phase 5's 17 modules assume Phase 2's contract works** — but Phase 2's contract hasn't been stress-tested with modules that need platform-specific config (AndroidManifest, Info.plist).
- **`remove` command** (Phase 2) must undo DI wiring. If wiring was done by modifying Dart source files, removal requires understanding the exact insertion points. One refactor by the user = broken removal.

## 8. Edge Cases That Will Crash

1. `create my-app` — Dart package names can't have hyphens. Validation missing.
2. `create ../escape` or `create /tmp/outside` — path traversal.
3. `add analytics` when Firebase isn't configured — runtime crash in generated app.
4. `remove auth` when `social_login` depends on it — dependency check exists in Phase 5 but not Phase 2.
5. `feature` when CWD is not an agentic_base project — missing `.info/agentic.yaml`.
6. `gen` when build_runner has conflicting outputs — `--delete-conflicting-outputs` is used but error handling unclear.
7. Disk full during generation — partial output with no cleanup.
8. User modifies generated DI code, then runs `add` — module wiring can't find expected insertion points.

## 9. pub.dev Specific Risks

- CLI tool with `bin/` entry + heavy `bricks/` directory = large package size. pub.dev doesn't penalize size directly but users notice.
- `dart pub global activate` — the main install path — needs the tool to work without Flutter SDK in PATH. But the tool runs `flutter pub get` in post-gen. Doctor command checks this but create doesn't guard it.
- Example directory (required for full score) containing a generated Flutter project would be enormous. Plan says "3 example projects" — that's potentially 3 full Flutter apps in `example/`.

## 10. Recommendations (Priority Order)

1. **Fix mason_api → mason dependency** immediately
2. **Add template testing strategy** — every template file needs a generate-and-compile integration test
3. **Use `yaml_edit` not `yaml`** for pubspec manipulation
4. **Design state-agnostic module contract** before Phase 2 starts (account for Phase 6)
5. **Cut scope**: Ship Cubit-only as v1.0. Riverpod/MobX as v1.1. 25 modules is excessive for initial release — ship 8 core, mark extended as "coming soon"
6. **Re-estimate at 250-300h** or cut scope to match 120h budget
7. **Add rollback/cleanup** on generation failure
8. **Address platform config** (AndroidManifest, Info.plist, Firebase) in module contract
9. **Add `--no-interactive` flag** from day 1
10. **Plan for 51+ module bricks** or find a way to share templates across state management options

---

**Bottom line**: The plan describes a legitimate product but underestimates implementation by 2-3x. The mason_api/mason confusion is a showstopper. The 3x state management multiplier on 25 modules is scope-creeping toward 75 brick variants with no strategy for managing that complexity. Ship Cubit-only with 8 modules as v1.0 or this will never land.
