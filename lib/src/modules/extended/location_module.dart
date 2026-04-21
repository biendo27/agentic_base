import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs geolocator + geocoding with a LocationService contract.
class LocationModule implements AgenticModule {
  const LocationModule();

  @override
  String get name => 'location';

  @override
  String get description =>
      'geolocator + geocoding — GPS positioning and address resolution.';

  @override
  List<String> get dependencies => ['geolocator', 'geocoding'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => ['permissions'];

  @override
  List<String> get platformSteps => [
    'iOS: add NSLocationWhenInUseUsageDescription (and Always variant if needed) to Info.plist.',
    'Android: add ACCESS_FINE_LOCATION and ACCESS_COARSE_LOCATION to AndroidManifest.xml.',
    'Android: set minSdkVersion to 19 in android/app/build.gradle.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/services/location/location_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/services/location/geolocator_location_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/services/location/location_service.dart')
      ..deleteFile('lib/services/location/geolocator_location_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  // ignore: use_raw_strings — template contains intentional \$ escapes for generated Dart source
  String _contractContent(String pkg) => '''
/// Geographic coordinates.
class AppLatLng {
  const AppLatLng({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  String toString() => 'AppLatLng(\$latitude, \$longitude)';
}

/// Location service contract.
abstract class LocationService {
  /// Returns the current device position.
  Future<AppLatLng> getCurrentPosition();

  /// Stream of position updates.
  Stream<AppLatLng> get positionStream;

  /// Forward-geocode [address] to coordinates. Returns null if not found.
  Future<AppLatLng?> geocode(String address);

  /// Reverse-geocode [position] to a human-readable address. Returns null if unavailable.
  Future<String?> reverseGeocode(AppLatLng position);
}
''';

  String _implContent(String pkg) => '''
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:$pkg/services/location/location_service.dart';

/// geolocator + geocoding implementation of [LocationService].
class GeolocatorLocationService implements LocationService {
  @override
  Future<AppLatLng> getCurrentPosition() async {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return AppLatLng(latitude: pos.latitude, longitude: pos.longitude);
  }

  @override
  Stream<AppLatLng> get positionStream => Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).map((p) => AppLatLng(latitude: p.latitude, longitude: p.longitude));

  @override
  Future<AppLatLng?> geocode(String address) async {
    final locations = await locationFromAddress(address);
    if (locations.isEmpty) return null;
    return AppLatLng(
      latitude: locations.first.latitude,
      longitude: locations.first.longitude,
    );
  }

  @override
  Future<String?> reverseGeocode(AppLatLng position) async {
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isEmpty) return null;
    final p = placemarks.first;
    return [p.street, p.locality, p.country]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');
  }
}
''';
}
