const moduleDependencyConstraints = <String, String>{
  'app_links': '^7.0.0',
  'awesome_notifications': '^0.11.0',
  'camerawesome': '^2.5.0',
  'connectivity_plus': '^7.1.1',
  'firebase_analytics': '^12.2.0',
  'firebase_auth': '^6.3.0',
  'firebase_core': '^4.6.0',
  'firebase_crashlytics': '^5.1.0',
  'firebase_remote_config': '^6.3.0',
  'flutter_inappwebview': '^6.1.5',
  'flutter_secure_storage': '^10.0.0',
  'geocoding': '^4.0.0',
  'geolocator': '^14.0.2',
  'google_maps_flutter': '^2.17.0',
  'google_mobile_ads': '^7.0.0',
  'google_sign_in': '^7.2.0',
  'image_cropper': '^12.2.0',
  'image_picker': '^1.2.1',
  'in_app_review': '^2.0.11',
  'in_app_purchase': '^3.2.3',
  'local_auth': '^3.0.1',
  'media_kit': '^1.2.6',
  'media_kit_libs_video': '^1.0.7',
  'media_kit_video': '^2.0.1',
  'mobile_scanner': '^7.2.0',
  'open_filex': '^4.7.0',
  'path_provider': '^2.1.5',
  'permission_handler': '^12.0.1',
  'share_plus': '^13.0.0',
  'shared_preferences': '^2.5.5',
  'sign_in_with_apple': '^7.0.1',
  'talker': '^5.1.16',
  'talker_dio_logger': '^5.1.16',
  'uni_links': '^0.5.1',
  'upgrader': '^13.0.0',
};

const moduleDevDependencyConstraints = <String, String>{};

String resolveModuleDependencyConstraint(
  String packageName, {
  required bool devDependency,
}) {
  final constraints =
      devDependency
          ? moduleDevDependencyConstraints
          : moduleDependencyConstraints;
  final version = constraints[packageName];
  if (version == null) {
    throw StateError(
      'Missing module dependency constraint for "$packageName". '
      'Update module_dependency_catalog.dart before installing this package.',
    );
  }
  return version;
}
