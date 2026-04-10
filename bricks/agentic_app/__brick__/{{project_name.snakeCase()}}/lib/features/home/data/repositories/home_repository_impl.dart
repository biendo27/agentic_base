import 'package:{{project_name.snakeCase()}}/core/error/failures.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/home_item.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/repositories/home_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<(List<HomeItem>, Failure?)> getHomeItems() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return (
        const [
          HomeItem(id: 'ownership'),
          HomeItem(id: 'localization'),
          HomeItem(id: 'flavors'),
        ],
        null,
      );
    } on Exception catch (e) {
      return (
        <HomeItem>[],
        UnexpectedFailure(message: e.toString()),
      );
    }
  }
}
