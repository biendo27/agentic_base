import 'dart:io';

import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/flutter_toolchain_runtime.dart';
import 'package:test/test.dart';

void main() {
  group('resolveFlutterToolchain', () {
    test('uses the preferred manager when it is executable', () {
      final toolchain = resolveFlutterToolchain(
        projectPath: '/tmp/demo',
        preferredManager: FlutterSdkManager.fvm,
        preferredVersion: '3.29.0',
        detector: ({
          required manager,
          required projectPath,
        }) {
          return _detection(
            manager: manager,
            available: manager == FlutterSdkManager.fvm,
            version: manager == FlutterSdkManager.fvm ? '3.41.6' : null,
          );
        },
      );

      expect(toolchain.source, FlutterToolchainResolutionSource.preferred);
      expect(toolchain.contract.manager, FlutterSdkManager.fvm);
      expect(toolchain.contract.preferredManager, FlutterSdkManager.fvm);
      expect(toolchain.contract.version, '3.41.6');
      expect(toolchain.contract.preferredVersion, '3.29.0');
      expect(
        toolchain.flutterCommand(['pub', 'get']).toString(),
        'fvm flutter pub get',
      );
      expect(
        toolchain.dartCommand(['format', 'lib']).toString(),
        'fvm dart format lib',
      );
    });

    test(
      'falls back to the inferred manager when preferred is unavailable',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'flutter-toolchain-inferred-',
        );
        addTearDown(() => tempDir.delete(recursive: true));
        File('${tempDir.path}/.fvmrc').writeAsStringSync('stable\n');

        final toolchain = resolveFlutterToolchain(
          projectPath: tempDir.path,
          preferredManager: FlutterSdkManager.puro,
          detector: ({
            required manager,
            required projectPath,
          }) {
            return _detection(
              manager: manager,
              available: manager == FlutterSdkManager.fvm,
              version: manager == FlutterSdkManager.fvm ? '3.41.6' : null,
            );
          },
        );

        expect(toolchain.source, FlutterToolchainResolutionSource.inferred);
        expect(toolchain.contract.manager, FlutterSdkManager.fvm);
        expect(toolchain.contract.preferredManager, FlutterSdkManager.puro);
      },
    );

    test(
      'falls back to system when preferred and inferred managers are unavailable',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'flutter-toolchain-system-',
        );
        addTearDown(() => tempDir.delete(recursive: true));
        File('${tempDir.path}/.puro.json').writeAsStringSync('{}');

        final toolchain = resolveFlutterToolchain(
          projectPath: tempDir.path,
          preferredManager: FlutterSdkManager.fvm,
          detector: ({
            required manager,
            required projectPath,
          }) {
            return _detection(
              manager: manager,
              available: manager == FlutterSdkManager.system,
              version: manager == FlutterSdkManager.system ? '3.41.6' : null,
            );
          },
        );

        expect(
          toolchain.source,
          FlutterToolchainResolutionSource.systemFallback,
        );
        expect(toolchain.contract.manager, FlutterSdkManager.system);
        expect(toolchain.contract.preferredManager, FlutterSdkManager.fvm);
      },
    );

    test('throws when no executable toolchain exists', () {
      expect(
        () => resolveFlutterToolchain(
          projectPath: '/tmp/demo',
          preferredManager: FlutterSdkManager.fvm,
          detector: ({
            required manager,
            required projectPath,
          }) {
            return _detection(
              manager: manager,
              available: false,
              problem: '${manager.wireName} missing',
            );
          },
        ),
        throwsA(
          isA<FlutterToolchainResolutionException>().having(
            (error) => error.message,
            'message',
            contains('No executable Flutter SDK was found'),
          ),
        ),
      );
    });
  });
}

DetectedFlutterToolchain _detection({
  required FlutterSdkManager manager,
  required bool available,
  String? version,
  String? channel,
  String? problem,
}) {
  return DetectedFlutterToolchain(
    manager: manager,
    version: version,
    channel: channel ?? 'stable',
    available: available,
    command: manager.wireName,
    problem: problem,
  );
}
