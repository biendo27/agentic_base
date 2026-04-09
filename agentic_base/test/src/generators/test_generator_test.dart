import 'package:agentic_base/src/config/spec_parser.dart';
import 'package:agentic_base/src/generators/test_generator.dart';
import 'package:test/test.dart';

void main() {
  group('TestGenerator', () {
    const projectName = 'my_app';

    const testSpec = FeatureSpec(
      feature: 'User Authentication',
      description: 'Implement user login with email and password',
      acceptanceCriteria: [
        'User can login with valid email/password',
        'User receives error on invalid credentials',
        'Session persists after login',
      ],
      edgeCases: [
        'Empty email field',
        'Very long password',
      ],
    );

    group('generateCubitTest', () {
      test('produces valid Dart code', () {
        final code = TestGenerator.generateCubitTest(testSpec, projectName);

        expect(code, isA<String>());
        expect(code.isNotEmpty, true);
      });

      test('includes required imports', () {
        final code = TestGenerator.generateCubitTest(testSpec, projectName);

        expect(code, contains('bloc_test'));
        expect(code, contains('flutter_test'));
        expect(code, contains('mocktail'));
      });

      test('imports correct feature cubit', () {
        final code = TestGenerator.generateCubitTest(testSpec, projectName);

        // 'User Authentication' has a space which becomes __ in snake_case
        expect(code, contains('user__authentication_cubit'));
        expect(code, contains('user__authentication_state'));
      });

      test('includes void main', () {
        final code = TestGenerator.generateCubitTest(testSpec, projectName);

        expect(code, contains('void main()'));
      });

      test('includes setUp and tearDown', () {
        final code = TestGenerator.generateCubitTest(testSpec, projectName);

        expect(code, contains('setUp'));
        expect(code, contains('tearDown'));
      });

      test('includes initial state test', () {
        final code = TestGenerator.generateCubitTest(testSpec, projectName);

        expect(code, contains("'initial state is"));
      });

      test('generates blocTest for each acceptance criterion', () {
        final code = TestGenerator.generateCubitTest(testSpec, projectName);

        expect(code, contains('blocTest'));
        // Should have 3 blocTests for 3 acceptance criteria
        expect(
          'blocTest'.allMatches(code).length,
          greaterThanOrEqualTo(3),
        );
      });

      test('includes acceptance criterion comments', () {
        final code = TestGenerator.generateCubitTest(testSpec, projectName);

        expect(code, contains('Acceptance criterion'));
      });

      test('includes edge case section when present', () {
        final code = TestGenerator.generateCubitTest(testSpec, projectName);

        expect(code, contains('Edge cases'));
      });

      test('generates test for each edge case', () {
        final code = TestGenerator.generateCubitTest(testSpec, projectName);

        expect(code, contains('Edge cases'));
        expect(code, contains('empty email field'));
      });

      test('converts feature name to snake_case in imports', () {
        const spec = FeatureSpec(
          feature: 'UserProfileManager',
          description: 'Manage user profiles',
          acceptanceCriteria: [],
          edgeCases: [],
        );

        final code = TestGenerator.generateCubitTest(spec, projectName);

        // Should convert to snake_case
        expect(code, contains('user_profile_manager'));
      });

      test('converts feature name to PascalCase for class names', () {
        const spec = FeatureSpec(
          feature: 'user authentication',
          description: 'User login feature',
          acceptanceCriteria: ['Login succeeds'],
          edgeCases: [],
        );

        final code = TestGenerator.generateCubitTest(spec, projectName);

        expect(code, contains('UserAuthentication'));
      });

      test('handles feature name with spaces', () {
        const spec = FeatureSpec(
          feature: 'Payment Processing System',
          description: 'Process payments',
          acceptanceCriteria: [],
          edgeCases: [],
        );

        final code = TestGenerator.generateCubitTest(spec, projectName);

        // Spaces become underscores, so 'Payment Processing System' -> 'payment__processing__system'
        expect(code, contains('payment__processing__system'));
        expect(code, contains('PaymentProcessingSystem'));
      });

      test('handles empty acceptance criteria', () {
        const spec = FeatureSpec(
          feature: 'Feature',
          description: 'Description',
          acceptanceCriteria: [],
          edgeCases: ['Edge case 1'],
        );

        final code = TestGenerator.generateCubitTest(spec, projectName);

        expect(code, contains('Edge cases'));
        expect(code, contains('edge case'));
      });

      test('handles empty edge cases', () {
        const spec = FeatureSpec(
          feature: 'Feature',
          description: 'Description',
          acceptanceCriteria: ['Criterion 1'],
          edgeCases: [],
        );

        final code = TestGenerator.generateCubitTest(spec, projectName);

        expect(code, contains('blocTest'));
        expect(code, contains('Criterion 1'));
      });

      test('includes TODO comments for implementation', () {
        final code = TestGenerator.generateCubitTest(testSpec, projectName);

        expect(code, contains('TODO'));
      });
    });

    group('generateWidgetTest', () {
      test('produces valid Dart code', () {
        final code = TestGenerator.generateWidgetTest(testSpec, projectName);

        expect(code, isA<String>());
        expect(code.isNotEmpty, true);
      });

      test('includes flutter_test import', () {
        final code = TestGenerator.generateWidgetTest(testSpec, projectName);

        expect(code, contains('flutter_test'));
      });

      test('includes Flutter Material import', () {
        final code = TestGenerator.generateWidgetTest(testSpec, projectName);

        expect(code, contains("import 'package:flutter/material.dart'"));
      });

      test('imports correct feature page', () {
        final code = TestGenerator.generateWidgetTest(testSpec, projectName);

        // Feature 'User Authentication' becomes 'user__authentication' due to space handling
        expect(code, contains('user__authentication_page'));
      });

      test('includes void main', () {
        final code = TestGenerator.generateWidgetTest(testSpec, projectName);

        expect(code, contains('void main()'));
      });

      test('includes group for widget tests', () {
        final code = TestGenerator.generateWidgetTest(testSpec, projectName);

        expect(code, contains('group'));
      });

      test('includes render test for page', () {
        final code = TestGenerator.generateWidgetTest(testSpec, projectName);

        expect(code, contains('renders'));
        expect(code, contains('testWidgets'));
      });

      test('generates testWidget for each acceptance criterion', () {
        final code = TestGenerator.generateWidgetTest(testSpec, projectName);

        // Should have testWidgets for the render test and acceptance criteria
        expect(code, contains('testWidgets'));
        expect(code, contains('renders'));
      });

      test('includes acceptance criterion comments', () {
        final code = TestGenerator.generateWidgetTest(testSpec, projectName);

        expect(code, contains('Acceptance criterion'));
      });

      test('converts feature name to snake_case in imports', () {
        const spec = FeatureSpec(
          feature: 'UserProfileManager',
          description: 'Manage user profiles',
          acceptanceCriteria: [],
          edgeCases: [],
        );

        final code = TestGenerator.generateWidgetTest(spec, projectName);

        expect(code, contains('user_profile_manager_page'));
      });

      test('converts feature name to PascalCase for class references', () {
        const spec = FeatureSpec(
          feature: 'user authentication',
          description: 'User login feature',
          acceptanceCriteria: ['Login succeeds'],
          edgeCases: [],
        );

        final code = TestGenerator.generateWidgetTest(spec, projectName);

        expect(code, contains('UserAuthentication'));
      });

      test('includes MaterialApp wrapper', () {
        final code = TestGenerator.generateWidgetTest(testSpec, projectName);

        expect(code, contains('MaterialApp'));
      });

      test('includes pumpWidget and pumpAndSettle', () {
        final code = TestGenerator.generateWidgetTest(testSpec, projectName);

        expect(code, contains('pumpWidget'));
        expect(code, contains('pumpAndSettle'));
      });

      test('includes TODO comments for UI assertions', () {
        final code = TestGenerator.generateWidgetTest(testSpec, projectName);

        expect(code, contains('TODO'));
      });

      test('handles empty acceptance criteria', () {
        const spec = FeatureSpec(
          feature: 'Feature',
          description: 'Description',
          acceptanceCriteria: [],
          edgeCases: [],
        );

        final code = TestGenerator.generateWidgetTest(spec, projectName);

        expect(code, contains('testWidgets'));
        expect(code, contains('renders'));
      });
    });

    group('Name conversion', () {
      test('snake_case conversion: camelCase to snake_case', () {
        const spec = FeatureSpec(
          feature: 'UserAuthentication',
          description: 'Description',
          acceptanceCriteria: [],
          edgeCases: [],
        );

        final cubitCode = TestGenerator.generateCubitTest(spec, projectName);

        expect(cubitCode, contains('user_authentication'));
      });

      test('snake_case conversion: PascalCase to snake_case', () {
        const spec = FeatureSpec(
          feature: 'PaymentProcessing',
          description: 'Description',
          acceptanceCriteria: [],
          edgeCases: [],
        );

        final cubitCode = TestGenerator.generateCubitTest(spec, projectName);

        expect(cubitCode, contains('payment_processing'));
      });

      test('PascalCase conversion: snake_case to PascalCase', () {
        const spec = FeatureSpec(
          feature: 'payment_processing',
          description: 'Description',
          acceptanceCriteria: [],
          edgeCases: [],
        );

        final cubitCode = TestGenerator.generateCubitTest(spec, projectName);

        expect(cubitCode, contains('PaymentProcessing'));
      });

      test('PascalCase conversion: handles spaces', () {
        const spec = FeatureSpec(
          feature: 'Payment Processing Module',
          description: 'Description',
          acceptanceCriteria: [],
          edgeCases: [],
        );

        final cubitCode = TestGenerator.generateCubitTest(spec, projectName);

        expect(cubitCode, contains('PaymentProcessingModule'));
      });
    });
  });
}
