# Testing Guide

## Test Structure

```
test/
├── features/
│   └── <name>/
│       ├── <name>_cubit_test.dart
│       └── mock_<name>_repository.dart
├── helpers/
│   ├── mock_helpers.dart    # Shared mocks
│   └── pump_app.dart        # Widget test helper
└── core/
    └── network/
        └── api_client_test.dart
```

## Unit Tests — Cubits

Use `bloc_test` + `mocktail`:

```dart
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

## Widget Tests

Use `pumpApp` helper from `test/helpers/pump_app.dart`:

```dart
testWidgets('shows loading indicator', (tester) async {
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
flutter test                          # all tests
flutter test test/features/home/      # single feature
flutter test --coverage               # with coverage
genhtml coverage/lcov.info -o coverage/html  # HTML report
```

Or use: `make test`

## Coverage Target

Aim for >80% coverage on:
- All Cubit classes
- All use cases
- Critical utility functions

Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from coverage.
