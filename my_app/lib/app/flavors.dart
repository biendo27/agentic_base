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
    _instance = switch (flavor) {
      Flavor.dev => const FlavorConfig._(
          flavor: Flavor.dev,
          apiBaseUrl: 'https://api-dev.example.com',
          appName: 'My App Dev',
        ),
      Flavor.staging => const FlavorConfig._(
          flavor: Flavor.staging,
          apiBaseUrl: 'https://api-staging.example.com',
          appName: 'My App Staging',
        ),
      Flavor.prod => const FlavorConfig._(
          flavor: Flavor.prod,
          apiBaseUrl: 'https://api.example.com',
          appName: 'My App',
        ),
    };
  }
}
