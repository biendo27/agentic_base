import 'package:my_app/core/error/failures.dart';
import 'package:my_app/features/home/domain/entities/home_item.dart';

abstract class HomeRepository {
  Future<(List<HomeItem>, Failure?)> getHomeItems();
}
