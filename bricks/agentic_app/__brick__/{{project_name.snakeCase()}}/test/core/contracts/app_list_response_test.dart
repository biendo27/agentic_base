import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name.snakeCase()}}/core/contracts/app_list_response.dart';

void main() {
  test(
    'deserializes and serializes list payloads through dedicated helpers',
    () {
      final response = AppListResponse<int>.fromJson(
        <String, Object?>{
          'success': true,
          'status_code': 200,
          'data': <Object?>[1, 2, 3],
        },
        (json) => json as int,
      );

      expect(response.isSuccess, isTrue);
      expect(response.hasData, isTrue);
      expect(response.data, <int>[1, 2, 3]);
      expect(
        response.toJson((value) => value),
        <String, Object?>{
          'success': true,
          'status_code': 200,
          'data': <Object?>[1, 2, 3],
        },
      );
    },
  );

  test('normalizes absent list data to an empty collection', () {
    final response = AppListResponse<String>.fromJson(
      <String, Object?>{
        'success': true,
      },
      (json) => json as String,
    );

    expect(response.hasData, isFalse);
    expect(response.data, isEmpty);
  });
}
