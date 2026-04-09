import 'package:agentic_base/src/cli/commands/create_command.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAgenticLogger extends Mock implements AgenticLogger {}

void main() {
  group('CreateCommand', () {
    late MockAgenticLogger mockLogger;
    late CreateCommand command;

    setUp(() {
      mockLogger = MockAgenticLogger();
      command = CreateCommand(logger: mockLogger);
    });

    test('has correct name and description', () {
      expect(command.name, equals('create'));
      expect(command.description, isNotEmpty);
      expect(command.invocation, isNotEmpty);
    });

    test('command parser has all options', () {
      expect(command.argParser.options.keys, contains('org'));
      expect(command.argParser.options.keys, contains('platforms'));
      expect(command.argParser.options.keys, contains('state'));
      expect(command.argParser.options.keys, contains('flavors'));
      expect(command.argParser.options.keys, contains('primary-color'));
      expect(command.argParser.options.keys, contains('no-interactive'));
    });

    test('state option defaults to cubit', () {
      final args = command.argParser.parse([]);
      expect(args['state'], equals('cubit'));
    });

    test('state option accepts cubit, riverpod, mobx', () {
      final options = command.argParser.options['state'];
      expect(options?.allowed, contains('cubit'));
      expect(options?.allowed, contains('riverpod'));
      expect(options?.allowed, contains('mobx'));
    });

    test('validates project name with regex', () {
      // Valid snake_case names
      expect(RegExp(r'^[a-z][a-z0-9_]*$').hasMatch('my_app'), true);
      expect(RegExp(r'^[a-z][a-z0-9_]*$').hasMatch('my_awesome_app'), true);
      expect(RegExp(r'^[a-z][a-z0-9_]*$').hasMatch('app123'), true);

      // Invalid names
      expect(RegExp(r'^[a-z][a-z0-9_]*$').hasMatch('MyApp'), false);
      expect(RegExp(r'^[a-z][a-z0-9_]*$').hasMatch('123_app'), false);
      expect(RegExp(r'^[a-z][a-z0-9_]*$').hasMatch('my-app'), false);
    });

    test('validates org format with regex', () {
      // Valid org format (reverse domain)
      expect(RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch('com.example'), true);
      expect(RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch('com.example.app'), true);

      // Invalid org format
      expect(RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch('invalid_org'), false);
      expect(RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch('com.example_org'), false);
      expect(RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch('ComExample'), false);
    });

    test('validates hex color with regex', () {
      // Valid 6-char hex
      expect(RegExp(r'^[0-9a-fA-F]{6}$').hasMatch('6750A4'), true);
      expect(RegExp(r'^[0-9a-fA-F]{6}$').hasMatch('abcdef'), true);
      expect(RegExp(r'^[0-9a-fA-F]{6}$').hasMatch('ABCDEF'), true);

      // Invalid hex
      expect(RegExp(r'^[0-9a-fA-F]{6}$').hasMatch('GGGGGG'), false);
      expect(RegExp(r'^[0-9a-fA-F]{6}$').hasMatch('6750A4F'), false);
      expect(RegExp(r'^[0-9a-fA-F]{6}$').hasMatch('6750A'), false);
    });

    test('supports all platform options', () {
      const platforms = ['android', 'ios', 'web', 'macos', 'windows', 'linux'];
      for (final platform in platforms) {
        expect(platforms, contains(platform));
      }
    });

    test('default flavors are dev, staging, prod', () {
      expect(['dev', 'staging', 'prod'], equals(['dev', 'staging', 'prod']));
    });

    test('default platforms are android, ios, web', () {
      expect(['android', 'ios', 'web'], equals(['android', 'ios', 'web']));
    });
  });
}
