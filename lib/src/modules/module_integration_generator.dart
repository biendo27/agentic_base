import 'dart:io';

import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';
import 'package:path/path.dart' as p;

final class ModuleIntegrationGenerator {
  const ModuleIntegrationGenerator();

  void sync(ProjectContext ctx) {
    final bindings = _discoverBindings(ctx);
    final installer = ModuleInstaller(ctx);
    if (ctx.stateProfile.usesGetIt) {
      installer.writeFile(
        'lib/app/modules/module_registrations.dart',
        _buildGetItRegistry(ctx.projectName, bindings),
      );
      return;
    }
    installer.writeFile(
      'lib/app/modules/module_providers.dart',
      _buildRiverpodRegistry(ctx.projectName, bindings),
    );
  }

  List<_ModuleServiceBinding> _discoverBindings(ProjectContext ctx) {
    final coreDir = Directory(p.join(ctx.projectPath, 'lib/core'));
    if (!coreDir.existsSync()) return const <_ModuleServiceBinding>[];

    final abstractServices = <String, _ServiceContract>{};
    final implementations = <String, _ServiceImplementation>{};

    for (final entity in coreDir.listSync(recursive: true)) {
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
          importPath: _packageImport(ctx.projectName, relativePath),
          requiresInit: RegExp(r'Future<void>\s+init\s*\(').hasMatch(body),
        );
      }

      for (final implementationMatch in RegExp(
        r'class (\w+)\s+implements\s+(\w+Service)\b',
      ).allMatches(contents)) {
        implementations[implementationMatch.group(2)!] = _ServiceImplementation(
          implementationType: implementationMatch.group(1)!,
          importPath: _packageImport(ctx.projectName, relativePath),
        );
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
          implementationType: implementation.implementationType,
          implementationImport: implementation.importPath,
          requiresInit: entry.value.requiresInit,
        ),
      );
    }
    bindings.sort(
      (left, right) => left.serviceType.compareTo(right.serviceType),
    );
    return bindings;
  }

  String _buildGetItRegistry(
    String projectName,
    List<_ModuleServiceBinding> bindings,
  ) {
    final imports =
        <String>{
            "import 'package:get_it/get_it.dart';",
            for (final binding in bindings)
              "import '${binding.serviceImport}';",
            for (final binding in bindings)
              "import '${binding.implementationImport}';",
          }.toList()
          ..sort();

    final registrations = bindings
        .map((binding) {
          return '''
  if (!getIt.isRegistered<${binding.serviceType}>()) {
    getIt.registerLazySingleton<${binding.serviceType}>(
      ${binding.implementationType}.new,
    );
  }''';
        })
        .join('\n');

    final initializers = bindings
        .where((binding) => binding.requiresInit)
        .map(
          (binding) => '  await getIt<${binding.serviceType}>().init();',
        )
        .join('\n');

    return '''
${imports.join('\n')}

Future<void> registerModuleServices(GetIt getIt) async {
$registrations
}

Future<void> initializeModuleServices(GetIt getIt) async {
${initializers.isEmpty ? '  // No module startup hooks registered.' : initializers}
}
''';
  }

  String _buildRiverpodRegistry(
    String projectName,
    List<_ModuleServiceBinding> bindings,
  ) {
    final imports =
        <String>{
            "import 'package:flutter_riverpod/flutter_riverpod.dart';",
            for (final binding in bindings)
              "import '${binding.serviceImport}';",
            for (final binding in bindings)
              "import '${binding.implementationImport}';",
          }.toList()
          ..sort();

    final providers = bindings
        .map((binding) {
          return '''
final ${binding.providerName} = Provider<${binding.serviceType}>(
  (ref) => ${binding.implementationType}(),
);''';
        })
        .join('\n\n');

    final initializers = bindings
        .where((binding) => binding.requiresInit)
        .map(
          (binding) =>
              '  await container.read(${binding.providerName}).init();',
        )
        .join('\n');

    return '''
${imports.join('\n')}

${providers.isEmpty ? '' : '$providers\n'}
Future<void> initializeModuleProviders(ProviderContainer container) async {
${initializers.isEmpty ? '  // No module startup hooks registered.' : initializers}
}
''';
  }

  String _packageImport(String projectName, String relativePath) {
    final normalized = p.posix.normalize(relativePath.replaceAll(r'\', '/'));
    return 'package:$projectName/${normalized.substring('lib/'.length)}';
  }
}

final class _ServiceContract {
  const _ServiceContract({
    required this.importPath,
    required this.requiresInit,
  });

  final String importPath;
  final bool requiresInit;
}

final class _ServiceImplementation {
  const _ServiceImplementation({
    required this.implementationType,
    required this.importPath,
  });

  final String implementationType;
  final String importPath;
}

final class _ModuleServiceBinding {
  const _ModuleServiceBinding({
    required this.serviceType,
    required this.serviceImport,
    required this.implementationType,
    required this.implementationImport,
    required this.requiresInit,
  });

  final String serviceType;
  final String serviceImport;
  final String implementationType;
  final String implementationImport;
  final bool requiresInit;

  String get providerName {
    final first = serviceType.substring(0, 1).toLowerCase();
    return '$first${serviceType.substring(1)}Provider';
  }
}
