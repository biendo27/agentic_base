import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs camerawesome with a CameraService contract.
class CameraModule implements AgenticModule {
  const CameraModule();

  @override
  String get name => 'camera';

  @override
  String get description =>
      'camerawesome — full-featured camera capture with photo and video modes.';

  @override
  List<String> get dependencies => ['camerawesome'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => ['permissions'];

  @override
  List<String> get platformSteps => [
    'iOS: add NSCameraUsageDescription and NSMicrophoneUsageDescription to Info.plist.',
    'Android: add CAMERA and RECORD_AUDIO permissions to AndroidManifest.xml.',
    'Android: set minSdkVersion to 21 in android/app/build.gradle.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/camera/camera_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/camera/camerawesome_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/camera/camera_service.dart')
      ..deleteFile('lib/core/camera/camerawesome_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Camera capture mode.
enum CaptureMode { photo, video }

/// Result of a camera capture operation.
class CaptureResult {
  const CaptureResult({required this.path, required this.mode});

  /// Absolute path of the captured file.
  final String path;
  final CaptureMode mode;
}

/// Camera service contract.
///
/// Use [CameraAwesomeBuilder] widget directly in your UI for live preview.
/// This service handles programmatic captures and lifecycle.
abstract class CameraService {
  /// Request camera and microphone permissions before opening the camera.
  Future<bool> requestPermissions();

  /// Take a photo and return the result, or null if cancelled.
  Future<CaptureResult?> takePhoto();

  /// Start video recording.
  Future<void> startVideoRecording();

  /// Stop video recording and return the result.
  Future<CaptureResult?> stopVideoRecording();
}
''';

  String _implContent(String pkg) => '''
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:$pkg/core/camera/camera_service.dart';

/// CameraAwesome stub implementation of [CameraService].
///
/// Most camera interaction is handled declaratively via [CameraAwesomeBuilder]
/// in your widget tree. This class provides a thin imperative facade for
/// cases where programmatic access is needed.
class CameraawesomeService implements CameraService {
  PhotoCameraState? _photoState;
  VideoCameraState? _videoState;

  /// Inject camera states from the [CameraAwesomeBuilder.onPreviewDecoratorBuilder]
  /// or state callbacks.
  void attachPhotoState(PhotoCameraState state) => _photoState = state;
  void attachVideoState(VideoCameraState state) => _videoState = state;

  @override
  Future<bool> requestPermissions() async {
    // Permissions are handled by the permissions module via PermissionsService.
    return true;
  }

  @override
  Future<CaptureResult?> takePhoto() async {
    final state = _photoState;
    if (state == null) return null;
    String? capturedPath;
    await state.takePhoto(
      onPhoto: (xfile) => capturedPath = xfile.path,
    );
    if (capturedPath == null) return null;
    return CaptureResult(path: capturedPath!, mode: CaptureMode.photo);
  }

  @override
  Future<void> startVideoRecording() async {
    await _videoState?.startRecording();
  }

  @override
  Future<CaptureResult?> stopVideoRecording() async {
    final state = _videoState;
    if (state == null) return null;
    String? recordedPath;
    await state.stopRecording(
      onVideo: (xfile) => recordedPath = xfile.path,
    );
    if (recordedPath == null) return null;
    return CaptureResult(path: recordedPath!, mode: CaptureMode.video);
  }
}
''';
}
