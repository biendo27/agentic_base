import 'package:agentic_base/src/tui/prompts.dart';
import 'package:test/test.dart';

void main() {
  group('Prompts Constants', () {
    test('defaultPlatforms contains expected values', () {
      expect(defaultPlatforms, equals(['android', 'ios', 'web']));
    });

    test('defaultPlatforms is a list of strings', () {
      expect(defaultPlatforms, everyElement(isA<String>()));
    });

    test('defaultPlatforms has exactly 3 platforms', () {
      expect(defaultPlatforms.length, equals(3));
    });

    test('allPlatforms contains all supported platforms', () {
      expect(allPlatforms, contains('android'));
      expect(allPlatforms, contains('ios'));
      expect(allPlatforms, contains('web'));
      expect(allPlatforms, contains('macos'));
      expect(allPlatforms, contains('windows'));
      expect(allPlatforms, contains('linux'));
    });

    test('allPlatforms has exactly 6 platforms', () {
      expect(allPlatforms.length, equals(6));
    });

    test('allPlatforms is a list of strings', () {
      expect(allPlatforms, everyElement(isA<String>()));
    });

    test('defaultPlatforms are subset of allPlatforms', () {
      for (final platform in defaultPlatforms) {
        expect(allPlatforms, contains(platform));
      }
    });

    test('stateManagementOptions contains expected values', () {
      expect(stateManagementOptions, contains('cubit'));
      expect(stateManagementOptions, contains('riverpod'));
      expect(stateManagementOptions, contains('mobx'));
    });

    test('stateManagementOptions has exactly 3 options', () {
      expect(stateManagementOptions.length, equals(3));
    });

    test('stateManagementOptions is a list of strings', () {
      expect(stateManagementOptions, everyElement(isA<String>()));
    });

    test('defaultFlavors contains expected values', () {
      expect(defaultFlavors, equals(['dev', 'staging', 'prod']));
    });

    test('defaultFlavors is a list of strings', () {
      expect(defaultFlavors, everyElement(isA<String>()));
    });

    test('defaultFlavors has exactly 3 flavors', () {
      expect(defaultFlavors.length, equals(3));
    });

    test('all platforms are lowercase', () {
      for (final platform in allPlatforms) {
        expect(platform, equals(platform.toLowerCase()));
      }
    });

    test('all state management options are lowercase', () {
      for (final option in stateManagementOptions) {
        expect(option, equals(option.toLowerCase()));
      }
    });

    test('all flavors are lowercase', () {
      for (final flavor in defaultFlavors) {
        expect(flavor, equals(flavor.toLowerCase()));
      }
    });

    test('no duplicate platforms', () {
      final unique = <String>{...allPlatforms};
      expect(allPlatforms.length, equals(unique.length));
    });

    test('no duplicate state management options', () {
      final unique = <String>{...stateManagementOptions};
      expect(stateManagementOptions.length, equals(unique.length));
    });

    test('no duplicate flavors', () {
      final unique = <String>{...defaultFlavors};
      expect(defaultFlavors.length, equals(unique.length));
    });

    test('platforms are common platform names', () {
      expect(allPlatforms, contains('ios'));
      expect(allPlatforms, contains('android'));
      expect(allPlatforms, contains('web'));
    });

    test('state management options are known frameworks', () {
      expect(stateManagementOptions, contains('cubit'));
      expect(stateManagementOptions, contains('riverpod'));
      expect(stateManagementOptions, contains('mobx'));
    });
  });
}
