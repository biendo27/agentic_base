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

## Test Structure

```
test/
├── app_smoke_test.dart       # Starter app-shell smoke path
├── features/
│   └── <name>/
│       ├── <name>_state_runtime_test.dart
│       └── mock_<name>_repository.dart
├── helpers/
│   ├── mock_helpers.dart    # Shared mocks
│   └── pump_app.dart        # Widget test helper
└── core/
    └── network/
        └── api_client_test.dart
```

## Unit Tests — State Runtime

{{#is_cubit}}Use `bloc_test` + `mocktail`:{{/is_cubit}}
{{#is_riverpod}}Use `ProviderContainer` + `mocktail`:{{/is_riverpod}}
{{#is_mobx}}Use `mobx` observable assertions + `mocktail`:{{/is_mobx}}

```dart
{{#is_cubit}}
class MockGetHomeItems extends Mock implements GetHomeItems {}

void main() {
  late HomeCubit cubit;
  late MockGetHomeItems mockGetHomeItems;

  setUp(() {
    mockGetHomeItems = MockGetHomeItems();
    cubit = HomeCubit(mockGetHomeItems);
  });

  tearDown(() => cubit.close());

  group('HomeCubit', () {
    blocTest<HomeCubit, HomeState>(
      'emits [loading, success] on successful load',
      build: () {
        when(() => mockGetHomeItems()).thenAnswer(
          (_) async => Right([HomeItem(id: '1', title: 'Test')]),
        );
        return cubit;
      },
      act: (c) => c.load(),
      expect: () => [
        const HomeState.loading(),
        isA<HomeState>().having(
          (s) => (s as dynamic).items,
          'items',
          isNotEmpty,
        ),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'emits [loading, failure] on error',
      build: () {
        when(() => mockGetHomeItems()).thenAnswer(
          (_) async => Left(ServerFailure('error')),
        );
        return cubit;
      },
      act: (c) => c.load(),
      expect: () => [
        const HomeState.loading(),
        isA<HomeState>(),
      ],
    );
  });
}
```
{{/is_cubit}}
{{#is_riverpod}}
class MockGetHomeItems extends Mock implements GetHomeItems {}

void main() {
  late ProviderContainer container;
  late MockGetHomeItems mockGetHomeItems;

  setUp(() {
    mockGetHomeItems = MockGetHomeItems();
    container = ProviderContainer(
      overrides: [
        getHomeItemsProvider.overrideWithValue(mockGetHomeItems),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('loads success state', () async {
    when(() => mockGetHomeItems()).thenAnswer(
      (_) async => (fakeItems, null),
    );

    await container.read(homeControllerProvider.notifier).loadItems();

    expect(container.read(homeControllerProvider), isA<HomeLoaded>());
  });
}
```
{{/is_riverpod}}
{{#is_mobx}}
class MockGetHomeItems extends Mock implements GetHomeItems {}

void main() {
  late HomeStore store;
  late MockGetHomeItems mockGetHomeItems;

  setUp(() {
    mockGetHomeItems = MockGetHomeItems();
    store = HomeStore(mockGetHomeItems);
  });

  test('loads success state', () async {
    when(() => mockGetHomeItems()).thenAnswer(
      (_) async => (fakeItems, null),
    );

    await store.loadItems();

    expect(store.state.value, isA<HomeLoaded>());
  });
}
```
{{/is_mobx}}

## Widget Tests

Use `pumpApp` helper from `test/helpers/pump_app.dart`:

```dart
testWidgets('shows loading indicator', (tester) async {
{{#is_cubit}}
  whenListen(
    mockCubit,
    Stream.value(const HomeState.loading()),
    initialState: const HomeState.initial(),
  );

  await tester.pumpApp(
    BlocProvider<HomeCubit>.value(
      value: mockCubit,
      child: const HomePage(),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```
{{/is_cubit}}
{{#is_riverpod}}
  await tester.pumpApp(
    ProviderScope(
      overrides: [
        homeControllerProvider.overrideWith(() => FakeHomeController()),
      ],
      child: const HomePage(),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```
{{/is_riverpod}}
{{#is_mobx}}
  final store = HomeStore(mockGetHomeItems);
  runInAction(() => store.state.value = const HomeState.loading());

  await tester.pumpApp(const HomePage());
  await tester.pump();

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```
{{/is_mobx}}

## Unit Tests — Use Cases

```dart
test('returns items from repository', () async {
  when(() => mockRepo.getItems()).thenAnswer(
    (_) async => Right(fakeItems),
  );

  final result = await getHomeItems();

  expect(result, Right(fakeItems));
  verify(() => mockRepo.getItems()).called(1);
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
