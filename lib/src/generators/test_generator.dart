import 'package:agentic_base/src/config/spec_parser.dart';

/// Generates test file content from a [FeatureSpec].
///
/// Produces real `test()` / `blocTest()` stubs with descriptive names
/// derived directly from the spec's acceptance criteria and edge cases.
class TestGenerator {
  const TestGenerator._();

  /// Generate a bloc_test / flutter_test cubit unit test file.
  ///
  /// Each acceptance criterion becomes a `blocTest` with descriptive naming.
  /// Edge cases become additional `test()` stubs tagged with comments.
  static String generateCubitTest(FeatureSpec spec, String projectName) {
    final featureSnake = _toSnakeCase(spec.feature);
    final featurePascal = _toPascalCase(spec.feature);

    final buffer =
        StringBuffer()
          ..writeln('// ignore_for_file: prefer_const_constructors')
          ..writeln("import 'package:bloc_test/bloc_test.dart';")
          ..writeln("import 'package:flutter_test/flutter_test.dart';")
          ..writeln("import 'package:mocktail/mocktail.dart';")
          ..writeln(
            "import 'package:$projectName/features/$featureSnake/presentation/cubit/${featureSnake}_cubit.dart';",
          )
          ..writeln(
            "import 'package:$projectName/features/$featureSnake/presentation/cubit/${featureSnake}_state.dart';",
          )
          ..writeln()
          ..writeln('void main() {')
          ..writeln('  late ${featurePascal}Cubit cubit;')
          ..writeln()
          ..writeln('  setUp(() {')
          ..writeln('    cubit = ${featurePascal}Cubit();')
          ..writeln('  });')
          ..writeln()
          ..writeln('  tearDown(() => cubit.close());')
          ..writeln()
          ..writeln("  test('initial state is ${featurePascal}Initial', () {")
          ..writeln('    expect(cubit.state, isA<${featurePascal}State>());')
          ..writeln('  });');

    // Generate a blocTest for each acceptance criterion.
    for (final criterion in spec.acceptanceCriteria) {
      final testName = criterion.toLowerCase();
      buffer
        ..writeln()
        ..writeln('  // Acceptance criterion: $criterion')
        ..writeln(
          '  blocTest<${featurePascal}Cubit, ${featurePascal}State>(',
        )
        ..writeln("    '$testName',")
        ..writeln('    build: () => cubit,')
        ..writeln('    act: (c) {')
        ..writeln('      // TODO: trigger the relevant cubit method')
        ..writeln('    },')
        ..writeln('    expect: () => [')
        ..writeln('      // TODO: assert expected state transitions')
        ..writeln('    ],')
        ..writeln('  );');
    }

    // Generate edge case stubs.
    if (spec.edgeCases.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('  // --- Edge cases ---');
      for (final edgeCase in spec.edgeCases) {
        final testName = edgeCase.toLowerCase();
        buffer
          ..writeln()
          ..writeln("  test('edge case: $testName', () {")
          ..writeln('    // TODO: implement edge case scenario')
          ..writeln('    // $edgeCase')
          ..writeln('  });');
      }
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Generate a flutter_test widget test file.
  ///
  /// Verifies the page renders and that each acceptance criterion
  /// has a corresponding finder stub.
  static String generateWidgetTest(FeatureSpec spec, String projectName) {
    final featureSnake = _toSnakeCase(spec.feature);
    final featurePascal = _toPascalCase(spec.feature);

    final buffer =
        StringBuffer()
          ..writeln("import 'package:flutter/material.dart';")
          ..writeln("import 'package:flutter_test/flutter_test.dart';")
          ..writeln(
            "import 'package:$projectName/features/$featureSnake/presentation/pages/${featureSnake}_page.dart';",
          )
          ..writeln()
          ..writeln('void main() {')
          ..writeln("  group('${featurePascal}Page widget tests', () {")
          ..writeln(
            "    testWidgets('renders ${featurePascal}Page', (tester) async {",
          )
          ..writeln('      await tester.pumpWidget(')
          ..writeln(
            '        const MaterialApp(home: ${featurePascal}Page()),',
          )
          ..writeln('      );')
          ..writeln('      await tester.pumpAndSettle();')
          ..writeln(
            '      expect(find.byType(${featurePascal}Page), findsOneWidget);',
          )
          ..writeln('    });');

    for (final criterion in spec.acceptanceCriteria) {
      final testName = criterion.toLowerCase();
      buffer
        ..writeln()
        ..writeln('    // Acceptance criterion: $criterion')
        ..writeln("    testWidgets('$testName', (tester) async {")
        ..writeln('      await tester.pumpWidget(')
        ..writeln(
          '        const MaterialApp(home: ${featurePascal}Page()),',
        )
        ..writeln('      );')
        ..writeln('      await tester.pumpAndSettle();')
        ..writeln('      // TODO: assert UI elements for this criterion')
        ..writeln('    });');
    }

    buffer
      ..writeln('  });')
      ..writeln('}');

    return buffer.toString();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Convert a feature name to snake_case (handles spaces and mixed case).
  static String _toSnakeCase(String name) {
    return name
        .replaceAll(RegExp('[^a-zA-Z0-9]+'), '_')
        .replaceAllMapped(
          RegExp('([A-Z])'),
          (m) => '_${m.group(1)!.toLowerCase()}',
        )
        .replaceAll(RegExp('^_+'), '')
        .toLowerCase();
  }

  /// Convert a feature name to PascalCase.
  static String _toPascalCase(String name) {
    return name.split(RegExp('[^a-zA-Z0-9]+')).map((part) {
      if (part.isEmpty) return '';
      return part[0].toUpperCase() + part.substring(1).toLowerCase();
    }).join();
  }
}
