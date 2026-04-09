import 'dart:io';

import 'package:agentic_base/src/cli/cli_runner.dart';

Future<void> main(List<String> args) async {
  await _flushThenExit(await AgenticBaseCliRunner().run(args));
}

/// Flushes stdout/stderr then exits with [status].
Future<void> _flushThenExit(int status) async {
  await Future.wait<void>([stdout.flush(), stderr.flush()]);
  exit(status);
}
