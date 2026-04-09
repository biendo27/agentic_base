import 'package:injectable/injectable.dart';
import 'package:my_app/core/error/failures.dart';
import 'package:my_app/features/home/domain/entities/home_item.dart';
import 'package:my_app/features/home/domain/repositories/home_repository.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<(List<HomeItem>, Failure?)> getHomeItems() async {
    try {
      // TODO(api): Replace with actual API call
      await Future<void>.delayed(const Duration(seconds: 1));
      return (
        List.generate(
          10,
          (i) => HomeItem(
            id: '$i',
            title: 'Item $i',
            description: 'Description for item $i',
          ),
        ),
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
