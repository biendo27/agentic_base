import 'package:agentic_base/src/config/state_config.dart';

final class ScaffoldStateProfile {
  const ScaffoldStateProfile({
    required this.name,
    required this.displayName,
    required this.packages,
    required this.devPackages,
    required this.usesGetIt,
    required this.usesInjectable,
    required this.usesRiverpod,
    required this.usesMobx,
    required this.presentationRuntime,
  });

  final String name;
  final String displayName;
  final Map<String, String> packages;
  final Map<String, String> devPackages;
  final bool usesGetIt;
  final bool usesInjectable;
  final bool usesRiverpod;
  final bool usesMobx;
  final String presentationRuntime;

  bool get isCubit => name == 'cubit';
  bool get isRiverpod => name == 'riverpod';
  bool get isMobx => name == 'mobx';

  Map<String, dynamic> get masonVars => <String, dynamic>{
    'state_management': name,
    'state_display_name': displayName,
    'is_cubit': isCubit,
    'is_riverpod': isRiverpod,
    'is_mobx': isMobx,
    'uses_get_it': usesGetIt,
    'uses_injectable': usesInjectable,
    'uses_riverpod': usesRiverpod,
    'uses_mobx': usesMobx,
    'presentation_runtime': presentationRuntime,
  };

  static ScaffoldStateProfile fromState(String stateManagement) {
    return StateConfig.fromString(stateManagement).profile;
  }
}
