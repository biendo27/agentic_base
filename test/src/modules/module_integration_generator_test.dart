import 'dart:io';

import 'package:agentic_base/src/modules/module_integration_generator.dart';
import 'package:agentic_base/src/modules/project_context.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('ModuleIntegrationGenerator', () {
    test(
      'writes get_it startup hooks and injectable annotations for detected services',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'module-integration-get-it-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        await _seedServicePair(
          tempDir.path,
          relativeDir: 'lib/services/notifications',
          contractFile: 'notifications_service.dart',
          contractType: 'NotificationsService',
          implementationFile: 'awesome_notifications_service.dart',
          implementationType: 'AwesomeNotificationsService',
          requiresInit: true,
        );

        const ModuleIntegrationGenerator().sync(
          ProjectContext(
            projectPath: tempDir.path,
            projectName: 'demo_app',
            stateManagement: 'cubit',
            installedModules: ['notifications'],
          ),
        );

        final startup =
            File(
              p.join(tempDir.path, 'lib/app/modules/module_startup.dart'),
            ).readAsStringSync();
        final implementation =
            File(
              p.join(
                tempDir.path,
                'lib/services/notifications/awesome_notifications_service.dart',
              ),
            ).readAsStringSync();

        expect(
          startup,
          contains('start: () => getIt<NotificationsService>().init(),'),
        );
        expect(
          startup,
          contains("id: 'notifications'"),
        );
        expect(
          implementation,
          contains('@LazySingleton(as: NotificationsService)'),
        );
      },
    );

    test('discovers legacy core services and required startup policy', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'module-integration-legacy-core-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      await _seedServicePair(
        tempDir.path,
        relativeDir: 'lib/core/storage',
        contractFile: 'local_storage_service.dart',
        contractType: 'LocalStorageService',
        implementationFile: 'shared_preferences_local_storage_service.dart',
        implementationType: 'SharedPreferencesLocalStorageService',
        requiresInit: true,
      );

      const ModuleIntegrationGenerator().sync(
        ProjectContext(
          projectPath: tempDir.path,
          projectName: 'demo_app',
          stateManagement: 'cubit',
          installedModules: ['local_storage'],
        ),
      );

      final startup =
          File(
            p.join(tempDir.path, 'lib/app/modules/module_startup.dart'),
          ).readAsStringSync();
      final implementation =
          File(
            p.join(
              tempDir.path,
              'lib/core/storage/shared_preferences_local_storage_service.dart',
            ),
          ).readAsStringSync();

      expect(
        startup,
        contains(
          "import 'package:demo_app/core/storage/local_storage_service.dart';",
        ),
      );
      expect(startup, contains("id: 'local_storage'"));
      expect(startup, contains('required: true'));
      expect(
        startup,
        contains('onFailure: ModuleStartupFailureBehavior.fail'),
      );
      expect(
        implementation,
        contains('@LazySingleton(as: LocalStorageService)'),
      );
    });

    test('injectable annotation insertion is idempotent', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'module-integration-idempotent-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      await _seedServicePair(
        tempDir.path,
        relativeDir: 'lib/services/notifications',
        contractFile: 'notifications_service.dart',
        contractType: 'NotificationsService',
        implementationFile: 'awesome_notifications_service.dart',
        implementationType: 'AwesomeNotificationsService',
        requiresInit: true,
      );

      final context = ProjectContext(
        projectPath: tempDir.path,
        projectName: 'demo_app',
        stateManagement: 'cubit',
        installedModules: ['notifications'],
      );
      const ModuleIntegrationGenerator()
        ..sync(context)
        ..sync(context);

      final implementation =
          File(
            p.join(
              tempDir.path,
              'lib/services/notifications/awesome_notifications_service.dart',
            ),
          ).readAsStringSync();

      expect(
        '@LazySingleton(as: NotificationsService)'.allMatches(implementation),
        hasLength(1),
      );
      expect(
        "import 'package:injectable/injectable.dart';".allMatches(
          implementation,
        ),
        hasLength(1),
      );
    });

    test(
      'writes riverpod providers and startup hooks for detected services',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'module-integration-riverpod-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        await _seedServicePair(
          tempDir.path,
          relativeDir: 'lib/services/notifications',
          contractFile: 'notifications_service.dart',
          contractType: 'NotificationsService',
          implementationFile: 'awesome_notifications_service.dart',
          implementationType: 'AwesomeNotificationsService',
          requiresInit: true,
        );

        const ModuleIntegrationGenerator().sync(
          ProjectContext(
            projectPath: tempDir.path,
            projectName: 'demo_app',
            stateManagement: 'riverpod',
            installedModules: ['analytics'],
          ),
        );

        final providers =
            File(
              p.join(tempDir.path, 'lib/app/modules/module_providers.dart'),
            ).readAsStringSync();

        expect(
          providers,
          contains(
            'final notificationsServiceProvider = Provider<NotificationsService>(',
          ),
        );
        expect(
          providers,
          contains('AwesomeNotificationsService()'),
        );
        expect(
          providers,
          contains(
            'start: () => container.read(notificationsServiceProvider).init(),',
          ),
        );
        expect(
          File(
            p.join(tempDir.path, 'lib/app/modules/module_startup.dart'),
          ).existsSync(),
          isFalse,
        );
      },
    );
  });
}

Future<void> _seedServicePair(
  String projectDir, {
  required String relativeDir,
  required String contractFile,
  required String contractType,
  required String implementationFile,
  required String implementationType,
  required bool requiresInit,
}) async {
  final contract = File(p.join(projectDir, relativeDir, contractFile));
  await contract.parent.create(recursive: true);
  await contract.writeAsString('''
abstract class $contractType {
${requiresInit ? '  Future<void> init();' : ''}
}
''');

  final implementation = File(
    p.join(projectDir, relativeDir, implementationFile),
  );
  await implementation.writeAsString('''
import 'package:demo_app/${relativeDir.substring('lib/'.length)}/$contractFile';

class $implementationType implements $contractType {
  @override
  Future<void> init() async {}
}
''');
}
