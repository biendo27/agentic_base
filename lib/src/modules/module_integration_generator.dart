import 'dart:io';

import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/module_startup_policy.dart';
import 'package:agentic_base/src/modules/project_context.dart';
import 'package:path/path.dart' as p;

final class ModuleIntegrationGenerator {
  const ModuleIntegrationGenerator();

  void sync(ProjectContext ctx) {
    final bindings = _discoverBindings(ctx);
    final installer = ModuleInstaller(ctx);
    if (ctx.stateProfile.usesGetIt) {
      _ensureInjectableAnnotations(ctx, bindings);
      installer
        ..writeFile(
          'lib/app/modules/module_startup.dart',
          _buildGetItStartup(ctx.projectName, bindings),
        )
        ..deleteFile('lib/app/modules/module_registrations.dart');
      return;
    }
    installer.writeFile(
      'lib/app/modules/module_providers.dart',
      _buildRiverpodRegistry(ctx.projectName, bindings),
    );
  }

  List<_ModuleServiceBinding> _discoverBindings(ProjectContext ctx) {
    final abstractServices = <String, _ServiceContract>{};
    final implementations = <String, _ServiceImplementation>{};

    for (final scanRoot in ['lib/services', 'lib/core']) {
      final directory = Directory(p.join(ctx.projectPath, scanRoot));
      if (!directory.existsSync()) continue;
      for (final entity in directory.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final relativePath = p.relative(entity.path, from: ctx.projectPath);
        final contents = entity.readAsStringSync();

        final serviceMatch = RegExp(
          r'abstract class (\w+Service)\b([\s\S]*)',
        ).firstMatch(contents);
        if (serviceMatch != null) {
          final serviceType = serviceMatch.group(1)!;
          final body = serviceMatch.group(2)!;
          abstractServices[serviceType] = _ServiceContract(
            filePath: entity.path,
            importPath: _packageImport(ctx.projectName, relativePath),
            requiresInit: RegExp(r'Future<void>\s+init\s*\(').hasMatch(body),
          );
        }

        for (final match in RegExp(
          r'class (\w+)\s+implements\s+(\w+Service)\b',
        ).allMatches(contents)) {
          implementations[match.group(2)!] = _ServiceImplementation(
            filePath: entity.path,
            implementationType: match.group(1)!,
            importPath: _packageImport(ctx.projectName, relativePath),
          );
        }
      }
    }

    final bindings = <_ModuleServiceBinding>[];
    for (final entry in abstractServices.entries) {
      final implementation = implementations[entry.key];
      if (implementation == null) continue;
      bindings.add(
        _ModuleServiceBinding(
          serviceType: entry.key,
          serviceImport: entry.value.importPath,
          serviceFilePath: entry.value.filePath,
          implementationType: implementation.implementationType,
          implementationImport: implementation.importPath,
          implementationFilePath: implementation.filePath,
          requiresInit: entry.value.requiresInit,
          startupPolicy: moduleStartupPolicies[entry.key],
        ),
      );
    }
    bindings.sort(
      (left, right) => left.serviceType.compareTo(right.serviceType),
    );
    return bindings;
  }

  void _ensureInjectableAnnotations(
    ProjectContext ctx,
    List<_ModuleServiceBinding> bindings,
  ) {
    for (final binding in bindings) {
      final path = binding.implementationFilePath;
      final file = File(path);
      if (!file.existsSync()) continue;

      String mutate(String current) {
        var contents = current;
        final annotation = '@LazySingleton(as: ${binding.serviceType})';
        if (!contents.contains(annotation)) {
          contents = contents.replaceFirst(
            'class ${binding.implementationType} implements ${binding.serviceType}',
            '$annotation\n'
                'class ${binding.implementationType} implements ${binding.serviceType}',
          );
        }

        const injectableImport = "import 'package:injectable/injectable.dart';";
        if (!contents.contains(injectableImport)) {
          final imports = RegExp(r"import '[^']+';\n").allMatches(contents);
          if (imports.isEmpty) {
            contents = '$injectableImport\n$contents';
          } else {
            final offset = imports.last.end;
            contents =
                '${contents.substring(0, offset)}'
                '$injectableImport\n'
                '${contents.substring(offset)}';
          }
        }

        return contents;
      }

      final journal = ctx.mutationJournal;
      if (journal != null) {
        journal.mutateTextFile(path, mutate);
      } else {
        file.writeAsStringSync(mutate(file.readAsStringSync()));
      }
    }
  }

  String _buildGetItStartup(
    String projectName,
    List<_ModuleServiceBinding> bindings,
  ) {
    final startupBindings = _startupBindings(bindings);
    final imports =
        <String>{
            "import 'package:get_it/get_it.dart';",
            "import 'package:$projectName/core/observability/observability_service.dart';",
            for (final binding in startupBindings)
              "import '${binding.serviceImport}';",
          }.toList()
          ..sort();
    final tasks = startupBindings.map(_buildGetItTask).join('\n');

    return '''
${imports.join('\n')}

${_startupSupportTypes()}

Future<void> initializeModuleServices(GetIt getIt) async {
  final tasks = <ModuleStartupTask>[
${tasks.isEmpty ? '    // No module startup hooks registered.' : tasks}
  ];
  await runModuleStartupTasks(tasks);
}
''';
  }

  String _buildRiverpodRegistry(
    String projectName,
    List<_ModuleServiceBinding> bindings,
  ) {
    final startupBindings = _startupBindings(bindings);
    final imports =
        <String>{
            "import 'package:flutter_riverpod/flutter_riverpod.dart';",
            "import 'package:$projectName/core/observability/observability_service.dart';",
            for (final binding in bindings)
              "import '${binding.serviceImport}';",
            for (final binding in bindings)
              "import '${binding.implementationImport}';",
          }.toList()
          ..sort();
    final providers = bindings.map(_buildProvider).join('\n\n');
    final tasks = startupBindings.map(_buildRiverpodTask).join('\n');

    return '''
${imports.join('\n')}

${providers.isEmpty ? '' : '$providers\n'}
${_startupSupportTypes()}

Future<void> initializeModuleProviders(ProviderContainer container) async {
  final tasks = <ModuleStartupTask>[
${tasks.isEmpty ? '    // No module startup hooks registered.' : tasks}
  ];
  await runModuleStartupTasks(tasks);
}
''';
  }

  String _startupSupportTypes() => r'''
enum ModuleStartupFailureBehavior { fail, logAndContinue }

final class ModuleStartupTask {
  const ModuleStartupTask({
    required this.id,
    required this.dependsOn,
    required this.stateProfiles,
    required this.required,
    required this.timeout,
    required this.runWhen,
    required this.onFailure,
    required this.start,
  });

  final String id;
  final List<String> dependsOn;
  final List<String> stateProfiles;
  final bool required;
  final Duration timeout;
  final String runWhen;
  final ModuleStartupFailureBehavior onFailure;
  final Future<void> Function() start;
}

Future<void> runModuleStartupTasks(List<ModuleStartupTask> tasks) async {
  for (final task in tasks) {
    try {
      await task.start().timeout(task.timeout);
    } on Object catch (error, stackTrace) {
      ObservabilityService.instance.log(
        'module_startup.failed',
        level: task.required ? 'error' : 'warning',
        fields: <String, Object?>{
          'task_id': task.id,
          'run_when': task.runWhen,
          'error_type': error.runtimeType.toString(),
        },
      );
      if (task.onFailure == ModuleStartupFailureBehavior.fail) {
        Error.throwWithStackTrace(
          ModuleStartupException(task.id, error),
          stackTrace,
        );
      }
    }
  }
}

final class ModuleStartupException implements Exception {
  const ModuleStartupException(this.taskId, this.cause);

  final String taskId;
  final Object cause;

  @override
  String toString() => 'Module startup failed for $taskId: $cause';
}
''';

  List<_ModuleServiceBinding> _startupBindings(
    List<_ModuleServiceBinding> bindings,
  ) {
    final startupBindings =
        bindings
            .where(
              (binding) =>
                  binding.requiresInit && binding.startupPolicy != null,
            )
            .toList();
    return startupBindings..sort((left, right) {
      final leftPolicy = left.startupPolicy!;
      final rightPolicy = right.startupPolicy!;
      final leftDependsOnRight = leftPolicy.dependsOn.contains(rightPolicy.id);
      final rightDependsOnLeft = rightPolicy.dependsOn.contains(leftPolicy.id);
      if (leftDependsOnRight && !rightDependsOnLeft) return 1;
      if (rightDependsOnLeft && !leftDependsOnRight) return -1;
      return leftPolicy.id.compareTo(rightPolicy.id);
    });
  }

  String _buildProvider(_ModuleServiceBinding binding) => '''
final ${binding.providerName} = Provider<${binding.serviceType}>(
  (ref) => ${binding.implementationType}(),
);''';

  String _buildGetItTask(_ModuleServiceBinding binding) {
    final policy = binding.startupPolicy!;
    return '''
    ModuleStartupTask(
      id: '${policy.id}',
      dependsOn: const <String>[${_quotedList(policy.dependsOn)}],
      stateProfiles: const <String>[${_quotedList(policy.stateProfiles)}],
      required: ${policy.required},
      timeout: const Duration(seconds: ${policy.timeout.inSeconds}),
      runWhen: '${policy.runWhen}',
      onFailure: ModuleStartupFailureBehavior.${policy.required ? 'fail' : 'logAndContinue'},
      start: () => getIt<${binding.serviceType}>().init(),
    ),''';
  }

  String _buildRiverpodTask(_ModuleServiceBinding binding) {
    final policy = binding.startupPolicy!;
    return '''
    ModuleStartupTask(
      id: '${policy.id}',
      dependsOn: const <String>[${_quotedList(policy.dependsOn)}],
      stateProfiles: const <String>[${_quotedList(policy.stateProfiles)}],
      required: ${policy.required},
      timeout: const Duration(seconds: ${policy.timeout.inSeconds}),
      runWhen: '${policy.runWhen}',
      onFailure: ModuleStartupFailureBehavior.${policy.required ? 'fail' : 'logAndContinue'},
      start: () => container.read(${binding.providerName}).init(),
    ),''';
  }

  String _quotedList(List<String> values) =>
      values.map((value) => "'$value'").join(', ');

  String _packageImport(String projectName, String relativePath) {
    final normalized = p.posix.normalize(relativePath.replaceAll(r'\', '/'));
    return 'package:$projectName/${normalized.substring('lib/'.length)}';
  }
}

final class _ServiceContract {
  const _ServiceContract({
    required this.filePath,
    required this.importPath,
    required this.requiresInit,
  });

  final String filePath;
  final String importPath;
  final bool requiresInit;
}

final class _ServiceImplementation {
  const _ServiceImplementation({
    required this.filePath,
    required this.implementationType,
    required this.importPath,
  });

  final String filePath;
  final String implementationType;
  final String importPath;
}

final class _ModuleServiceBinding {
  const _ModuleServiceBinding({
    required this.serviceType,
    required this.serviceImport,
    required this.serviceFilePath,
    required this.implementationType,
    required this.implementationImport,
    required this.implementationFilePath,
    required this.requiresInit,
    required this.startupPolicy,
  });

  final String serviceType;
  final String serviceImport;
  final String serviceFilePath;
  final String implementationType;
  final String implementationImport;
  final String implementationFilePath;
  final bool requiresInit;
  final ModuleStartupPolicy? startupPolicy;

  String get providerName {
    final first = serviceType.substring(0, 1).toLowerCase();
    return '$first${serviceType.substring(1)}Provider';
  }
}
