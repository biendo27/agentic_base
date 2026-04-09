/// State management configuration — packages, dev packages, DI system.
library;

/// Supported state management paradigms with their associated dependency sets.
///
/// Each value carries the exact pub constraints to inject into `pubspec.yaml`
/// and the DI system identifier used by module installers.
enum StateConfig {
  /// Flutter Bloc / Cubit + get_it + injectable.
  cubit(
    packages: {
      'flutter_bloc': '^9.1.1',
      'get_it': '^9.2.1',
      'injectable': '^2.7.1',
    },
    devPackages: {
      'bloc_test': '^10.0.0',
      'injectable_generator': '^2.12.1',
    },
    diSystem: 'get_it',
  ),

  /// Flutter Riverpod + riverpod_annotation (self-contained DI).
  riverpod(
    packages: {
      'flutter_riverpod': '^2.6.1',
      'riverpod_annotation': '^2.6.1',
    },
    devPackages: {
      'riverpod_generator': '^2.6.3',
      'riverpod_lint': '^2.6.3',
    },
    diSystem: 'riverpod',
  ),

  /// Flutter MobX + get_it + injectable.
  mobx(
    packages: {
      'flutter_mobx': '^2.2.1',
      'mobx': '^2.4.0',
      'get_it': '^9.2.1',
      'injectable': '^2.7.1',
    },
    devPackages: {
      'mobx_codegen': '^2.7.0',
      'build_runner': '^2.13.1',
      'injectable_generator': '^2.12.1',
    },
    diSystem: 'get_it',
  );

  const StateConfig({
    required this.packages,
    required this.devPackages,
    required this.diSystem,
  });

  /// `pubspec.yaml` `dependencies` entries: name → version constraint.
  final Map<String, String> packages;

  /// `pubspec.yaml` `dev_dependencies` entries: name → version constraint.
  final Map<String, String> devPackages;

  /// DI system identifier: `'get_it'` or `'riverpod'`.
  final String diSystem;

  // ---------------------------------------------------------------------------
  // Factory
  // ---------------------------------------------------------------------------

  /// Resolve [StateConfig] from a string name (e.g. `'cubit'`).
  ///
  /// Throws [ArgumentError] for unrecognised names.
  static StateConfig fromString(String name) => switch (name) {
        'cubit' => cubit,
        'riverpod' => riverpod,
        'mobx' => mobx,
        _ => throw ArgumentError('Unknown state management: $name'),
      };

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Human-readable label for this configuration.
  String get displayName => switch (this) {
        cubit => 'Flutter Bloc / Cubit',
        riverpod => 'Riverpod',
        mobx => 'MobX',
      };
}
