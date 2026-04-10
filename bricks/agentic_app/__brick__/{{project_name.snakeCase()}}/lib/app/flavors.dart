enum Flavor { dev, staging, prod }

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

  static void init(Flavor flavor) {
    const devUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://dev.api.example.com',
    );
    const stagingUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://staging.api.example.com',
    );
    const prodUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.example.com',
    );
    const devName = String.fromEnvironment(
      'APP_NAME',
      defaultValue: '{{project_name.titleCase()}} Dev',
    );
    const stagingName = String.fromEnvironment(
      'APP_NAME',
      defaultValue: '{{project_name.titleCase()}} Staging',
    );
    const prodName = String.fromEnvironment(
      'APP_NAME',
      defaultValue: '{{project_name.titleCase()}}',
    );

    _instance = switch (flavor) {
      Flavor.dev => const FlavorConfig._(
        flavor: Flavor.dev,
        apiBaseUrl: devUrl,
        appName: devName,
      ),
      Flavor.staging => const FlavorConfig._(
        flavor: Flavor.staging,
        apiBaseUrl: stagingUrl,
        appName: stagingName,
      ),
      Flavor.prod => const FlavorConfig._(
        flavor: Flavor.prod,
        apiBaseUrl: prodUrl,
        appName: prodName,
      ),
    };
  }
}
