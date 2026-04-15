import 'dart:io';

import 'package:agentic_base/src/modules/module_integration_generator.dart';
import 'package:agentic_base/src/modules/project_context.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('ModuleIntegrationGenerator', () {
    test(
      'writes get_it registrations and init hooks for detected services',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'module-integration-get-it-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        await _seedServicePair(
          tempDir.path,
          relativeDir: 'lib/core/notifications',
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

        final registrations =
            File(
              p.join(tempDir.path, 'lib/app/modules/module_registrations.dart'),
            ).readAsStringSync();

        expect(
          registrations,
          contains('registerLazySingleton<NotificationsService>('),
        );
        expect(
          registrations,
          contains('AwesomeNotificationsService.new'),
        );
        expect(
          registrations,
          contains('await getIt<NotificationsService>().init();'),
        );
      },
    );

    test(
      'writes riverpod providers and startup hooks for detected services',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'module-integration-riverpod-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        await _seedServicePair(
          tempDir.path,
          relativeDir: 'lib/core/analytics',
          contractFile: 'analytics_service.dart',
          contractType: 'AnalyticsService',
          implementationFile: 'firebase_analytics_service.dart',
          implementationType: 'FirebaseAnalyticsService',
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
            'final analyticsServiceProvider = Provider<AnalyticsService>(',
          ),
        );
        expect(
          providers,
          contains('FirebaseAnalyticsService()'),
        );
        expect(
          providers,
          contains('await container.read(analyticsServiceProvider).init();'),
        );
        expect(
          File(
            p.join(tempDir.path, 'lib/app/modules/module_registrations.dart'),
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
