final class ModuleStartupPolicy {
  const ModuleStartupPolicy({
    required this.id,
    required this.serviceType,
    this.dependsOn = const <String>[],
    this.stateProfiles = const <String>['cubit', 'mobx', 'riverpod'],
    this.required = false,
    this.timeout = const Duration(seconds: 15),
    this.runWhen = 'always',
    this.onFailure = 'log_once_and_continue',
  });

  final String id;
  final String serviceType;
  final List<String> dependsOn;
  final List<String> stateProfiles;
  final bool required;
  final Duration timeout;
  final String runWhen;
  final String onFailure;
}

const moduleStartupPolicies = <String, ModuleStartupPolicy>{
  'AuthService': ModuleStartupPolicy(
    id: 'firebase_auth',
    serviceType: 'AuthService',
    dependsOn: <String>['firebase_runtime'],
  ),
  'CrashReportingService': ModuleStartupPolicy(
    id: 'crash_reporting',
    serviceType: 'CrashReportingService',
    dependsOn: <String>['firebase_runtime'],
  ),
  'LocalStorageService': ModuleStartupPolicy(
    id: 'local_storage',
    serviceType: 'LocalStorageService',
    required: true,
    onFailure: 'fail_bootstrap',
  ),
  'NotificationsService': ModuleStartupPolicy(
    id: 'notifications',
    serviceType: 'NotificationsService',
  ),
  'RemoteConfigService': ModuleStartupPolicy(
    id: 'remote_config',
    serviceType: 'RemoteConfigService',
    dependsOn: <String>['firebase_runtime'],
  ),
};
