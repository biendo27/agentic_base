import 'dart:io';

import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

Future<void> run(HookContext context) async {
  final logger = context.logger;
  final projectName = context.vars['project_name'] as String;

  // Resolve to absolute path to avoid issues with CWD changes
  final workDir = p.join(Directory.current.path, projectName);
  final progress = logger.progress('Running flutter pub get');

  final result = await Process.run(
    'flutter',
    ['pub', 'get'],
    workingDirectory: workDir,
  );

  if (result.exitCode != 0) {
    progress.fail('flutter pub get failed');
    logger.err(result.stderr.toString());
    return;
  }

  progress.complete('Dependencies installed');

  logger.info('');
  logger.info('Generated project: $projectName');
  logger.info('Next steps:');
  logger.info('  cd $projectName');
  logger.info('  dart run build_runner build --delete-conflicting-outputs');
}
