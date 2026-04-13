import 'package:{{project_name.snakeCase()}}/core/error/failures.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/home_item.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/repositories/home_repository.dart';
{{^is_riverpod}}
import 'package:injectable/injectable.dart';
{{/is_riverpod}}

{{^is_riverpod}}
@LazySingleton(as: HomeRepository)
{{/is_riverpod}}
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
