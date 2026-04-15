import 'package:{{project_name.snakeCase()}}/core/contracts/app_result.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/home_item.dart';

// ignore: one_member_abstracts — Clean Architecture contract pattern
abstract class HomeRepository {
  Future<AppResult<List<HomeItem>>> getHomeItems();
}
