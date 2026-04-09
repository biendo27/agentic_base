# Coding Standards

## Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Files | snake_case | `home_cubit.dart` |
| Classes | PascalCase | `HomeCubit` |
| Variables | camelCase | `isLoading` |
| Constants | kCamelCase | `kDefaultTimeout` |
| Cubits | `<Feature>Cubit` | `ProfileCubit` |
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
- `*.config.dart` — injectable DI configuration

Run `make gen` after any model or annotation change.

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

### Cubit
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

## Analysis

Configuration in `analysis_options.yaml` uses `very_good_analysis`.
Run `dart analyze` or `make lint` before every commit.
Zero warnings policy — fix all issues, do not suppress without justification.
