import 'package:agentic_base/src/tui/agentic_logger.dart';

/// Default platform choices for project creation.
const defaultPlatforms = ['android', 'ios', 'web'];

/// All supported platforms.
const allPlatforms = ['android', 'ios', 'web', 'macos', 'windows', 'linux'];

/// Supported state management options.
const stateManagementOptions = ['cubit', 'riverpod', 'mobx'];

/// Default flavor names.
const defaultFlavors = ['dev', 'staging', 'prod'];

/// Prompt user for project configuration when flags are missing.
class CreatePrompts {
  const CreatePrompts(this._logger);

  final AgenticLogger _logger;

  String promptOrg(String? flagValue) {
    if (flagValue != null) return flagValue;
    return _logger.prompt(
      'Organization (reverse domain)',
      defaultValue: 'com.example',
    );
  }

  List<String> promptPlatforms(String? flagValue) {
    if (flagValue != null) {
      return flagValue.split(',').map((p) => p.trim()).toList();
    }
    return _logger.chooseAny(
      'Target platforms',
      choices: allPlatforms,
      defaultValues: defaultPlatforms,
    );
  }

  String promptState(String? flagValue) {
    if (flagValue != null) return flagValue;
    return _logger.chooseOne(
      'State management',
      choices: stateManagementOptions,
      defaultValue: 'cubit',
    );
  }

  List<String> promptFlavors(String? flagValue) {
    if (flagValue != null) {
      return flagValue.split(',').map((f) => f.trim()).toList();
    }

    // Let user pick from defaults + offer custom input
    final selected = _logger.chooseAny(
      'Build flavors',
      choices: [...defaultFlavors, '(custom)'],
      defaultValues: defaultFlavors,
    );

    // If user selected (custom), prompt for custom flavors
    if (selected.contains('(custom)')) {
      final custom = _logger.prompt(
        'Enter custom flavors (comma-separated)',
        defaultValue: 'dev,staging,prod',
      );
      final customList = custom.split(',').map((f) => f.trim()).toList();
      // Merge selected defaults (minus the custom marker) + custom entries
      return [
        ...selected.where((f) => f != '(custom)'),
        ...customList,
      ];
    }

    return selected;
  }

  String promptPrimaryColor(String? flagValue) {
    if (flagValue != null) return flagValue;
    return _logger.prompt('Primary color (hex)', defaultValue: '6750A4');
  }
}
