import 'dart:io';

import 'package:agentic_base/src/modules/extended/notifications_module.dart';
import 'package:agentic_base/src/modules/project_context.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _basePodfile = '''
# Uncomment this line to define a global platform for your project
# platform :ios, '13.0'

target 'Runner' do
  use_frameworks!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
''';

Future<String> _seedProject() async {
  final tempDir = await Directory.systemTemp.createTemp(
    'notifications-module-test-',
  );
  addTearDown(() => tempDir.delete(recursive: true));

  await File(p.join(tempDir.path, 'pubspec.yaml')).writeAsString(
    'name: demo_app\ndependencies:\n  flutter:\n    sdk: flutter\n',
  );
  await File(
    p.join(tempDir.path, 'ios/Podfile'),
  ).create(recursive: true);
  await File(p.join(tempDir.path, 'ios/Podfile')).writeAsString(_basePodfile);

  return tempDir.path;
}

ProjectContext _context(String projectPath) => ProjectContext(
  projectPath: projectPath,
  projectName: 'demo_app',
  stateManagement: 'cubit',
  installedModules: const [],
);

void _expectNotificationsPodfilePatch(String podfile) {
  expect(podfile, contains("platform :ios, '15.0'"));
  expect(podfile, contains('use_modular_headers!'));
  expect(podfile, contains('update_awesome_pod_build_settings(installer)'));
  expect(
    podfile,
    contains("update_awesome_main_target_settings('Runner'"),
  );
}

void main() {
  group('NotificationsModule', () {
    test('patches iOS Podfile after dependency refresh', () async {
      final projectPath = await _seedProject();
      final podfile = File(p.join(projectPath, 'ios/Podfile'));
      const module = NotificationsModule();

      await module.install(_context(projectPath));
      _expectNotificationsPodfilePatch(podfile.readAsStringSync());

      podfile.writeAsStringSync(_basePodfile);
      await module.afterDependencyRefresh(_context(projectPath));
      final refreshedPatch = podfile.readAsStringSync();

      _expectNotificationsPodfilePatch(refreshedPatch);

      await module.afterDependencyRefresh(_context(projectPath));
      final idempotentPatch = podfile.readAsStringSync();
      expect(
        'update_awesome_pod_build_settings(installer)'.allMatches(
          idempotentPatch,
        ),
        hasLength(1),
      );
      expect(
        "update_awesome_main_target_settings('Runner'".allMatches(
          idempotentPatch,
        ),
        hasLength(1),
      );
    });
  });
}
