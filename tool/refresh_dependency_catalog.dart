import 'dart:io';

import 'package:agentic_base/src/modules/module_dependency_catalog.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

Future<void> main(List<String> args) async {
  final write = args.contains('--write');
  final repoRoot = Directory.current.path;
  final brickPubspec = File(
    p.join(
      repoRoot,
      'bricks',
      'agentic_app',
      '__brick__',
      '{{project_name.snakeCase()}}',
      'pubspec.yaml',
    ),
  );
  if (!brickPubspec.existsSync()) {
    stderr.writeln('Run this script from the agentic_base repo root.');
    exitCode = 64;
    return;
  }

  final parsed = loadYaml(brickPubspec.readAsStringSync());
  if (parsed is! YamlMap) {
    stderr.writeln('Could not parse ${brickPubspec.path}.');
    exitCode = 65;
    return;
  }

  final runtimePackages = _packageNames(parsed['dependencies']);
  final devPackages = _packageNames(parsed['dev_dependencies']);
  final catalogPackages = moduleDependencyConstraints.keys.toList()..sort();

  final report =
      StringBuffer()
        ..writeln('# Dependency Catalog Refresh Report')
        ..writeln()
        ..writeln('- date: ${DateTime.now().toUtc().toIso8601String()}')
        ..writeln('- mode: ${write ? 'write' : 'report-only'}')
        ..writeln('- baseline dependencies: ${runtimePackages.length}')
        ..writeln('- baseline dev_dependencies: ${devPackages.length}')
        ..writeln('- module catalog entries: ${catalogPackages.length}')
        ..writeln()
        ..writeln('Run these checks before changing constraints:')
        ..writeln('1. `dart pub outdated` in a generated temp app')
        ..writeln('2. `dart pub upgrade --major-versions` in that temp app')
        ..writeln('3. `./tools/verify.sh` in the generated app')
        ..writeln('4. package `dart test` in this repo')
        ..writeln()
        ..writeln('Catalog packages:');
  for (final package in catalogPackages) {
    report.writeln('- $package: ${moduleDependencyConstraints[package]}');
  }

  if (write) {
    report
      ..writeln()
      ..writeln(
        'No automatic mutation was performed. Update constraints only after '
        'the generated-app verification evidence is attached to the release.',
      );
  }
  stdout.write(report);
}

List<String> _packageNames(dynamic raw) {
  if (raw is! YamlMap) return const <String>[];
  final names =
      raw.keys
          .map((key) => key.toString())
          .where((name) => name != 'flutter')
          .toList()
        ..sort();
  return names;
}
