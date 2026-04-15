import 'package:agentic_base/src/config/flutter_sdk_contract.dart';

typedef FlutterToolchainDetector =
    DetectedFlutterToolchain Function({
      required FlutterSdkManager manager,
      required String projectPath,
    });

enum FlutterToolchainResolutionSource { preferred, inferred, systemFallback }

final class FlutterToolchainResolutionException implements Exception {
  const FlutterToolchainResolutionException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ToolCommandSpec {
  const ToolCommandSpec({
    required this.executable,
    required this.arguments,
  });

  final String executable;
  final List<String> arguments;

  @override
  String toString() {
    if (arguments.isEmpty) {
      return executable;
    }
    return '$executable ${arguments.join(' ')}';
  }
}

final class ResolvedFlutterToolchain {
  const ResolvedFlutterToolchain({
    required this.contract,
    required this.detected,
    required this.source,
  });

  final FlutterSdkContract contract;
  final DetectedFlutterToolchain detected;
  final FlutterToolchainResolutionSource source;

  ToolCommandSpec flutterCommand(List<String> arguments) {
    return switch (contract.manager) {
      FlutterSdkManager.system => ToolCommandSpec(
        executable: 'flutter',
        arguments: arguments,
      ),
      FlutterSdkManager.fvm => ToolCommandSpec(
        executable: 'fvm',
        arguments: ['flutter', ...arguments],
      ),
      FlutterSdkManager.puro => ToolCommandSpec(
        executable: 'puro',
        arguments: ['flutter', ...arguments],
      ),
    };
  }

  ToolCommandSpec dartCommand(List<String> arguments) {
    return switch (contract.manager) {
      FlutterSdkManager.system => ToolCommandSpec(
        executable: 'dart',
        arguments: arguments,
      ),
      FlutterSdkManager.fvm => ToolCommandSpec(
        executable: 'fvm',
        arguments: ['dart', ...arguments],
      ),
      FlutterSdkManager.puro => ToolCommandSpec(
        executable: 'puro',
        arguments: ['dart', ...arguments],
      ),
    };
  }
}

ResolvedFlutterToolchain resolveFlutterToolchain({
  required String projectPath,
  FlutterSdkManager? preferredManager,
  String? preferredVersion,
  String preferredChannel = defaultFlutterChannel,
  FlutterVersionPolicy policy = FlutterVersionPolicy.newestTested,
  FlutterToolchainDetector detector = detectFlutterToolchain,
}) {
  final inferredManager = inferFlutterSdkManager(projectPath);
  final requestedManager = preferredManager ?? inferredManager;
  final attemptedDetections = <DetectedFlutterToolchain>[];

  final candidates = <(FlutterSdkManager, FlutterToolchainResolutionSource)>[
    (requestedManager, FlutterToolchainResolutionSource.preferred),
    if (inferredManager != requestedManager)
      (inferredManager, FlutterToolchainResolutionSource.inferred),
    if (FlutterSdkManager.system != requestedManager &&
        FlutterSdkManager.system != inferredManager)
      (
        FlutterSdkManager.system,
        FlutterToolchainResolutionSource.systemFallback,
      ),
  ];

  for (final candidate in candidates) {
    final detection = detector(
      manager: candidate.$1,
      projectPath: projectPath,
    );
    attemptedDetections.add(detection);
    if (!detection.available) {
      continue;
    }

    final resolvedVersion = detection.version;
    if (resolvedVersion == null || resolvedVersion.trim().isEmpty) {
      throw FlutterToolchainResolutionException(
        'Resolved Flutter manager "${candidate.$1.wireName}" is executable '
        'but its version could not be parsed from `${detection.command}`.',
      );
    }

    return ResolvedFlutterToolchain(
      contract: FlutterSdkContract(
        manager: candidate.$1,
        channel: detection.channel ?? preferredChannel,
        version: resolvedVersion,
        policy: policy,
        preferredManager: requestedManager,
        preferredVersion: preferredVersion ?? resolvedVersion,
      ),
      detected: detection,
      source: candidate.$2,
    );
  }

  final attemptSummary = attemptedDetections
      .map(
        (detection) =>
            '${detection.manager.wireName}: '
            '${detection.problem ?? detection.command}',
      )
      .join('; ');
  throw FlutterToolchainResolutionException(
    'No executable Flutter SDK was found. Attempted managers: $attemptSummary',
  );
}

ResolvedFlutterToolchain resolveProjectFlutterToolchain({
  required String projectPath,
  required FlutterSdkContract contract,
  FlutterToolchainDetector detector = detectFlutterToolchain,
}) {
  return resolveFlutterToolchain(
    projectPath: projectPath,
    preferredManager: contract.preferredManager,
    preferredVersion: contract.preferredVersion,
    preferredChannel: contract.channel,
    policy: contract.policy,
    detector: detector,
  );
}
