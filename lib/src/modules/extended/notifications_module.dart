import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs awesome_notifications with a NotificationsService contract.
class NotificationsModule implements AgenticModule {
  const NotificationsModule();

  @override
  String get name => 'notifications';

  @override
  String get description =>
      'awesome_notifications — local and push notification service.';

  @override
  List<String> get dependencies => ['awesome_notifications'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
    'iOS: enable Push Notifications capability in Xcode.',
    'Android: add notification icons to res/drawable.',
    'Initialise AwesomeNotifications in bootstrap.dart before runApp().',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/notifications/notifications_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/notifications/awesome_notifications_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/notifications/notifications_service.dart')
      ..deleteFile('lib/core/notifications/awesome_notifications_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Notification channel descriptor (avoids name clash with packages).
class AppNotificationChannel {
  const AppNotificationChannel({
    required this.channelKey,
    required this.channelName,
    required this.channelDescription,
  });

  final String channelKey;
  final String channelName;
  final String channelDescription;
}

/// Notification payload model.
class AppNotificationPayload {
  const AppNotificationPayload({
    required this.id,
    required this.channelKey,
    required this.title,
    this.body,
    this.payload,
  });

  final int id;
  final String channelKey;
  final String title;
  final String? body;
  final Map<String, String>? payload;
}

/// Notifications service contract.
abstract class NotificationsService {
  /// Initialise notification channels.
  Future<void> initialize(List<AppNotificationChannel> channels);

  /// Request notification permission from the user.
  Future<bool> requestPermission();

  /// Show a local notification.
  Future<void> show(AppNotificationPayload payload);

  /// Cancel a notification by [id].
  Future<void> cancel(int id);

  /// Cancel all pending notifications.
  Future<void> cancelAll();
}
''';

  String _implContent(String pkg) => '''
import 'package:awesome_notifications/awesome_notifications.dart'
    as awesome;
import 'package:$pkg/core/notifications/notifications_service.dart';

/// awesome_notifications implementation of [NotificationsService].
class AwesomeNotificationsService implements NotificationsService {
  @override
  Future<void> initialize(List<AppNotificationChannel> channels) async {
    await awesome.AwesomeNotifications().initialize(
      null,
      channels
          .map(
            (c) => awesome.NotificationChannel(
              channelKey: c.channelKey,
              channelName: c.channelName,
              channelDescription: c.channelDescription,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<bool> requestPermission() =>
      awesome.AwesomeNotifications()
          .requestPermissionToSendNotifications();

  @override
  Future<void> show(AppNotificationPayload payload) async {
    await awesome.AwesomeNotifications().createNotification(
      content: awesome.NotificationContent(
        id: payload.id,
        channelKey: payload.channelKey,
        title: payload.title,
        body: payload.body,
        payload: payload.payload,
      ),
    );
  }

  @override
  Future<void> cancel(int id) =>
      awesome.AwesomeNotifications().cancel(id);

  @override
  Future<void> cancelAll() =>
      awesome.AwesomeNotifications().cancelAll();
}
''';
}
