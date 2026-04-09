import 'package:agentic_base/src/config/spec_parser.dart';
import 'package:test/test.dart';

void main() {
  group('SpecParser', () {
    test('parses valid spec YAML', () {
      const yaml = '''
feature: user_authentication
description: Implement user login with email and password
acceptance_criteria:
  - User can login with valid email/password
  - User receives error on invalid credentials
  - Session persists after login
edge_cases:
  - Empty email field
  - Very long password
''';

      final spec = SpecParser.parse(yaml);

      expect(spec.feature, equals('user_authentication'));
      expect(spec.description, contains('user login'));
      expect(spec.acceptanceCriteria.length, equals(3));
      expect(spec.edgeCases.length, equals(2));
    });

    test('throws FormatException when missing feature field', () {
      const yaml = '''
description: Some description
acceptance_criteria:
  - Criterion 1
''';

      expect(
        () => SpecParser.parse(yaml),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('feature'),
        )),
      );
    });

    test('throws FormatException when missing description field', () {
      const yaml = '''
feature: some_feature
acceptance_criteria:
  - Criterion 1
''';

      expect(
        () => SpecParser.parse(yaml),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('description'),
        )),
      );
    });

    test('throws FormatException for empty feature field', () {
      const yaml = '''
feature: ""
description: Some description
acceptance_criteria:
  - Criterion 1
''';

      expect(
        () => SpecParser.parse(yaml),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for empty description field', () {
      const yaml = '''
feature: some_feature
description: ""
acceptance_criteria:
  - Criterion 1
''';

      expect(
        () => SpecParser.parse(yaml),
        throwsA(isA<FormatException>()),
      );
    });

    test('allows empty acceptance_criteria list', () {
      const yaml = '''
feature: some_feature
description: Some description
acceptance_criteria: []
''';

      final spec = SpecParser.parse(yaml);

      expect(spec.feature, equals('some_feature'));
      expect(spec.acceptanceCriteria, isEmpty);
    });

    test('handles missing acceptance_criteria field', () {
      const yaml = '''
feature: some_feature
description: Some description
''';

      final spec = SpecParser.parse(yaml);

      expect(spec.acceptanceCriteria, isEmpty);
    });

    test('allows empty edge_cases list', () {
      const yaml = '''
feature: some_feature
description: Some description
acceptance_criteria:
  - Criterion 1
edge_cases: []
''';

      final spec = SpecParser.parse(yaml);

      expect(spec.edgeCases, isEmpty);
    });

    test('handles missing edge_cases field', () {
      const yaml = '''
feature: some_feature
description: Some description
acceptance_criteria:
  - Criterion 1
''';

      final spec = SpecParser.parse(yaml);

      expect(spec.edgeCases, isEmpty);
    });

    test('throws FormatException for non-YAML-map root', () {
      const yaml = '''
- item 1
- item 2
''';

      expect(
        () => SpecParser.parse(yaml),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('expected a YAML mapping'),
        )),
      );
    });

    test('throws FormatException when acceptance_criteria is not a list', () {
      const yaml = '''
feature: some_feature
description: Some description
acceptance_criteria: "not a list"
''';

      expect(
        () => SpecParser.parse(yaml),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('must be a YAML list'),
        )),
      );
    });

    test('throws FormatException when edge_cases is not a list', () {
      const yaml = '''
feature: some_feature
description: Some description
edge_cases: "not a list"
''';

      expect(
        () => SpecParser.parse(yaml),
        throwsA(isA<FormatException>()),
      );
    });

    test('parses spec with multiple acceptance criteria', () {
      const yaml = '''
feature: payment_processing
description: Process user payments
acceptance_criteria:
  - User can input payment amount
  - System validates amount
  - Payment is submitted to gateway
  - Confirmation is displayed
  - Transaction is logged
''';

      final spec = SpecParser.parse(yaml);

      expect(spec.acceptanceCriteria.length, equals(5));
      expect(spec.acceptanceCriteria.first, contains('input'));
    });

    test('parses spec with multiple edge cases', () {
      const yaml = '''
feature: some_feature
description: Some description
acceptance_criteria:
  - Criterion 1
edge_cases:
  - Zero amount payment
  - Negative amount
  - Decimal precision
  - Currency conversion
''';

      final spec = SpecParser.parse(yaml);

      expect(spec.edgeCases.length, equals(4));
    });

    test('converts list items to strings', () {
      const yaml = '''
feature: some_feature
description: Some description
acceptance_criteria:
  - Item 1
  - Item 2
edge_cases:
  - Edge 1
  - Edge 2
''';

      final spec = SpecParser.parse(yaml);

      expect(spec.acceptanceCriteria, everyElement(isA<String>()));
      expect(spec.edgeCases, everyElement(isA<String>()));
    });

    test('preserves text content from YAML', () {
      const yaml = '''
feature: user signup
description: Allow users to create a new account
acceptance_criteria:
  - User enters email and password
  - Email validation is performed
  - User receives confirmation email
''';

      final spec = SpecParser.parse(yaml);

      expect(spec.feature, equals('user signup'));
      expect(spec.description, equals('Allow users to create a new account'));
      expect(spec.acceptanceCriteria.first, equals('User enters email and password'));
    });
  });
}
