---
title: Flavor, IDE, and Default App Cleanup Research
generated_at: 2026-04-10T08:56:19+07:00
work_context: /Users/biendh/base
---

# Research Report: Flavor, IDE, and Default App Cleanup

## Executive Summary

The repo already has the right shape for a product-grade Flutter scaffold: `lib/app/*`, `lib/core/*`, `lib/features/*`, native flavor wiring in Android/iOS, docs, tests, and build scripts. The problem is drift. `flutter run` still lands on the legacy `lib/main.dart` + `lib/app.dart` + `lib/flavors.dart` path, while the newer shell lives under `lib/app/app.dart` and `lib/main_{dev,staging,prod}.dart`. The sample home feature also still returns generated fake rows, so the default app still feels like a template.

`flutter_flavorizr` is currently too broad for this repo. Its official docs show it can generate Android/iOS native flavor wiring, but also Flutter-side files (`flutter:app`, `flutter:pages`, `flutter:main`, `flutter:flavors`) and IDE configs (`ide:config`). For agentic_base, those extra processors are the wrong boundary. The generator should own native flavor setup only; Dart app structure and editor launch config should be owned elsewhere.

Best fit: keep flavorizr native-only, make one canonical app entrypoint surface, and generate only the minimum shared IDE launch configs that are stable. If shared IntelliJ configs are not needed, prefer VS Code launch files only and keep `.idea` local.

## Sources Consulted

High-credibility sources first:

- Repo files: [README.md](/Users/biendh/base/README.md), [03-code-standards.md](/Users/biendh/base/docs/03-code-standards.md), [04-system-architecture.md](/Users/biendh/base/docs/04-system-architecture.md), [project_generator.dart](/Users/biendh/base/lib/src/generators/project_generator.dart), [brick.yaml](/Users/biendh/base/bricks/agentic_app/brick.yaml), [my_app](./) tree.
- Official package docs: [flutter_flavorizr on pub.dev](https://pub.dev/packages/flutter_flavorizr)
- Official Flutter docs: [pubspec default-flavor](https://docs.flutter.dev/tools/pubspec#default-flavor-field)
- Official JetBrains docs/search results: JetBrains help pages describing shared settings vs `workspace.xml` user state

Credibility ranking:

1. Official Flutter + package docs
2. Local repo source of truth
3. JetBrains help pages

## Key Findings

### 1. `flutter_flavorizr` should be constrained to native-only work

The package supports a wide instruction set:

- Native: `android:flavorizrGradle`, `android:buildGradle`, `android:androidManifest`, `android:icons`, `ios:podfile`, `ios:xcconfig`, `ios:buildTargets`, `ios:schema`, `ios:plist`, `ios:launchScreen`
- Flutter-side: `flutter:flavors`, `flutter:app`, `flutter:pages`, `flutter:main`
- IDE-side: `ide:config`

For this repo, the native set is the only part that belongs in flavorizr. The Flutter shell is already owned by Mason templates and the repo source tree. If flavorizr also writes app files, it reintroduces duplicate sources of truth and template drift.

Relevant repo evidence:

- `ProjectGenerator.generate()` shells out to `dart run flutter_flavorizr` after `flutter pub get` in [project_generator.dart](/Users/biendh/base/lib/src/generators/project_generator.dart)
- Android flavor wiring already exists in [my_app/android/app/build.gradle.kts](/Users/biendh/base/my_app/android/app/build.gradle.kts) and [my_app/android/app/flavorizr.gradle.kts](/Users/biendh/base/my_app/android/app/flavorizr.gradle.kts)
- iOS flavor wiring already exists in [my_app/ios/Runner.xcodeproj/project.pbxproj](/Users/biendh/base/my_app/ios/Runner.xcodeproj/project.pbxproj) and flavor-specific xcconfigs under [my_app/ios/Flutter/](/Users/biendh/base/my_app/ios/Flutter/)

Recommendation:

- Keep flavorizr on Android/iOS/macOS-native processors only
- Do not let it generate `lib/main.dart`, `lib/app.dart`, `lib/flavors.dart`, or editor configs
- If the package is invoked via YAML, pin the `instructions` list explicitly instead of relying on defaults

### 2. Editor config should be explicit and minimal

Current sample app state:

- `.idea` exists locally with `workspace.xml`, `modules.xml`, `libraries/Dart_SDK.xml`, `libraries/KotlinJavaRuntime.xml`, and `runConfigurations/main_dart.xml`
- `.vscode` does not exist
- `my_app/.gitignore` ignores `.idea/`, `*.iml`, and `.vscode/`

What should be generated:

- VS Code: `.vscode/launch.json`
- Optional VS Code: `.vscode/extensions.json`
- IntelliJ/Android Studio: only `.idea/runConfigurations/*.xml` if shared run targets are worth supporting

What must stay out:

- `.idea/workspace.xml` - user-specific editor state
- `.idea/libraries/*.xml` - in this repo they contain absolute SDK paths
- `*.iml` - import artifacts, not product behavior
- `.idea/modules.xml` - generated module binding, unnecessary in a generator-owned scaffold

Trade-off:

- VS Code config is lower maintenance and aligns with CLI-first usage
- IntelliJ run configs are useful only if you are willing to unignore a tiny `.idea/runConfigurations/` allowlist and keep it stable
- Avoid generating the rest of `.idea`; it becomes churn with little product value

### 3. The current default app is still template-like in three concrete ways

1. `flutter run` still lands on the legacy path:
   - [my_app/lib/main.dart](/Users/biendh/base/my_app/lib/main.dart) uses `F` + `appFlavor`
   - [my_app/lib/app.dart](/Users/biendh/base/my_app/lib/app.dart) shows a banner and `MyHomePage`
   - [my_app/lib/pages/my_home_page.dart](/Users/biendh/base/my_app/lib/pages/my_home_page.dart) renders `Hello ${F.title}`

2. The newer product shell is separate:
   - [my_app/lib/app/app.dart](/Users/biendh/base/my_app/lib/app/app.dart)
   - [my_app/lib/app/bootstrap.dart](/Users/biendh/base/my_app/lib/app/bootstrap.dart)
   - [my_app/lib/app/flavors.dart](/Users/biendh/base/my_app/lib/app/flavors.dart)

3. The starter data is fake:
   - [my_app/lib/features/home/data/repositories/home_repository_impl.dart](/Users/biendh/base/my_app/lib/features/home/data/repositories/home_repository_impl.dart) waits 1 second and generates 10 rows
   - This is demo behavior, not product behavior

Secondary template smell:

- [my_app/.idea/runConfigurations/main_dart.xml](/Users/biendh/base/my_app/.idea/runConfigurations/main_dart.xml) still points at `lib/main.dart`
- [my_app/README.md](/Users/biendh/base/my_app/README.md) tells users to run plain `flutter run`, which still hits the legacy entrypoint

### 4. Minimum product-grade default app

Minimum bar:

- One canonical run path
- One canonical flavor model
- A branded shell, not a bannered template
- Router, theme, DI, and error handling wired from the start
- At least one starter feature with loading/error/empty states
- No fake "generated items" unless they are explicitly framed as placeholder fixtures

For this repo, the product-grade shell already mostly exists in `lib/app/*`, `lib/core/*`, and `lib/features/home/*`. What is missing is consolidation and removal of the legacy template path.

Recommended minimum default app shape:

- `main.dart` becomes the default bootstrap for the dev flavor, or a thin alias to `main_dev.dart`
- `main_dev.dart`, `main_staging.dart`, `main_prod.dart` stay as explicit flavor entrypoints
- `App` stays in one place only
- The home screen shows a real starter dashboard or clearly labeled fixture state, not synthetic network-like data
- `flutter run` should open the product shell, not the old banner template

## Comparative Analysis

| Option | Performance | Complexity | Maintenance | Cost | Risk | Fit |
|---|---:|---:|---:|---:|---:|---|
| Native-only flavorizr + explicit IDE configs | High | Medium | Low | Low | Low | Best |
| Default flavorizr processors | Medium | Low | High | Low | High | Poor |
| Fully manual native flavor setup | High | High | High | Medium | Medium | Acceptable fallback |

Ranking:

1. Native-only flavorizr + explicit editor launch files
2. Manual native flavor setup if flavorizr proves brittle
3. Default flavorizr processors for Flutter/IDE files

## Recommended Implementation Phases

### Phase 1 - Unify entrypoints

- Make `flutter run` land on the real app shell
- Collapse or alias the legacy `lib/main.dart`, `lib/app.dart`, `lib/flavors.dart`, and `lib/pages/my_home_page.dart`
- Decide whether `default-flavor: dev` should be set in `pubspec.yaml`

Risk:

- Build scripts, IDE configs, and docs may still point at the old path

### Phase 2 - Narrow flavorizr

- Keep only native flavor processors
- Remove Flutter-side and IDE-side processors from flavorizr usage
- Verify Android/iOS flavor build outputs remain identical

Risk:

- Missing one native processor can break flavor-specific app names, IDs, icons, or launch screens

### Phase 3 - Editor config policy

- Choose VS Code-only, or VS Code plus shared IntelliJ run configs
- If IntelliJ configs are shared, allowlist only `.idea/runConfigurations/*.xml`
- Keep `workspace.xml`, `libraries/*`, `*.iml`, and `modules.xml` out

Risk:

- `.gitignore` churn and absolute-path leakage if the allowlist is too broad

### Phase 4 - Default app polish

- Replace synthetic repository data with a real starter surface
- Add a proper empty/loading/error state
- Keep the starter screen intentionally simple, not demo-heavy

Risk:

- Overbuilding the starter screen turns the template into product debt

## Test Matrix

Minimum matrix for this cleanup:

| Area | Command / Check | Pass condition |
|---|---|---|
| Package | `dart analyze --fatal-infos` | No analyzer failures |
| Formatting | `dart format --set-exit-if-changed lib test` | No formatting drift |
| Unit tests | `dart test` | All tests pass |
| Codegen | `dart run build_runner build --delete-conflicting-outputs` | No generator failures |
| App smoke | `flutter test integration_test/app_test.dart` | App launches |
| Android flavors | `flutter build apk --flavor dev|staging|prod -t lib/main_*.dart` | All flavor builds succeed |
| iOS flavors | `flutter build ipa --flavor staging|prod -t lib/main_*.dart` | Native flavor builds succeed on macOS |
| IDE launch | VS Code / Android Studio run targets | Dev/staging/prod launch the intended entrypoint |

## Ranked Recommendation

1. **Best choice:** keep `flutter_flavorizr` native-only, own Flutter shell files in Mason/templates, and generate only minimal shared editor launch configs.
2. **Second choice:** keep native-only flavorizr and skip shared IDE configs entirely; rely on CLI and IDE auto-import.
3. **Do not do:** keep flavorizr defaults that generate Flutter app files and IDE configs. That is the main source of drift here.

Why this is the right fit:

- Matches the repo’s generator-first architecture
- Reduces template drift
- Keeps editor state out of the scaffold
- Preserves deterministic native flavor builds

## Unresolved Questions

- Should agentic_base support shared IntelliJ configs at all, or standardize on VS Code launch files only?
- Should the default flavor be `dev` or `staging` when plain `flutter run` is used?
- Should the legacy `main.dart` remain as a compatibility shim, or be removed entirely once the new shell is canonical?

## References

- [Agentic base README](/Users/biendh/base/README.md)
- [Code standards](/Users/biendh/base/docs/03-code-standards.md)
- [System architecture](/Users/biendh/base/docs/04-system-architecture.md)
- [Project generator](/Users/biendh/base/lib/src/generators/project_generator.dart)
- [App brick](/Users/biendh/base/bricks/agentic_app/brick.yaml)
- [flutter_flavorizr docs](https://pub.dev/packages/flutter_flavorizr)
- [Flutter default flavor docs](https://docs.flutter.dev/tools/pubspec#default-flavor-field)
- [JetBrains shared settings docs](https://resources.jetbrains.com/storage/products/help/data/idea/2016.1/intellij-idea-help.pdf)
