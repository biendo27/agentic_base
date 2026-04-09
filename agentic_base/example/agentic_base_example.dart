// This is a CLI tool. See README.md for usage.
//
// Quick start:
//   dart pub global activate agentic_base
//   agentic_base create my_app --org com.example
//   cd my_app && agentic_base gen
//
// For programmatic usage, all public APIs are available:
//
//   - AgenticBaseCliRunner: Full CLI runner
//   - AgenticConfig: Project configuration management
//   - ModuleRegistry: Module discovery and management

import 'dart:io';

import 'package:agentic_base/agentic_base.dart';

Future<void> main() async {
  // Run the CLI with provided arguments.
  final exitCode = await AgenticBaseCliRunner().run(['--version']);
  exit(exitCode);
}
