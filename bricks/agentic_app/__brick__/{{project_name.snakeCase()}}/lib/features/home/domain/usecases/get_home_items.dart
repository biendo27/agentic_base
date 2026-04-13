import 'package:{{project_name.snakeCase()}}/core/error/failures.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/home_item.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/repositories/home_repository.dart';
{{^is_riverpod}}
import 'package:injectable/injectable.dart';
{{/is_riverpod}}

{{^is_riverpod}}
@injectable
{{/is_riverpod}}
class GetHomeItems {
  const GetHomeItems(this._repository);
  final HomeRepository _repository;

  Future<(List<HomeItem>, Failure?)> call() => _repository.getHomeItems();
}
