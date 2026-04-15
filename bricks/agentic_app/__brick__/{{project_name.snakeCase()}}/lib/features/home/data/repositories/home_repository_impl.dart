{{^is_riverpod}}
import 'package:injectable/injectable.dart';
{{/is_riverpod}}
import 'package:{{project_name.snakeCase()}}/core/contracts/app_result.dart';
import 'package:{{project_name.snakeCase()}}/core/error/error_handler.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/home_item.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/repositories/home_repository.dart';

{{^is_riverpod}}
@LazySingleton(as: HomeRepository)
{{/is_riverpod}}
class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<AppResult<List<HomeItem>>> getHomeItems() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return success(
        const <HomeItem>[
          HomeItem(id: 'ownership'),
          HomeItem(id: 'localization'),
          HomeItem(id: 'flavors'),
        ],
      );
    } on Object catch (error) {
      return failure(ErrorHandler.handle(error));
    }
  }
}
