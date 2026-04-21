import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs a custom feature flags service (no external package required).
class FeatureFlagsModule implements AgenticModule {
  const FeatureFlagsModule();

  @override
  String get name => 'feature_flags';

  @override
  String get description =>
      'Feature flags — custom in-memory toggle service for progressive rollouts.';

  @override
  List<String> get dependencies => [];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
    'Define your flags in FeatureFlagsServiceImpl._defaults.',
    'Connect to remote_config or a backend to override flags at runtime.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..writeFile(
        'lib/services/feature_flags/feature_flags_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/services/feature_flags/feature_flags_service_impl.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..deleteFile('lib/services/feature_flags/feature_flags_service.dart')
      ..deleteFile('lib/services/feature_flags/feature_flags_service_impl.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Feature flags service contract.
///
/// Flags are keyed by string identifiers. Override values at runtime
/// by calling [setFlag] (e.g. from a remote config callback).
abstract class FeatureFlagsService {
  /// Returns true if [flag] is enabled.
  bool isEnabled(String flag);

  /// Override [flag] value at runtime.
  void setFlag(String flag, {required bool enabled});

  /// Bulk-load a map of overrides (e.g. from remote config).
  void loadOverrides(Map<String, bool> overrides);

  /// Reset all runtime overrides, reverting to compiled defaults.
  void resetOverrides();
}
''';

  String _implContent(String pkg) => '''
import 'package:$pkg/services/feature_flags/feature_flags_service.dart';

/// In-memory implementation of [FeatureFlagsService].
///
/// Add your app's flags to [_defaults]. Override values at runtime
/// via [setFlag] or [loadOverrides] (e.g. driven by RemoteConfigService).
class FeatureFlagsServiceImpl implements FeatureFlagsService {
  /// Compiled-in default values for every known flag.
  ///
  /// Add entries here as your app grows:
  ///   'new_onboarding_flow': false,
  ///   'dark_mode_v2': true,
  static const Map<String, bool> _defaults = {
    'example_flag': false,
  };

  final Map<String, bool> _overrides = {};

  @override
  bool isEnabled(String flag) => _overrides[flag] ?? _defaults[flag] ?? false;

  @override
  void setFlag(String flag, {required bool enabled}) {
    _overrides[flag] = enabled;
  }

  @override
  void loadOverrides(Map<String, bool> overrides) {
    _overrides.addAll(overrides);
  }

  @override
  void resetOverrides() => _overrides.clear();
}
''';
}
