import 'dart:io';

import 'package:agentic_base/src/config/spec_parser.dart';
import 'package:agentic_base/src/generators/test_generator.dart';
import 'package:path/path.dart' as p;

final class FeatureHostSynchronizer {
  const FeatureHostSynchronizer();

  void sync({
    required String projectPath,
    required String projectName,
    required String featureName,
    required bool simple,
    FeatureSpec? spec,
  }) {
    _wireRoute(
      projectPath: projectPath,
      featureName: featureName,
    );

    if (simple || spec == null) {
      return;
    }

    _writeFeatureSpecContract(
      projectPath: projectPath,
      featureName: featureName,
      spec: spec,
    );
    _writeFeatureSpecTest(
      projectPath: projectPath,
      projectName: projectName,
      spec: spec,
    );
  }

  void _wireRoute({
    required String projectPath,
    required String featureName,
  }) {
    final routerFile = File(
      p.join(projectPath, 'lib/core/router/app_router.dart'),
    );
    if (!routerFile.existsSync()) {
      return;
    }

    final routeClass = '${_toPascalCase(featureName)}Route';
    final routeEntry = '        AutoRoute(page: $routeClass.page),';
    final contents = routerFile.readAsStringSync();
    if (contents.contains(routeEntry)) {
      return;
    }

    final updated = contents.replaceFirst('      ];', '$routeEntry\n      ];');
    routerFile.writeAsStringSync(updated);
  }

  void _writeFeatureSpecContract({
    required String projectPath,
    required String featureName,
    required FeatureSpec spec,
  }) {
    final featurePascal = _toPascalCase(featureName);
    final file = File(
      p.join(projectPath, 'lib/features/$featureName/${featureName}_spec.dart'),
    );
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('''
final class ${featurePascal}FeatureSpec {
  const ${featurePascal}FeatureSpec._();

  static const feature = '${spec.feature}';
  static const title = '${_escape(_toTitleCase(spec.feature))}';
  static const description = '${_escape(spec.description)}';
  static const acceptanceCriteria = <String>[
${spec.acceptanceCriteria.map((value) => "    '${_escape(value)}',").join('\n')}
  ];
  static const edgeCases = <String>[
${spec.edgeCases.map((value) => "    '${_escape(value)}',").join('\n')}
  ];
}
''');
  }

  void _writeFeatureSpecTest({
    required String projectPath,
    required String projectName,
    required FeatureSpec spec,
  }) {
    final featureSnake = _toSnakeCase(spec.feature);
    final file = File(
      p.join(
        projectPath,
        'test/features/$featureSnake/${featureSnake}_spec_contract_test.dart',
      ),
    );
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      TestGenerator.generateFeatureSpecContractTest(spec, projectName),
    );
  }

  String _toPascalCase(String value) {
    return value
        .split('_')
        .map(
          (part) =>
              part.isEmpty
                  ? ''
                  : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join();
  }

  String _toSnakeCase(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), '_').toLowerCase();
  }

  String _toTitleCase(String value) {
    return value
        .split(RegExp(r'[_\s]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _escape(String value) {
    return value
        .replaceAll(String.fromCharCode(92), r'\\')
        .replaceAll("'", r"\'");
  }
}
