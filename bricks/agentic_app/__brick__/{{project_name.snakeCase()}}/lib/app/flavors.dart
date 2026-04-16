enum Flavor { dev, staging, prod }

final class FlavorDefaults {
  const FlavorDefaults({
    required this.apiBaseUrl,
    required this.appName,
  });

  final String apiBaseUrl;
  final String appName;
}

class FlavorConfig {
  const FlavorConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appName,
  });

  final Flavor flavor;
  final String apiBaseUrl;
  final String appName;

  static late FlavorConfig _instance;
  static FlavorConfig get instance => _instance;

  static const _apiBaseUrlKey = 'API_BASE_URL';
  static const _appNameKey = 'APP_NAME';
  static const _defaults = {
    Flavor.dev: FlavorDefaults(
      apiBaseUrl: 'https://dev.api.example.com',
      appName: '{{project_name.titleCase()}} Dev',
    ),
    Flavor.staging: FlavorDefaults(
      apiBaseUrl: 'https://staging.api.example.com',
      appName: '{{project_name.titleCase()}} Staging',
    ),
    Flavor.prod: FlavorDefaults(
      apiBaseUrl: 'https://api.example.com',
      appName: '{{project_name.titleCase()}}',
    ),
  };

  static void init(Flavor flavor) {
    final defaults = _defaults[flavor]!;
    _instance = FlavorConfig._(
      flavor: flavor,
      apiBaseUrl: _readStringEnv(_apiBaseUrlKey, defaults.apiBaseUrl),
      appName: _readStringEnv(_appNameKey, defaults.appName),
    );
  }

  static String _readStringEnv(String key, String fallback) {
    return String.fromEnvironment(key, defaultValue: fallback);
  }
}
