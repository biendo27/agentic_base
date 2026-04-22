import 'dart:io';

import 'package:agentic_base/src/modules/extended/ads_module.dart';
import 'package:agentic_base/src/modules/project_context.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

Future<String> _seedProject(String plistContents) async {
  final tempDir = await Directory.systemTemp.createTemp('ads-module-test-');
  addTearDown(() => tempDir.delete(recursive: true));

  await File(p.join(tempDir.path, 'pubspec.yaml')).writeAsString(
    'name: demo_app\ndependencies:\n  flutter:\n    sdk: flutter\n',
  );
  await File(
    p.join(tempDir.path, 'android/app/src/main/AndroidManifest.xml'),
  ).create(recursive: true);
  await File(
    p.join(tempDir.path, 'android/app/src/main/AndroidManifest.xml'),
  ).writeAsString('<manifest><application></application></manifest>');
  await File(p.join(tempDir.path, 'ios/Runner/Info.plist')).create(
    recursive: true,
  );
  await File(
    p.join(tempDir.path, 'ios/Runner/Info.plist'),
  ).writeAsString(plistContents);

  return tempDir.path;
}

Future<String> _installAndReadPlist(String plistContents) async {
  final projectPath = await _seedProject(plistContents);
  await const AdsModule().install(
    ProjectContext(
      projectPath: projectPath,
      projectName: 'demo_app',
      stateManagement: 'cubit',
      installedModules: const [],
    ),
  );
  return File(p.join(projectPath, 'ios/Runner/Info.plist')).readAsStringSync();
}

void main() {
  group('AdsModule iOS plist mutation', () {
    test('inserts AdMob app id in the root plist dictionary', () async {
      final plist = await _installAndReadPlist('''
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
  <key>UIApplicationSceneManifest</key>
  <dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <false/>
  </dict>
</dict>
</plist>
''');

      expect(
        plist,
        contains(
          '<key>UIApplicationSceneManifest</key>\n'
          '  <dict>\n'
          '    <key>UIApplicationSupportsMultipleScenes</key>',
        ),
      );
      expect(plist, contains('<key>GADApplicationIdentifier</key>'));
      final keyIndex = plist.indexOf('<key>GADApplicationIdentifier</key>');
      final rootSentinelIndex = plist.indexOf(
        '</dict>\n  <key>GADApplicationIdentifier',
      );
      expect(rootSentinelIndex, greaterThanOrEqualTo(0));
      expect(keyIndex, greaterThan(rootSentinelIndex));
    });

    test('preserves an existing top-level AdMob app id', () async {
      final plist = await _installAndReadPlist('''
<plist version="1.0">
<dict>
  <key>GADApplicationIdentifier</key>
  <string>custom-app-id</string>
  <key>UIApplicationSceneManifest</key>
  <dict/>
</dict>
</plist>
''');

      expect(plist, contains('<string>custom-app-id</string>'));
      expect(
        RegExp('GADApplicationIdentifier').allMatches(plist),
        hasLength(1),
      );
    });

    test('repairs a nested AdMob app id sample entry', () async {
      final plist = await _installAndReadPlist('''
<plist version="1.0">
<dict>
  <key>UIApplicationSceneManifest</key>
  <dict>
    <key>GADApplicationIdentifier</key>
    <string>nested-sample</string>
  </dict>
</dict>
</plist>
''');

      expect(plist, isNot(contains('nested-sample')));
      expect(
        RegExp('GADApplicationIdentifier').allMatches(plist),
        hasLength(1),
      );
      expect(
        plist,
        contains(
          '<key>GADApplicationIdentifier</key>\n'
          '  <string>ca-app-pub-3940256099942544~1458002511</string>\n'
          '</dict>',
        ),
      );
    });

    test('leaves malformed plist content unchanged', () async {
      const malformed = '<plist><key>CFBundleName</key><string>demo</string>';
      final plist = await _installAndReadPlist(malformed);

      expect(plist, equals(malformed));
    });
  });
}
