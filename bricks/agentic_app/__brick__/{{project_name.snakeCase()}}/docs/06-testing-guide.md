# Testing Guide

## Verify Ladder

The primary verification surface is `./tools/verify.sh`. It runs the same local contract that CI wrappers call:

1. validate the contract surface
2. validate the declared Flutter toolchain
3. regenerate typed outputs and run static analysis
4. run unit and widget tests
5. run the starter app-shell smoke test
6. run native readiness checks where the host can support them

Use `./tools/release-preflight.sh` before any upload-oriented release command.
Inspect evidence under `{{{evidence_dir}}}` for `summary.json`, gate check files, and logs.

## Generated Test Matrix

```text
test/
├── app_smoke_test.dart
├── features/home/
│   ├── data/repositories/demo_starter_monetization_repository_test.dart
│   ├── data/repositories/home_repository_impl_test.dart
{{#is_cubit}}│   ├── home_cubit_test.dart{{/is_cubit}}
{{#is_riverpod}}│   ├── home_controller_test.dart{{/is_riverpod}}
{{#is_mobx}}│   ├── home_store_test.dart{{/is_mobx}}
│   └── presentation/widgets/starter_action_card_test.dart
└── helpers/pump_app.dart
```

## Starter Service Tests

Repository tests prove the starter-owned seams without relying on full app boot:

- `home_repository_impl_test.dart` proves the dashboard checklist contract
- `demo_starter_monetization_repository_test.dart` proves the provider-neutral paywall snapshot

```dart
test('returns the starter dashboard checklist items', () async {
  final result = await HomeRepositoryImpl().getHomeItems();

  result.match(
    (failure) => fail('Expected starter items, got: ${failure.message}'),
    (items) => expect(
      items.map((item) => item.id).toList(),
      equals(['ownership', 'localization', 'flavors']),
    ),
  );
});
```

## State Runtime Tests

{{#is_cubit}}`test/features/home/home_cubit_test.dart` proves initial, loading, loaded, and error behavior for `HomeCubit`.{{/is_cubit}}
{{#is_riverpod}}`test/features/home/home_controller_test.dart` proves initial and loaded behavior for `homeControllerProvider`.{{/is_riverpod}}
{{#is_mobx}}`test/features/home/home_store_test.dart` proves initial and loaded behavior for `HomeStore`.{{/is_mobx}}

```dart
{{#is_cubit}}
blocTest<HomeCubit, HomeState>(
  'emits [loading, error] when loadItems fails',
  build: () {
    when(() => mockGetHomeItems()).thenAnswer(
      (_) async => failure(const UnexpectedFailure(message: 'fail')),
    );
    return cubit;
  },
  act: (cubit) => cubit.loadItems(),
  expect: () => [
    HomeState.loading(),
    HomeState.error('fail'),
  ],
);
{{/is_cubit}}
{{#is_riverpod}}
test('loadItems emits loaded state', () async {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  await container.read(homeControllerProvider.notifier).loadItems();

  expect(container.read(homeControllerProvider), isA<HomeLoaded>());
});
{{/is_riverpod}}
{{#is_mobx}}
test('loadItems emits loaded state', () async {
  await store.loadItems();

  expect(store.state.value, isA<HomeLoaded>());
});
{{/is_mobx}}
```

## Widget Tests

Use `pumpApp` from `test/helpers/pump_app.dart` for small starter widgets:

```dart
import '../../../../helpers/pump_app.dart';

testWidgets('renders the starter CTA and reacts to taps', (tester) async {
  var tapped = false;

  await tester.pumpApp(
    StarterActionCard(
      icon: Icons.settings_outlined,
      title: 'Starter settings',
      description: 'Preview locale and theme behavior.',
      onTap: () => tapped = true,
    ),
  );

  await tester.tap(find.text('Starter settings'));

  expect(tapped, isTrue);
});
```

## Running Tests

```bash
./tools/verify.sh                     # full local verify ladder
flutter test                          # all tests
flutter test test/features/home/      # single feature
flutter test --coverage               # with coverage
genhtml coverage/lcov.info -o coverage/html  # HTML report
```

Or use: `make verify` / `make test`

## Coverage Target

Aim for >80% coverage on:
- All presentation controllers/stores
- All use cases
- Critical utility functions

Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from coverage.
