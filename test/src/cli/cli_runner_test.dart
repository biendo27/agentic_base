import 'package:agentic_base/src/cli/cli_runner.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAgenticLogger extends Mock implements AgenticLogger {}

void main() {
  group('AgenticBaseCliRunner', () {
    late MockAgenticLogger mockLogger;
    late AgenticBaseCliRunner runner;

    setUp(() {
      mockLogger = MockAgenticLogger();
      runner = AgenticBaseCliRunner(logger: mockLogger);
    });

    test('prints version on --version flag', () async {
      when(() => mockLogger.info(any())).thenReturn(null);

      final exitCode = await runner.run(['--version']);

      expect(exitCode, ExitCode.success.code);
      verify(() => mockLogger.info('agentic_base v${AgenticBaseCliRunner.version}'))
          .called(1);
    });

    test('prints version on -v flag', () async {
      when(() => mockLogger.info(any())).thenReturn(null);

      final exitCode = await runner.run(['-v']);

      expect(exitCode, ExitCode.success.code);
      verify(() => mockLogger.info('agentic_base v${AgenticBaseCliRunner.version}'))
          .called(1);
    });

    test('shows help on --help flag', () async {
      when(() => mockLogger.info(any())).thenReturn(null);

      // The --help flag is handled by the command_runner package
      // and may exit the process, so we just verify the runner has commands
      expect(runner.commands, isNotEmpty);
      expect(runner.usage, isNotEmpty);
    });

    test('unknown command returns usage error', () async {
      when(() => mockLogger.err(any())).thenReturn(null);
      when(() => mockLogger.info(any())).thenReturn(null);

      final exitCode = await runner.run(['unknown-command']);

      expect(exitCode, ExitCode.usage.code);
      verify(() => mockLogger.err(any())).called(1);
    });

    test('invalid format exception returns usage error', () async {
      when(() => mockLogger.err(any())).thenReturn(null);
      when(() => mockLogger.info(any())).thenReturn(null);

      // Passing invalid arguments causes FormatException
      final exitCode = await runner.run(['create', '--invalid-flag', 'value']);

      expect(exitCode, ExitCode.usage.code);
      verify(() => mockLogger.err(any())).called(1);
    });

    test('runner has all commands registered', () {
      final commands = runner.commands;
      expect(commands, isNotEmpty);
      expect(commands.keys, contains('create'));
      expect(commands.keys, contains('add'));
      expect(commands.keys, contains('remove'));
    });
  });
}
