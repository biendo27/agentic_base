import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name.snakeCase()}}/features/home/data/repositories/home_repository_impl.dart';

void main() {
  test('returns the starter dashboard checklist items', () async {
    final result = await HomeRepositoryImpl().getHomeItems();

    result.match(
      (failure) => fail('Expected starter items, got: ${failure.message}'),
      (items) => expect(
        items.map((item) => item.id).toList(),
        equals(['ownership', 'localization', 'flavors']),
      ),
    );
  });
}
