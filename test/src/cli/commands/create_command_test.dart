import 'dart:io';

import 'package:agentic_base/src/cli/commands/create_command.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/generators/project_generator.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAgenticLogger extends Mock implements AgenticLogger {}

class RecordingProjectGenerator extends ProjectGenerator {
  RecordingProjectGenerator() : super(logger: AgenticLogger());

  String? projectName;
  String? outputDirectory;
  String? org;
  List<String>? platforms;
  String? stateManagement;
  List<String>? flavors;
  String? primaryColor;
  CiProvider? ciProvider;
  List<String>? modules;

  @override
  Future<void> generate({
    required String projectName,
    required String outputDirectory,
    required String org,
    required List<String> platforms,
    required String stateManagement,
    required List<String> flavors,
    required String primaryColor,
    required CiProvider ciProvider,
    List<String> modules = const [],
  }) async {
    this.projectName = projectName;
    this.outputDirectory = outputDirectory;
    this.org = org;
    this.platforms = List.of(platforms);
    this.stateManagement = stateManagement;
    this.flavors = List.of(flavors);
    this.primaryColor = primaryColor;
    this.ciProvider = ciProvider;
    this.modules = List.of(modules);
  }
}

void main() {
  group('CreateCommand', () {
    late MockAgenticLogger mockLogger;
    late RecordingProjectGenerator recordingGenerator;
    late CreateCommand command;
    late CommandRunner<int> runner;

    setUp(() {
      mockLogger = MockAgenticLogger();
      recordingGenerator = RecordingProjectGenerator();
      command = CreateCommand(
        logger: mockLogger,
        projectGeneratorBuilder: (_) => recordingGenerator,
      );
      runner = CommandRunner<int>('agentic_base', 'test runner')
        ..addCommand(command);
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
      expect(command.argParser.options.keys, contains('ci-provider'));
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
      expect(
        RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch('com.example'),
        true,
      );
      expect(
        RegExp(
          r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$',
        ).hasMatch('com.example.app'),
        true,
      );

      // Invalid org format
      expect(
        RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch('invalid_org'),
        false,
      );
      expect(
        RegExp(
          r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$',
        ).hasMatch('com.example_org'),
        false,
      );
      expect(
        RegExp(r'^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$').hasMatch('ComExample'),
        false,
      );
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

    test(
      'passes ci-provider through to the project generator',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'create-command-provider-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final exitCode = await runner.run([
          'create',
          'demo_app',
          '--no-interactive',
          '--output-dir',
          tempDir.path,
          '--ci-provider',
          'gitlab',
        ]);

        expect(exitCode, equals(0));
        expect(recordingGenerator.ciProvider, equals(CiProvider.gitlab));
      },
    );

    test(
      'normalizes comma-separated platforms and modules before generation',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'create-command-normalization-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final exitCode = await runner.run([
          'create',
          'demo_app',
          '--no-interactive',
          '--output-dir',
          tempDir.path,
          '--platforms',
          ' ios, web , ios ',
          '--modules',
          ' analytics, logging ,, analytics ',
        ]);

        expect(exitCode, equals(0));
        expect(recordingGenerator.platforms, equals(['ios', 'web']));
        expect(recordingGenerator.modules, equals(['analytics', 'logging']));
      },
    );

    test(
      'normalizes default flavors back to the stable contract order',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'create-command-flavors-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final exitCode = await runner.run([
          'create',
          'demo_app',
          '--no-interactive',
          '--output-dir',
          tempDir.path,
          '--flavors',
          'prod, dev, staging',
        ]);

        expect(exitCode, equals(0));
        expect(recordingGenerator.flavors, equals(['dev', 'staging', 'prod']));
      },
    );

    test(
      'rejects unsupported custom flavors before generation starts',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'create-command-invalid-flavors-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final exitCode = await runner.run([
          'create',
          'demo_app',
          '--no-interactive',
          '--output-dir',
          tempDir.path,
          '--flavors',
          'qa,prod',
        ]);

        expect(exitCode, equals(1));
        expect(recordingGenerator.flavors, isNull);
        verify(
          () => mockLogger.err(
            'Only the default flavor contract is supported: dev, staging, prod.',
          ),
        ).called(1);
      },
    );
  });
}
