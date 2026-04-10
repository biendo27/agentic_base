import 'dart:io';

import 'package:agentic_base/src/config/ci_provider.dart';
import 'package:agentic_base/src/generators/generated_project_contract.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

bool _isFlutterAvailable() {
  try {
    return Process.runSync('flutter', ['--version']).exitCode == 0;
  } on ProcessException {
    return false;
  }
}

void main() {
  final flutterAvailable = _isFlutterAvailable();
  for (final ciProvider in ['github', 'gitlab']) {
    test(
      'create command generates a $ciProvider starter app that matches the ownership contract',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'agentic-base-smoke-$ciProvider-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final appName = 'smoke_${ciProvider}_app';
        final result = await Process.run(
          'dart',
          [
            'run',
            'bin/agentic_base.dart',
            'create',
            appName,
            '--no-interactive',
            '--output-dir',
            tempDir.path,
            '--ci-provider',
            ciProvider,
          ],
          workingDirectory: Directory.current.path,
        );

        expect(
          result.exitCode,
          equals(0),
          reason: '${result.stdout}\n${result.stderr}',
        );

        final appDir = p.join(tempDir.path, appName);
        expect(Directory(appDir).existsSync(), isTrue);
        expect(
          () => GeneratedProjectContract.validate(
            appDir,
            ciProvider: parseCiProvider(ciProvider),
          ),
          returnsNormally,
        );
      },
      skip:
          flutterAvailable
              ? false
              : 'Flutter SDK is required for smoke generation.',
      timeout: const Timeout(Duration(minutes: 4)),
    );
  }
}
