# State Management

The selected runtime is persisted in `.info/agentic.yaml` and mirrored here as canonical human-readable context.

## Active Runtime

- Selected runtime: `{{state_display_name}}`
- Shared presentation state type: `HomeState` (`initial`, `loading`, `loaded`, `error`)
- Shared domain contract: presentation reads the same `GetHomeItems` use case and converts `AppResult<T>` into UI state

## Starter Home Runtime

{{#is_cubit}}
### Cubit + get_it/injectable

- runtime file: `lib/features/home/presentation/cubit/home_cubit.dart`
- injection: `getIt<HomeCubit>()`
- widget consumption: `BlocProvider` + `BlocBuilder`
- debug transitions: `AppBlocObserver`

```dart
@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getHomeItems) : super(const HomeState.initial());

  final GetHomeItems _getHomeItems;

  Future<void> loadItems() async {
    emit(const HomeState.loading());
    final result = await _getHomeItems();
    result.match(
      (failure) => emit(HomeState.error(failure.message)),
      (items) => emit(HomeState.loaded(items)),
    );
  }
}
```
{{/is_cubit}}

{{#is_riverpod}}
### Riverpod Notifier

- runtime file: `lib/features/home/presentation/controller/home_controller.dart`
- composition: repository provider -> use-case provider -> notifier provider
- widget consumption: `ConsumerWidget` / `WidgetRef`
- no `get_it` or `injectable` runtime for the starter shell

```dart
final homeControllerProvider =
    NotifierProvider<HomeController, HomeState>(HomeController.new);

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState.initial();

  Future<void> loadItems() async {
    state = const HomeState.loading();
    final result = await ref.read(getHomeItemsProvider)();
    state = result.match(
      (failure) => HomeState.error(failure.message),
      HomeState.loaded,
    );
  }
}
```
{{/is_riverpod}}

{{#is_mobx}}
### MobX Store

- runtime file: `lib/features/home/presentation/store/home_store.dart`
- injection: `getIt<HomeStore>()`
- widget consumption: `Observer`
- state holder: `Observable<HomeState>`

```dart
@injectable
class HomeStore {
  HomeStore(this._getHomeItems);

  final GetHomeItems _getHomeItems;
  final Observable<HomeState> state = Observable(const HomeState.initial());

  Future<void> loadItems() async {
    runInAction(() => state.value = const HomeState.loading());
    final result = await _getHomeItems();
    runInAction(() {
      state.value = result.match(
        (failure) => HomeState.error(failure.message),
        HomeState.loaded,
      );
    });
  }
}
```
{{/is_mobx}}

## Testing Surface

{{#is_cubit}}- runtime regression test: `test/features/home/home_cubit_test.dart`{{/is_cubit}}
{{#is_riverpod}}- runtime regression test: `test/features/home/home_controller_test.dart`{{/is_riverpod}}
{{#is_mobx}}- runtime regression test: `test/features/home/home_store_test.dart`{{/is_mobx}}
- all runtimes still share the same repository tests and starter widget test
