import 'package:agentic_base/src/cli/commands/add_command.dart';
import 'package:agentic_base/src/cli/commands/brick_command.dart';
import 'package:agentic_base/src/cli/commands/create_command.dart';
import 'package:agentic_base/src/cli/commands/deploy_command.dart';
import 'package:agentic_base/src/cli/commands/doctor_command.dart';
import 'package:agentic_base/src/cli/commands/eval_command.dart';
import 'package:agentic_base/src/cli/commands/feature_command.dart';
import 'package:agentic_base/src/cli/commands/gen_command.dart';
import 'package:agentic_base/src/cli/commands/init_command.dart';
import 'package:agentic_base/src/cli/commands/inspect_command.dart';
import 'package:agentic_base/src/cli/commands/remove_command.dart';
import 'package:agentic_base/src/cli/commands/upgrade_command.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

/// CLI runner for agentic_base tool.
class AgenticBaseCliRunner extends CommandRunner<int> {
  AgenticBaseCliRunner({AgenticLogger? logger})
    : _logger = logger ?? AgenticLogger(),
      super(
        'agentic_base',
        'Generate agent-ready Flutter repositories with canonical context '
            'and deterministic workflows.',
      ) {
    argParser.addFlag(
      'version',
      abbr: 'v',
      negatable: false,
      help: 'Print the current version.',
    );
    addCommand(AddCommand(logger: _logger));
    addCommand(BrickCommand(logger: _logger));
    addCommand(CreateCommand(logger: _logger));
    addCommand(DeployCommand(logger: _logger));
    addCommand(DoctorCommand(logger: _logger));
    addCommand(EvalCommand(logger: _logger));
    addCommand(FeatureCommand(logger: _logger));
    addCommand(GenCommand(logger: _logger));
    addCommand(InitCommand(logger: _logger));
    addCommand(InspectCommand(logger: _logger));
    addCommand(RemoveCommand(logger: _logger));
    addCommand(UpgradeCommand(logger: _logger));
  }

  final AgenticLogger _logger;

  static const String version = '0.2.2';

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final topLevelResults = parse(args);
      if (topLevelResults['version'] == true) {
        _logger.info('agentic_base v$version');
        return ExitCode.success.code;
      }
      return await runCommand(topLevelResults) ?? ExitCode.success.code;
    } on FormatException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(usage);
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      _logger
        ..err(e.message)
        ..info('')
        ..info(e.usage);
      return ExitCode.usage.code;
    } on Exception catch (error) {
      _logger.err('$error');
      return ExitCode.software.code;
    }
  }
}
