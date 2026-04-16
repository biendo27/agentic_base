# Coding Standards

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Files | snake_case | `home_state.dart` |
| Classes | PascalCase | `HomeState` |
| Variables | camelCase | `isLoading` |
| Constants | kCamelCase | `kDefaultTimeout` |
| Presentation controllers | runtime-specific | `ProfileCubit`, `ProfileController`, `ProfileStore` |
| States | `<Feature>State` | `ProfileState` |
| Use cases | verb phrase | `GetHomeItems` |
| Repos (interface) | `<Name>Repository` | `HomeRepository` |
| Repos (impl) | `<Name>RepositoryImpl` | `HomeRepositoryImpl` |

## Imports

Always use **package imports**. Relative imports are forbidden.

```dart
// Good
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/home_item.dart';

// Bad — never use relative
import '../../../domain/entities/home_item.dart';
```

Import ordering (enforced by very_good_analysis):
1. `dart:` SDK imports
2. `package:flutter/` imports
3. Third-party packages
4. Internal package imports

## File Size

- Hard limit: **200 lines per file**
- Split large widgets into sub-widgets in `widgets/` subdirectory
- Extract utility functions to dedicated files in `lib/shared/utils/`

## Generated Files

Never manually edit:
- `*.g.dart` — JSON serialization
- `*.freezed.dart` — Freezed unions/data classes
- `*.gr.dart` — auto_route generated routes
{{#uses_get_it}}- `*.config.dart` — injectable DI configuration{{/uses_get_it}}

Run `make gen` after any model or annotation change.

Keep `library` + `part` limited to codegen-required leaf files such as Freezed,
JsonSerializable, auto_route, and injectable outputs. Repositories, use cases,
pages, modules, and services stay as normal files with imports.

Keep `lib/core/contracts` runtime-agnostic:
- invariants and value behavior live on the contract class
- helpers with explicit caller input are allowed on the class
- locale-, DI-, or app-runtime-aware convenience belongs in extensions or services outside raw contracts

## Code Patterns

### Freezed State
```dart
@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loading() = _Loading;
  const factory HomeState.success(List<HomeItem> items) = _Success;
  const factory HomeState.failure(String message) = _Failure;
}
```

### Data/Domain Boundary
```dart
abstract class HomeRepository {
  Future<AppResult<List<HomeItem>>> getHomeItems();
}
```

### State Runtime
{{#is_cubit}}
```dart
@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getHomeItems) : super(const HomeState.initial());

  final GetHomeItems _getHomeItems;

  Future<void> load() async {
    emit(const HomeState.loading());
    final result = await _getHomeItems();
    result.fold(
      (failure) => emit(HomeState.failure(failure.message)),
      (items) => emit(HomeState.success(items)),
    );
  }
}
```
{{/is_cubit}}
{{#is_riverpod}}
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

## Analysis

Configuration in `analysis_options.yaml` uses `very_good_analysis`.
Run `dart analyze` or `make lint` before every commit.
Zero warnings policy — fix all issues, do not suppress without justification.
