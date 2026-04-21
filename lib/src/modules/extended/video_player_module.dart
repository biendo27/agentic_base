import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs media_kit + media_kit_video + media_kit_libs_video with a VideoPlayerService contract.
class VideoPlayerModule implements AgenticModule {
  const VideoPlayerModule();

  @override
  String get name => 'video_player';

  @override
  String get description =>
      'media_kit — cross-platform video player with hardware acceleration.';

  @override
  List<String> get dependencies => [
    'media_kit',
    'media_kit_video',
    'media_kit_libs_video',
  ];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
    'Call MediaKit.ensureInitialized() in main() before runApp().',
    'Android: set minSdkVersion to 21 in android/app/build.gradle.',
    'macOS: add com.apple.security.network.client to entitlements for network streams.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/services/video_player/video_player_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/services/video_player/media_kit_video_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/services/video_player/video_player_service.dart')
      ..deleteFile('lib/services/video_player/media_kit_video_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Video player service contract.
///
/// Use the companion [VideoPlayerService] widget from media_kit_video
/// for rendering. This service manages the player lifecycle.
abstract class VideoPlayerService {
  /// Open [url] (network, asset, or file path) and begin playback.
  Future<void> open(String url, {bool autoPlay = true});

  /// Toggle play / pause.
  Future<void> playOrPause();

  /// Seek to [position].
  Future<void> seek(Duration position);

  /// Set playback [volume] from 0.0 to 100.0.
  Future<void> setVolume(double volume);

  /// Stop playback and release resources.
  Future<void> dispose();
}
''';

  String _implContent(String pkg) => '''
import 'package:media_kit/media_kit.dart';
import 'package:$pkg/services/video_player/video_player_service.dart';

/// media_kit implementation of [VideoPlayerService].
///
/// Expose [player] to a [Video] widget from media_kit_video for rendering:
///
/// ```dart
/// Video(controller: VideoController(service.player))
/// ```
class MediaKitVideoService implements VideoPlayerService {
  MediaKitVideoService() : player = Player();

  /// Underlying media_kit [Player] — expose to [VideoController] for rendering.
  final Player player;

  @override
  Future<void> open(String url, {bool autoPlay = true}) =>
      player.open(Media(url), play: autoPlay);

  @override
  Future<void> playOrPause() => player.playOrPause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> setVolume(double volume) => player.setVolume(volume);

  @override
  Future<void> dispose() async => player.dispose();
}
''';
}
