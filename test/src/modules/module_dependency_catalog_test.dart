import 'package:agentic_base/src/modules/module_dependency_catalog.dart';
import 'package:agentic_base/src/modules/module_registry.dart';
import 'package:test/test.dart';

void main() {
  group('module dependency catalog', () {
    test('covers every dependency declared by the module registry', () {
      for (final module in ModuleRegistry.all) {
        for (final packageName in module.dependencies) {
          expect(
            () => resolveModuleDependencyConstraint(
              packageName,
              devDependency: false,
            ),
            returnsNormally,
            reason:
                'Missing runtime constraint for ${module.name}: $packageName',
          );
        }

        for (final packageName in module.devDependencies) {
          expect(
            () => resolveModuleDependencyConstraint(
              packageName,
              devDependency: true,
            ),
            returnsNormally,
            reason: 'Missing dev constraint for ${module.name}: $packageName',
          );
        }
      }
    });

    test('never falls back to floating constraints', () {
      for (final entry in moduleDependencyConstraints.entries) {
        expect(entry.value, isNot('any'));
        expect(entry.value.startsWith('^'), isTrue);
      }
      for (final entry in moduleDevDependencyConstraints.entries) {
        expect(entry.value, isNot('any'));
        expect(entry.value.startsWith('^'), isTrue);
      }
    });

    test('rejects known-broken legacy dependency pins', () {
      expect(moduleDependencyConstraints, isNot(contains('uni_links')));
      for (final module in ModuleRegistry.all) {
        expect(
          module.dependencies,
          isNot(contains('uni_links')),
          reason: '${module.name} must not reintroduce uni_links',
        );
      }
    });
  });
}
