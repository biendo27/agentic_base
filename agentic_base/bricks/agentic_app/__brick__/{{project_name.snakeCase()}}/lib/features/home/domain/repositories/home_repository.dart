import 'package:{{project_name.snakeCase()}}/core/error/failures.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/home_item.dart';

abstract class HomeRepository {
  Future<(List<HomeItem>, Failure?)> getHomeItems();
}
