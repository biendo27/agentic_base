import 'package:injectable/injectable.dart';
import 'package:my_app/core/error/failures.dart';
import 'package:my_app/features/home/domain/entities/home_item.dart';
import 'package:my_app/features/home/domain/repositories/home_repository.dart';

@injectable
class GetHomeItems {
  const GetHomeItems(this._repository);
  final HomeRepository _repository;

  Future<(List<HomeItem>, Failure?)> call() => _repository.getHomeItems();
}
