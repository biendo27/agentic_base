import 'package:agentic_base/src/config/state_config.dart';
import 'package:test/test.dart';

void main() {
  group('StateConfig', () {
    test('cubit has correct packages', () {
      const config = StateConfig.cubit;

      expect(config.packages, contains('flutter_bloc'));
      expect(config.packages, contains('get_it'));
      expect(config.packages, contains('injectable'));
      expect(config.packages['flutter_bloc'], equals('^9.1.1'));
    });

    test('cubit has correct dev packages', () {
      const config = StateConfig.cubit;

      expect(config.devPackages, contains('bloc_test'));
      expect(config.devPackages, contains('injectable_generator'));
      expect(config.devPackages['bloc_test'], equals('^10.0.0'));
    });

    test('cubit uses get_it DI system', () {
      const config = StateConfig.cubit;
      expect(config.diSystem, equals('get_it'));
    });

    test('riverpod has correct packages', () {
      const config = StateConfig.riverpod;

      expect(config.packages, contains('flutter_riverpod'));
      expect(config.packages, contains('riverpod_annotation'));
      expect(config.packages['flutter_riverpod'], equals('^2.6.1'));
    });

    test('riverpod has correct dev packages', () {
      const config = StateConfig.riverpod;

      expect(config.devPackages, contains('riverpod_generator'));
      expect(config.devPackages, contains('riverpod_lint'));
    });

    test('riverpod uses riverpod DI system', () {
      const config = StateConfig.riverpod;
      expect(config.diSystem, equals('riverpod'));
    });

    test('mobx has correct packages', () {
      const config = StateConfig.mobx;

      expect(config.packages, contains('flutter_mobx'));
      expect(config.packages, contains('mobx'));
      expect(config.packages, contains('get_it'));
      expect(config.packages, contains('injectable'));
      expect(config.packages['flutter_mobx'], equals('^2.2.1'));
    });

    test('mobx has correct dev packages', () {
      const config = StateConfig.mobx;

      expect(config.devPackages, contains('mobx_codegen'));
      expect(config.devPackages, contains('build_runner'));
      expect(config.devPackages, contains('injectable_generator'));
    });

    test('mobx uses get_it DI system', () {
      const config = StateConfig.mobx;
      expect(config.diSystem, equals('get_it'));
    });

    test('fromString returns cubit for "cubit"', () {
      final config = StateConfig.fromString('cubit');
      expect(config, equals(StateConfig.cubit));
    });

    test('fromString returns riverpod for "riverpod"', () {
      final config = StateConfig.fromString('riverpod');
      expect(config, equals(StateConfig.riverpod));
    });

    test('fromString returns mobx for "mobx"', () {
      final config = StateConfig.fromString('mobx');
      expect(config, equals(StateConfig.mobx));
    });

    test('fromString throws ArgumentError for unknown name', () {
      expect(
        () => StateConfig.fromString('unknown'),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Unknown state management'),
        )),
      );
    });

    test('fromString throws ArgumentError for empty string', () {
      expect(
        () => StateConfig.fromString(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('displayName for cubit', () {
      expect(StateConfig.cubit.displayName, equals('Flutter Bloc / Cubit'));
    });

    test('displayName for riverpod', () {
      expect(StateConfig.riverpod.displayName, equals('Riverpod'));
    });

    test('displayName for mobx', () {
      expect(StateConfig.mobx.displayName, equals('MobX'));
    });

    test('cubit and riverpod have different packages', () {
      expect(
        StateConfig.cubit.packages,
        isNot(equals(StateConfig.riverpod.packages)),
      );
    });

    test('cubit and mobx both use get_it DI system', () {
      expect(StateConfig.cubit.diSystem, equals(StateConfig.mobx.diSystem));
    });

    test('all configs have at least one package', () {
      expect(StateConfig.cubit.packages.isNotEmpty, true);
      expect(StateConfig.riverpod.packages.isNotEmpty, true);
      expect(StateConfig.mobx.packages.isNotEmpty, true);
    });

    test('all configs have at least one dev package', () {
      expect(StateConfig.cubit.devPackages.isNotEmpty, true);
      expect(StateConfig.riverpod.devPackages.isNotEmpty, true);
      expect(StateConfig.mobx.devPackages.isNotEmpty, true);
    });

    test('package versions are valid semantic version constraints', () {
      for (final config in [StateConfig.cubit, StateConfig.riverpod, StateConfig.mobx]) {
        for (final version in config.packages.values) {
          expect(version, matches(RegExp(r'^[\^~>=<]')));
        }
        for (final version in config.devPackages.values) {
          expect(version, matches(RegExp(r'^[\^~>=<]')));
        }
      }
    });
  });
}
