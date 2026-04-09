# State Management

## Technology: flutter_bloc / Cubit

Cubit is preferred over full Bloc for simplicity. Use Bloc only when event-driven
history or transformation is required.

## State Design

States are **sealed classes** using `@freezed`. Each feature defines its own state.

### Standard State Shape
```dart
@freezed
sealed class FeatureState with _$FeatureState {
  const factory FeatureState.initial() = _Initial;
  const factory FeatureState.loading() = _Loading;
  const factory FeatureState.success(FeatureData data) = _Success;
  const factory FeatureState.failure(String message) = _Failure;
}
```

### When to Add States
- `initial` — before any action (always required)
- `loading` — async operation in progress
- `success` — data available
- `failure` — error with message
- Additional states only when UI needs distinct rendering

## Cubit Patterns

### Constructor injection (get_it + injectable)
```dart
@injectable
class FeatureCubit extends Cubit<FeatureState> {
  FeatureCubit(this._useCase) : super(const FeatureState.initial());

  final UseCaseName _useCase;
}
```

### Safe async emission
```dart
Future<void> load() async {
  if (isClosed) return;
  emit(const FeatureState.loading());
  try {
    final result = await _useCase(params);
    if (!isClosed) emit(FeatureState.success(result));
  } catch (e) {
    if (!isClosed) emit(FeatureState.failure(e.toString()));
  }
}
```

## UI Consumption

### BlocProvider (page level)
```dart
BlocProvider(
  create: (context) => getIt<FeatureCubit>()..load(),
  child: const FeaturePage(),
)
```

### BlocBuilder
```dart
BlocBuilder<FeatureCubit, FeatureState>(
  builder: (context, state) => switch (state) {
    _Initial() => const SizedBox.shrink(),
    _Loading() => const CircularProgressIndicator(),
    _Success(:final data) => FeatureContent(data: data),
    _Failure(:final message) => ErrorView(message: message),
  },
)
```

## Testing Cubits

```dart
blocTest<FeatureCubit, FeatureState>(
  'emits [loading, success] when load succeeds',
  build: () {
    when(() => mockUseCase()).thenAnswer((_) async => Right(fakeData));
    return FeatureCubit(mockUseCase);
  },
  act: (cubit) => cubit.load(),
  expect: () => [
    const FeatureState.loading(),
    FeatureState.success(fakeData),
  ],
);
```

## BlocObserver

`AppBlocObserver` in `lib/app/observers/` logs all transitions in debug builds.
Do not remove — it provides crucial debugging information.
