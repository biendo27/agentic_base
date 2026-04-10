import 'package:agentic_base/src/modules/module_registry.dart';
import 'package:test/test.dart';

void main() {
  group('ModuleRegistry', () {
    test('all module names are registered', () {
      final allNames = ModuleRegistry.allNames;

      expect(allNames, contains('analytics'));
      expect(allNames, contains('auth'));
      expect(allNames, contains('crashlytics'));
      expect(allNames, contains('connectivity'));
      expect(allNames, contains('local_storage'));
      expect(allNames, contains('permissions'));
      expect(allNames, contains('secure_storage'));
      expect(allNames, contains('logging'));
      expect(allNames, contains('notifications'));
      expect(allNames, contains('deep_link'));
      expect(allNames, contains('in_app_review'));
      expect(allNames, contains('share'));
      expect(allNames, contains('social_login'));
      expect(allNames, contains('ads'));
      expect(allNames, contains('payments'));
      expect(allNames, contains('remote_config'));
      expect(allNames, contains('feature_flags'));
      expect(allNames, contains('image_picker'));
      expect(allNames, contains('camera'));
      expect(allNames, contains('video_player'));
      expect(allNames, contains('qr_scanner'));
      expect(allNames, contains('location'));
      expect(allNames, contains('maps'));
      expect(allNames, contains('biometric'));
      expect(allNames, contains('file_manager'));
      expect(allNames, contains('app_update'));
      expect(allNames, contains('webview'));
    });

    test('registry contains exactly 27 modules', () {
      final allNames = ModuleRegistry.allNames;
      expect(allNames.length, equals(27));
    });

    test('all module names are sorted', () {
      final allNames = ModuleRegistry.allNames;
      final sorted = List<String>.from(allNames)..sort();
      expect(allNames, equals(sorted));
    });

    test('find returns module by name', () {
      final module = ModuleRegistry.find('analytics');

      expect(module, isNotNull);
      expect(module!.name, equals('analytics'));
    });

    test('find returns null for unknown module', () {
      final module = ModuleRegistry.find('unknown_module');

      expect(module, isNull);
    });

    test('findOrThrow returns module by name', () {
      final module = ModuleRegistry.findOrThrow('auth');

      expect(module, isNotNull);
      expect(module.name, equals('auth'));
    });

    test('findOrThrow throws ArgumentError for unknown module', () {
      expect(
        () => ModuleRegistry.findOrThrow('unknown_module'),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Unknown module'),
          ),
        ),
      );
    });

    test('maps module has location as prerequisite', () {
      final module = ModuleRegistry.findOrThrow('maps');

      expect(module.requiresModules, contains('location'));
    });

    test('location module has permissions as prerequisite', () {
      final module = ModuleRegistry.findOrThrow('location');

      expect(module.requiresModules, contains('permissions'));
    });

    test('findConflicts returns empty list for no conflicts', () {
      final conflicts = ModuleRegistry.findConflicts(
        'analytics',
        installed: ['auth', 'payments'],
      );

      expect(conflicts, isEmpty);
    });

    test('findConflicts returns conflicting modules', () {
      final module = ModuleRegistry.findOrThrow('social_login');

      // Assuming social_login conflicts with something, test conflict detection
      if (module.conflictsWith.isNotEmpty) {
        final conflicts = ModuleRegistry.findConflicts(
          'social_login',
          installed: [module.conflictsWith.first],
        );

        expect(conflicts, isNotEmpty);
      }
    });

    test('missingPrerequisites detects direct dependencies', () {
      final missing = ModuleRegistry.missingPrerequisites(
        'maps',
        installed: [],
      );

      expect(missing, contains('location'));
    });

    test('missingPrerequisites detects transitive dependencies', () {
      final missing = ModuleRegistry.missingPrerequisites(
        'maps',
        installed: [],
      );

      // location requires permissions, so both should be missing
      expect(missing, contains('location'));
      expect(missing, contains('permissions'));
    });

    test('missingPrerequisites returns empty when all installed', () {
      final missing = ModuleRegistry.missingPrerequisites(
        'location',
        installed: ['location', 'permissions'],
      );

      expect(missing, isEmpty);
    });

    test('missingPrerequisites respects already installed modules', () {
      final missing = ModuleRegistry.missingPrerequisites(
        'maps',
        installed: ['permissions'],
      );

      // location should still be missing even if permissions is installed
      expect(missing, contains('location'));
    });

    test('missingPrerequisites for module with no dependencies', () {
      final module = ModuleRegistry.findOrThrow('analytics');

      if (module.requiresModules.isEmpty) {
        final missing = ModuleRegistry.missingPrerequisites(
          'analytics',
          installed: [],
        );

        expect(missing, isEmpty);
      }
    });

    test('dependentsOf returns modules that depend on given module', () {
      final dependents = ModuleRegistry.dependentsOf(
        'location',
        installed: ['location', 'maps', 'auth'],
      );

      // maps depends on location
      expect(dependents, contains('maps'));
    });

    test('dependentsOf returns empty when no dependents', () {
      final dependents = ModuleRegistry.dependentsOf(
        'analytics',
        installed: ['analytics', 'auth'],
      );

      expect(dependents, isEmpty);
    });

    test('dependentsOf only considers installed modules', () {
      final dependents = ModuleRegistry.dependentsOf(
        'location',
        installed: ['permissions', 'analytics'],
      );

      // maps depends on location but is not installed
      expect(dependents, isEmpty);
    });

    test('all registered modules have names', () {
      final allNames = ModuleRegistry.allNames;

      for (final name in allNames) {
        final module = ModuleRegistry.find(name);
        expect(module, isNotNull);
        expect(module!.name, isNotEmpty);
      }
    });

    test('all registered modules have descriptions', () {
      final allModules = ModuleRegistry.all;

      for (final module in allModules) {
        expect(module.description, isNotEmpty);
      }
    });

    test('all module names are lowercase', () {
      final allNames = ModuleRegistry.allNames;

      for (final name in allNames) {
        expect(name, equals(name.toLowerCase()));
      }
    });

    test('no duplicate module names', () {
      final allNames = ModuleRegistry.allNames;
      final uniqueNames = <String>{...allNames};

      expect(allNames.length, equals(uniqueNames.length));
    });

    test('auth module is registered', () {
      expect(ModuleRegistry.find('auth'), isNotNull);
    });

    test('payments module is registered', () {
      expect(ModuleRegistry.find('payments'), isNotNull);
    });

    test('analytics module is registered', () {
      expect(ModuleRegistry.find('analytics'), isNotNull);
    });
  });
}
