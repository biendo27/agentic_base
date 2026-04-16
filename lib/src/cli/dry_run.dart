import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/flutter_toolchain_runtime.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/args.dart';

const dryRunFlagName = 'dry-run';

void addDryRunFlag(
  ArgParser parser, {
  String help =
      'Preview the command without writing files, running tools, or '
          'triggering remote side effects.',
}) {
  parser.addFlag(
    dryRunFlagName,
    negatable: false,
    help: help,
  );
}

bool isDryRunEnabled(ArgResults argResults) =>
    argResults[dryRunFlagName] == true;

final class DryRunReporter {
  DryRunReporter({
    required AgenticLogger logger,
    required String commandName,
  }) : _logger = logger {
    _logger.header('Dry run: $commandName');
  }

  final AgenticLogger _logger;

  void note(String message) => _logger.info('  - $message');

  void read(String path) => note('would read $path');

  void write(String path) => note('would write $path');

  void create(String path) => note('would create $path');

  void delete(String path) => note('would delete $path');

  void command(
    ToolCommandSpec command, {
    String? workingDirectory,
    String? label,
  }) {
    final prefix = label == null ? 'would run' : 'would $label';
    final location =
        workingDirectory == null ? '' : ' (cwd: $workingDirectory)';
    note('$prefix `$command`$location');
  }

  void remote(String message) => note('would call remote workflow: $message');

  void toolchainContract(FlutterSdkContract contract) {
    note(
      'would use declared Flutter manager '
      '`${contract.preferredManager.wireName}` in preview mode '
      '(no toolchain probing)',
    );
  }

  int complete() {
    _logger.success('Dry run complete. No changes were made.');
    return 0;
  }
}
