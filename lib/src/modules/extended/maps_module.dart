import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs google_maps_flutter with a MapsService contract.
class MapsModule implements AgenticModule {
  const MapsModule();

  @override
  String get name => 'maps';

  @override
  String get description =>
      'google_maps_flutter — Google Maps with markers, polylines, and camera control.';

  @override
  List<String> get dependencies => ['google_maps_flutter'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => ['location'];

  @override
  List<String> get platformSteps => [
    'iOS: add MAPS_API_KEY to AppDelegate.swift via GMSServices.provideAPIKey().',
    'Android: add MAPS_API_KEY meta-data to AndroidManifest.xml.',
    'Obtain a Maps SDK API key from Google Cloud Console.',
    'Android: set minSdkVersion to 21 in android/app/build.gradle.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/maps/maps_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/maps/google_maps_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/maps/maps_service.dart')
      ..deleteFile('lib/core/maps/google_maps_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
import 'package:$pkg/core/location/location_service.dart';

/// Map marker model.
class MapMarker {
  const MapMarker({
    required this.id,
    required this.position,
    this.title,
    this.snippet,
  });

  final String id;
  final AppLatLng position;
  final String? title;
  final String? snippet;
}

/// Maps service contract — thin facade over the map controller.
///
/// Embed [GoogleMap] widget in your UI. Use this service for
/// programmatic camera and marker control.
abstract class MapsService {
  /// Animate camera to [position] at [zoom] level.
  Future<void> animateTo(AppLatLng position, {double zoom = 15});

  /// Add or update a [marker] on the map.
  void upsertMarker(MapMarker marker);

  /// Remove marker by [markerId].
  void removeMarker(String markerId);

  /// Clear all markers.
  void clearMarkers();

  /// Returns the current set of markers.
  List<MapMarker> get markers;
}
''';

  String _implContent(String pkg) => '''
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:$pkg/core/location/location_service.dart';
import 'package:$pkg/core/maps/maps_service.dart';

/// google_maps_flutter implementation of [MapsService].
///
/// Attach the controller from GoogleMap(onMapCreated:) via [attachController].
class GoogleMapsService implements MapsService {
  GoogleMapController? _controller;
  final Map<String, MapMarker> _markers = {};

  /// Call this from GoogleMap(onMapCreated:) to enable camera control.
  void attachController(GoogleMapController controller) {
    _controller = controller;
  }

  @override
  Future<void> animateTo(AppLatLng position, {double zoom = 15}) async {
    await _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: zoom,
        ),
      ),
    );
  }

  @override
  void upsertMarker(MapMarker marker) => _markers[marker.id] = marker;

  @override
  void removeMarker(String markerId) => _markers.remove(markerId);

  @override
  void clearMarkers() => _markers.clear();

  @override
  List<MapMarker> get markers => List.unmodifiable(_markers.values);

  /// Convert internal markers to google_maps_flutter [Marker] set for the widget.
  Set<Marker> toGoogleMarkers() => _markers.values.map((m) => Marker(
        markerId: MarkerId(m.id),
        position: LatLng(m.position.latitude, m.position.longitude),
        infoWindow: InfoWindow(title: m.title, snippet: m.snippet),
      )).toSet();
}
''';
}
