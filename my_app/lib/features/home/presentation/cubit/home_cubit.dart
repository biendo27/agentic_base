import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/features/home/domain/usecases/get_home_items.dart';
import 'package:my_app/features/home/presentation/cubit/home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getHomeItems) : super(const HomeState.initial());

  final GetHomeItems _getHomeItems;

  Future<void> loadItems() async {
    emit(const HomeState.loading());
    final (items, failure) = await _getHomeItems();
    if (failure != null) {
      emit(HomeState.error(failure.message));
    } else {
      emit(HomeState.loaded(items));
    }
  }
}
