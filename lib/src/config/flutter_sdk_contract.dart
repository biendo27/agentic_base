import 'dart:io';

const newestTestedFlutterVersion = '3.29.0';
const defaultFlutterChannel = 'stable';

enum FlutterSdkManager { system, fvm, puro }

extension FlutterSdkManagerX on FlutterSdkManager {
  String get wireName => switch (this) {
    FlutterSdkManager.system => 'system',
    FlutterSdkManager.fvm => 'fvm',
    FlutterSdkManager.puro => 'puro',
  };

  static FlutterSdkManager fromWireName(String? value) => switch (value) {
    'fvm' => FlutterSdkManager.fvm,
    'puro' => FlutterSdkManager.puro,
    _ => FlutterSdkManager.system,
  };
}

enum FlutterVersionPolicy { newestTested }

extension FlutterVersionPolicyX on FlutterVersionPolicy {
  String get wireName => switch (this) {
    FlutterVersionPolicy.newestTested => 'newest_tested',
  };

  static FlutterVersionPolicy fromWireName(String? value) => switch (value) {
    'newest_tested' => FlutterVersionPolicy.newestTested,
    _ => FlutterVersionPolicy.newestTested,
  };
}

final class FlutterSdkContract {
  const FlutterSdkContract({
    required this.manager,
    required this.channel,
    required this.version,
    required this.policy,
  });

  factory FlutterSdkContract.fromConfigMap(dynamic raw) {
    if (raw is! Map) {
      return const FlutterSdkContract(
        manager: FlutterSdkManager.system,
        channel: defaultFlutterChannel,
        version: newestTestedFlutterVersion,
        policy: FlutterVersionPolicy.newestTested,
      );
    }

    return FlutterSdkContract(
      manager: FlutterSdkManagerX.fromWireName(
        raw['manager']?.toString(),
      ),
      channel: _readString(raw['channel']) ?? defaultFlutterChannel,
      version: _readString(raw['version']) ?? newestTestedFlutterVersion,
      policy: FlutterVersionPolicyX.fromWireName(
        raw['policy']?.toString(),
      ),
    );
  }

  final FlutterSdkManager manager;
  final String channel;
  final String version;
  final FlutterVersionPolicy policy;

  FlutterSdkContract copyWith({
    FlutterSdkManager? manager,
    String? channel,
    String? version,
    FlutterVersionPolicy? policy,
  }) {
    return FlutterSdkContract(
      manager: manager ?? this.manager,
      channel: channel ?? this.channel,
      version: version ?? this.version,
      policy: policy ?? this.policy,
    );
  }

  Map<String, dynamic> toConfigMap() {
    return <String, dynamic>{
      'manager': manager.wireName,
      'channel': channel,
      'version': version,
      'policy': policy.wireName,
    };
  }
}

final class DetectedFlutterToolchain {
  const DetectedFlutterToolchain({
    required this.manager,
    required this.version,
    required this.channel,
    required this.available,
    required this.command,
    this.problem,
  });

  final FlutterSdkManager manager;
  final String? version;
  final String? channel;
  final bool available;
  final String command;
  final String? problem;

  bool matches(FlutterSdkContract contract) {
    return available &&
        version == contract.version &&
        (channel == null || channel == contract.channel);
  }
}

FlutterSdkManager inferFlutterSdkManager(String projectPath) {
  final puroFiles = <String>[
    '.puro.json',
    '.puro',
  ];
  for (final relativePath in puroFiles) {
    final type = FileSystemEntity.typeSync('$projectPath/$relativePath');
    if (type != FileSystemEntityType.notFound) {
      return FlutterSdkManager.puro;
    }
  }

  final fvmFiles = <String>[
    '.fvm',
    '.fvmrc',
    '.fvm/fvm_config.json',
  ];
  for (final relativePath in fvmFiles) {
    final type = FileSystemEntity.typeSync('$projectPath/$relativePath');
    if (type != FileSystemEntityType.notFound) {
      return FlutterSdkManager.fvm;
    }
  }

  return FlutterSdkManager.system;
}

String? _readString(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return null;
}

FlutterSdkContract resolveFlutterSdkContract({
  required String projectPath,
  FlutterSdkManager? manager,
  String? version,
  String channel = defaultFlutterChannel,
  FlutterVersionPolicy policy = FlutterVersionPolicy.newestTested,
}) {
  final resolvedManager = manager ?? inferFlutterSdkManager(projectPath);
  final detected = detectFlutterToolchain(
    manager: resolvedManager,
    projectPath: projectPath,
  );
  return FlutterSdkContract(
    manager: resolvedManager,
    channel: detected.channel ?? channel,
    version: version ?? detected.version ?? newestTestedFlutterVersion,
    policy: policy,
  );
}

DetectedFlutterToolchain detectFlutterToolchain({
  required FlutterSdkManager manager,
  required String projectPath,
}) {
  final commandSpec = switch (manager) {
    FlutterSdkManager.system => ('flutter', <String>['--version']),
    FlutterSdkManager.fvm => ('fvm', <String>['flutter', '--version']),
    FlutterSdkManager.puro => ('puro', <String>['flutter', '--version']),
  };

  try {
    final result = Process.runSync(
      commandSpec.$1,
      commandSpec.$2,
      workingDirectory: projectPath,
    );
    final output = '${result.stdout}\n${result.stderr}';
    if (result.exitCode != 0) {
      return DetectedFlutterToolchain(
        manager: manager,
        version: null,
        channel: null,
        available: false,
        command: '${commandSpec.$1} ${commandSpec.$2.join(' ')}',
        problem: output.trim().isEmpty ? 'command failed' : output.trim(),
      );
    }

    return DetectedFlutterToolchain(
      manager: manager,
      version: _extractFlutterVersion(output),
      channel: _extractFlutterChannel(output),
      available: true,
      command: '${commandSpec.$1} ${commandSpec.$2.join(' ')}',
    );
  } on ProcessException catch (error) {
    return DetectedFlutterToolchain(
      manager: manager,
      version: null,
      channel: null,
      available: false,
      command: '${commandSpec.$1} ${commandSpec.$2.join(' ')}',
      problem: error.message,
    );
  }
}

String? _extractFlutterVersion(String output) {
  final match = RegExp(r'Flutter\s+([0-9]+\.[0-9]+\.[0-9]+)').firstMatch(
    output,
  );
  return match?.group(1);
}

String? _extractFlutterChannel(String output) {
  final match = RegExp(r'channel\s+([A-Za-z0-9_-]+)').firstMatch(output);
  return match?.group(1)?.toLowerCase();
}
