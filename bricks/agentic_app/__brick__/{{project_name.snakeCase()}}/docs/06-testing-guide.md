# Testing Guide

## Verify Ladder

The primary verification surface is `./tools/verify.sh`. It runs the same local contract that CI wrappers call:

1. validate the contract surface
2. validate the declared Flutter toolchain
3. regenerate typed outputs and run static analysis
4. run unit and widget tests while excluding the dedicated app-shell smoke tag
5. run the dedicated starter app-shell smoke test once
6. run native readiness checks where the host can support them

`AGENTIC_VERIFY_FAST=1 ./tools/verify.sh` is only for local smoke loops and CI lanes that run another complete gate immediately after generation. It skips static analysis, unit/widget tests, and native readiness, so do not use it as a release gate.

Use `./tools/release-preflight.sh` before any upload-oriented release command.
Inspect evidence under `{{{evidence_dir}}}` for `summary.json`, gate check files, and logs.
Use `./tools/inspect-evidence.sh verify` for the latest derived run report.

## Manager-Aware Test Surface

Use the generated wrappers first:

- `./tools/test.sh` runs the manager-aware test command declared by `.info/agentic.yaml`
- `./tools/test.sh <path-or-args>` passes extra test arguments through to the resolved Flutter runtime
- `make test` is the shortest full-suite entrypoint
- `./tools/lint.sh --strict` runs `dart analyze --fatal-infos` when you need info-level lint enforcement
- `./tools/verify.sh` is the pre-review gate, not just another test command
- `./tools/inspect-evidence.sh <run-kind> [latest|run-id] [markdown|json]` renders the local evidence bundle through the shared inspect surface when `agentic_base` is available
- `test/app_smoke_test.dart` stays on the dedicated `app-shell-smoke` gate so verify avoids duplicate Flutter startup cost inside the broader suite

Do not bypass these wrappers unless you are debugging the wrapper itself.

## Generated Test Matrix

```text
test/
├── app_smoke_test.dart
├── core/contracts/
│   ├── app_list_response_test.dart
│   ├── app_response_test.dart
│   ├── localized_text_test.dart
│   └── pagination_test.dart
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

## Shared Contract Tests

The generated contract tests keep the shared model layer honest:

- `app_list_response_test.dart` covers dedicated list-envelope parsing and serialization
- `app_response_test.dart` covers response-envelope serialization and success semantics
- `pagination_test.dart` covers request serialization, reserved-key protection, and pagination helpers
- `localized_text_test.dart` covers runtime-agnostic locale lookup and fallback behavior

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
./tools/test.sh
./tools/test.sh test/features/home/
./tools/test.sh --coverage
./tools/lint.sh --strict
./tools/verify.sh
./tools/inspect-evidence.sh verify
make test
make verify
```

## Coverage Target

Aim for >80% coverage on:

- presentation controllers/stores
- use cases
- critical utility functions
- shared contracts that carry parsing or boundary rules

Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from coverage.
