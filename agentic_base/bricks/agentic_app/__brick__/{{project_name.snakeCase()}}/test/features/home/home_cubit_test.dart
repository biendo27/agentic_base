// ignore_for_file: prefer_const_constructors — test values are dynamic
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name.snakeCase()}}/core/error/failures.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/home_item.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/usecases/get_home_items.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/cubit/home_cubit.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/cubit/home_state.dart';

class MockGetHomeItems extends Mock implements GetHomeItems {}

void main() {
  late HomeCubit cubit;
  late MockGetHomeItems mockGetHomeItems;

  setUp(() {
    mockGetHomeItems = MockGetHomeItems();
    cubit = HomeCubit(mockGetHomeItems);
  });

  tearDown(() => cubit.close());

  test('initial state is HomeInitial', () {
    expect(cubit.state, equals(HomeState.initial()));
  });

  blocTest<HomeCubit, HomeState>(
    'emits [loading, loaded] when loadItems succeeds',
    build: () {
      when(() => mockGetHomeItems()).thenAnswer(
        (_) async => ([
          HomeItem(id: '1', title: 'Test', description: 'Desc'),
        ], null),
      );
      return cubit;
    },
    act: (cubit) => cubit.loadItems(),
    expect: () => [
      HomeState.loading(),
      isA<HomeLoaded>(),
    ],
  );

  blocTest<HomeCubit, HomeState>(
    'emits [loading, error] when loadItems fails',
    build: () {
      when(() => mockGetHomeItems()).thenAnswer(
        (_) async => (
          <HomeItem>[],
          UnexpectedFailure(message: 'fail'),
        ),
      );
      return cubit;
    },
    act: (cubit) => cubit.loadItems(),
    expect: () => [
      HomeState.loading(),
      HomeState.error('fail'),
    ],
  );
}
