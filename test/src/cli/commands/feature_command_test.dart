import 'dart:io';

import 'package:agentic_base/src/cli/commands/feature_command.dart';
import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/tui/agentic_logger.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('FeatureCommand', () {
    late Directory tempDir;
    late CommandRunner<int> runner;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('feature-command-test-');
      _seedAgenticProject(tempDir.path);
      runner = CommandRunner<int>('agentic_base', 'test runner')..addCommand(
        FeatureCommand(
          logger: AgenticLogger(),
          projectPathProvider: () => tempDir.path,
        ),
      );
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test(
      'fails fast for full feature scaffolds when shared host contracts are missing',
      () async {
        final exitCode = await runner.run(['feature', 'user_profile']);

        expect(exitCode, equals(1));
        expect(
          Directory(
            p.join(tempDir.path, 'lib/features/user_profile'),
          ).existsSync(),
          isFalse,
        );
      },
    );

    test(
      'allows simple feature scaffolds without the full shared host contract',
      () async {
        final exitCode = await runner.run([
          'feature',
          'user_profile',
          '--simple',
        ]);

        expect(exitCode, equals(0));
        expect(
          File(
            p.join(
              tempDir.path,
              'lib/features/user_profile/user_profile_state.dart',
            ),
          ).existsSync(),
          isTrue,
        );
      },
    );

    test(
      'generates full features after the shared host contract is present',
      () async {
        _seedFullFeatureHost(tempDir.path);

        final exitCode = await runner.run(['feature', 'user_profile']);

        expect(exitCode, equals(0));
        expect(
          File(
            p.join(
              tempDir.path,
              'lib/features/user_profile/domain/repositories/user_profile_repository.dart',
            ),
          ).existsSync(),
          isTrue,
        );
      },
    );
  });
}

void _seedAgenticProject(String projectPath) {
  AgenticConfig.createInitial(
    projectPath: projectPath,
    projectName: 'demo_app',
    org: 'com.example',
    stateManagement: 'cubit',
    platforms: ['android', 'ios'],
    flavors: ['dev', 'staging', 'prod'],
    toolVersion: 'test',
  );
  File(p.join(projectPath, 'pubspec.yaml'))
    ..createSync(recursive: true)
    ..writeAsStringSync(
      'name: demo_app\ndependencies:\n  flutter:\n    sdk: flutter\n',
    );
}

void _seedFullFeatureHost(String projectPath) {
  File(p.join(projectPath, 'lib/core/contracts/app_result.dart'))
    ..createSync(recursive: true)
    ..writeAsStringSync('typedef AppResult<T> = T;\n');
  File(p.join(projectPath, 'lib/core/error/error_handler.dart'))
    ..createSync(recursive: true)
    ..writeAsStringSync('class ErrorHandler {}\n');
  File(p.join(projectPath, 'lib/core/error/failures.dart'))
    ..createSync(recursive: true)
    ..writeAsStringSync('sealed class AppFailure {}\n');
  File(p.join(projectPath, 'pubspec.yaml')).writeAsStringSync(
    'name: demo_app\ndependencies:\n  flutter:\n    sdk: flutter\n  fpdart: ^1.1.1\n',
  );
}
