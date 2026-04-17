import 'dart:io';

import 'package:agentic_base/src/cli/commands/create_command.dart';
import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/harness_profile.dart';
import 'package:agentic_base/src/generators/project_generator.dart';
import 'package:agentic_base/src/modules/module_registry.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAgenticLogger extends Mock implements AgenticLogger {}

class RecordingProjectGenerator extends ProjectGenerator {
  RecordingProjectGenerator() : super(logger: AgenticLogger());

  bool previewInvoked = false;
  bool generateInvoked = false;
  String? projectName;
  String? outputDirectory;
  String? org;
  List<String>? platforms;
  String? stateManagement;
  List<String>? flavors;
  CiProvider? ciProvider;
  HarnessAppProfile? appProfile;
  FlutterSdkManager? flutterSdkManager;
  String? flutterSdkVersion;
  List<String>? secondaryTraits;
  List<String>? modules;

  @override
  Future<void> previewGenerate({
    required String projectName,
    required String outputDirectory,
    required String org,
    required List<String> platforms,
    required String stateManagement,
    required List<String> flavors,
    required CiProvider ciProvider,
    required HarnessAppProfile appProfile,
    required FlutterSdkManager flutterSdkManager,
    String? flutterSdkVersion,
    List<String> secondaryTraits = const [],
    List<String>? modules,
  }) async {
    previewInvoked = true;
    this.projectName = projectName;
    this.outputDirectory = outputDirectory;
    this.modules = modules == null ? null : List.of(modules);
    this.appProfile = appProfile;
  }

  @override
  Future<void> generate({
    required String projectName,
    required String outputDirectory,
    required String org,
    required List<String> platforms,
    required String stateManagement,
    required List<String> flavors,
    required CiProvider ciProvider,
    required HarnessAppProfile appProfile,
    required FlutterSdkManager flutterSdkManager,
    String? flutterSdkVersion,
    List<String> secondaryTraits = const [],
    List<String>? modules,
    bool runVerify = true,
  }) async {
    generateInvoked = true;
    this.projectName = projectName;
    this.outputDirectory = outputDirectory;
    this.org = org;
    this.platforms = List.of(platforms);
    this.stateManagement = stateManagement;
    this.flavors = List.of(flavors);
    this.ciProvider = ciProvider;
    this.appProfile = appProfile;
    this.flutterSdkManager = flutterSdkManager;
    this.flutterSdkVersion = flutterSdkVersion;
    this.secondaryTraits = List.of(secondaryTraits);
    this.modules = modules == null ? null : List.of(modules);
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
      expect(command.argParser.options.keys, isNot(contains('primary-color')));
      expect(command.argParser.options.keys, contains('ci-provider'));
      expect(command.argParser.options.keys, contains('app-profile'));
      expect(command.argParser.options.keys, contains('traits'));
      expect(command.argParser.options.keys, contains('flutter-sdk-manager'));
      expect(command.argParser.options.keys, contains('flutter-version'));
      expect(command.argParser.options.keys, contains('no-interactive'));
      expect(command.argParser.options.keys, contains('dry-run'));
    });

    test('uses preview mode for dry runs', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'create-command-dry-run-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final exitCode = await runner.run([
        'create',
        'demo_app',
        '--dry-run',
        '--no-interactive',
        '--output-dir',
        tempDir.path,
      ]);

      expect(exitCode, equals(0));
      expect(recordingGenerator.previewInvoked, isTrue);
      expect(recordingGenerator.generateInvoked, isFalse);
      expect(
        recordingGenerator.outputDirectory,
        endsWith('${Platform.pathSeparator}demo_app'),
      );
    });

    test('state option defaults to cubit', () {
      final args = command.argParser.parse([]);
      expect(args['state'], equals('cubit'));
    });

    test('app-profile defaults to subscription-commerce-app', () {
      final args = command.argParser.parse([]);
      expect(
        args['app-profile'],
        equals(HarnessAppProfile.subscriptionCommerceApp.wireName),
      );
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
      'keeps module resolution deferred when the caller does not override it',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'create-command-default-profile-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final exitCode = await runner.run([
          'create',
          'demo_app',
          '--no-interactive',
          '--output-dir',
          tempDir.path,
        ]);

        expect(exitCode, equals(0));
        expect(
          recordingGenerator.appProfile,
          equals(HarnessAppProfile.subscriptionCommerceApp),
        );
        expect(recordingGenerator.modules, isNull);
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

    test('passes harness profile, traits, and SDK manager through', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'create-command-harness-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final exitCode = await runner.run([
        'create',
        'demo_app',
        '--no-interactive',
        '--output-dir',
        tempDir.path,
        '--app-profile',
        'offline-first-field-app',
        '--traits',
        'offline-first,geo-aware',
        '--flutter-sdk-manager',
        'fvm',
        '--flutter-version',
        '3.29.0',
      ]);

      expect(exitCode, equals(0));
      expect(
        recordingGenerator.appProfile,
        equals(HarnessAppProfile.offlineFirstFieldApp),
      );
      expect(
        recordingGenerator.secondaryTraits,
        equals(['offline-first', 'geo-aware']),
      );
      expect(
        recordingGenerator.flutterSdkManager,
        equals(FlutterSdkManager.fvm),
      );
      expect(recordingGenerator.flutterSdkVersion, equals('3.29.0'));
    });

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

    test('rejects unknown modules before preview starts', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'create-command-invalid-modules-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final exitCode = await runner.run([
        'create',
        'demo_app',
        '--dry-run',
        '--no-interactive',
        '--output-dir',
        tempDir.path,
        '--modules',
        'analytics,unknown_module',
      ]);

      expect(exitCode, equals(1));
      expect(recordingGenerator.previewInvoked, isFalse);
      expect(recordingGenerator.generateInvoked, isFalse);
      verify(
        () => mockLogger.err(
          'Unknown module(s): unknown_module. '
          'Available: ${ModuleRegistry.allNames.join(', ')}',
        ),
      ).called(1);
    });
  });
}
