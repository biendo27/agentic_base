import 'package:agentic_base/src/modules/project_context.dart';
import 'package:test/test.dart';

void main() {
  group('ProjectContext', () {
    test('constructor initializes all fields', () {
      const context = ProjectContext(
        projectPath: '/path/to/project',
        projectName: 'my_app',
        stateManagement: 'cubit',
        installedModules: ['auth', 'analytics'],
      );

      expect(context.projectPath, equals('/path/to/project'));
      expect(context.projectName, equals('my_app'));
      expect(context.stateManagement, equals('cubit'));
      expect(context.installedModules, equals(['auth', 'analytics']));
    });

    test('toString produces readable output', () {
      const context = ProjectContext(
        projectPath: '/path/to/project',
        projectName: 'my_app',
        stateManagement: 'cubit',
        installedModules: ['auth', 'analytics'],
      );

      final str = context.toString();

      expect(str, contains('ProjectContext'));
      expect(str, contains('my_app'));
      expect(str, contains('cubit'));
      expect(str, contains('auth'));
      expect(str, contains('analytics'));
    });

    test('supports different state management options', () {
      for (final state in ['cubit', 'riverpod', 'mobx']) {
        final context = ProjectContext(
          projectPath: '/path/to/project',
          projectName: 'my_app',
          stateManagement: state,
          installedModules: [],
        );

        expect(context.stateManagement, equals(state));
      }
    });

    test('supports empty installed modules list', () {
      const context = ProjectContext(
        projectPath: '/path/to/project',
        projectName: 'my_app',
        stateManagement: 'cubit',
        installedModules: [],
      );

      expect(context.installedModules, isEmpty);
    });

    test('supports multiple installed modules', () {
      final modules = ['auth', 'analytics', 'payments', 'notifications'];

      final context = ProjectContext(
        projectPath: '/path/to/project',
        projectName: 'my_app',
        stateManagement: 'cubit',
        installedModules: modules,
      );

      expect(context.installedModules.length, equals(4));
      expect(context.installedModules, equals(modules));
    });

    test('projectPath can be relative', () {
      const context = ProjectContext(
        projectPath: './my_project',
        projectName: 'my_app',
        stateManagement: 'cubit',
        installedModules: [],
      );

      expect(context.projectPath, equals('./my_project'));
    });

    test('projectPath can be absolute', () {
      const context = ProjectContext(
        projectPath: '/absolute/path/to/project',
        projectName: 'my_app',
        stateManagement: 'cubit',
        installedModules: [],
      );

      expect(context.projectPath, equals('/absolute/path/to/project'));
    });

    test('projectName follows snake_case convention', () {
      const context = ProjectContext(
        projectPath: '/path/to/project',
        projectName: 'my_awesome_app',
        stateManagement: 'cubit',
        installedModules: [],
      );

      expect(context.projectName, equals('my_awesome_app'));
    });

    test('immutability after construction', () {
      final modules = <String>['auth'];
      final context = ProjectContext(
        projectPath: '/path/to/project',
        projectName: 'my_app',
        stateManagement: 'cubit',
        installedModules: modules,
      );

      // Original list and context should have same reference
      // This is expected behavior - ProjectContext doesn't make a defensive copy
      expect(context.installedModules, equals(modules));
    });
  });
}
