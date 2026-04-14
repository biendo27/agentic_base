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
      ..mutateTextFile('ios/Podfile', _patchIosPodfile)
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
  /// Initialise default notification channels at app startup.
  Future<void> init();

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

const _defaultNotificationChannels = <AppNotificationChannel>[
  AppNotificationChannel(
    channelKey: 'general',
    channelName: 'General',
    channelDescription: 'Default app notifications',
  ),
];

/// awesome_notifications implementation of [NotificationsService].
class AwesomeNotificationsService implements NotificationsService {
  @override
  Future<void> init() => initialize(_defaultNotificationChannels);

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

String _patchIosPodfile(String current) {
  var next = current;

  next = next.replaceFirst(
    "# platform :ios, '13.0'",
    "platform :ios, '15.0'",
  );
  next = next.replaceFirst(
    "platform :ios, '13.0'",
    "platform :ios, '15.0'",
  );

  if (!next.contains('use_modular_headers!')) {
    next = next.replaceFirst(
      '  use_frameworks!\n',
      '  use_frameworks!\n  use_modular_headers!\n',
    );
  }

  const postInstallPatch = '''
  ################  Awesome Notifications pod modification 1  ###################
  awesome_pod_file = File.expand_path(File.join('plugins', 'awesome_notifications', 'ios', 'Scripts', 'AwesomePodFile'), '.symlinks')
  require awesome_pod_file
  update_awesome_pod_build_settings(installer)
  ################  Awesome Notifications pod modification 1  ###################
''';

  if (!next.contains('update_awesome_pod_build_settings(installer)')) {
    next = next.replaceFirst(
      '  installer.pods_project.targets.each do |target|\n'
          '    flutter_additional_ios_build_settings(target)\n'
          '  end\n',
      '  installer.pods_project.targets.each do |target|\n'
          '    flutter_additional_ios_build_settings(target)\n'
          '  end\n\n$postInstallPatch',
    );
  }

  const mainTargetPatch = '''
################  Awesome Notifications pod modification 2  ###################
awesome_pod_file = File.expand_path(File.join('plugins', 'awesome_notifications', 'ios', 'Scripts', 'AwesomePodFile'), '.symlinks')
require awesome_pod_file
update_awesome_main_target_settings('Runner', File.dirname(File.realpath(__FILE__)), flutter_root)
################  Awesome Notifications pod modification 2  ###################
''';

  if (!next.contains("update_awesome_main_target_settings('Runner'")) {
    next = '${next.trimRight()}\n\n$mainTargetPatch';
  }

  return next;
}
