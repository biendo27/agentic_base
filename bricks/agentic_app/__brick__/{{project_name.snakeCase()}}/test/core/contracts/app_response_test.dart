import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name.snakeCase()}}/core/contracts/app_response.dart';

void main() {
  test('deserializes and serializes the shared response envelope', () {
    final response = AppResponse<int>.fromJson(
      <String, Object?>{
        'success': true,
        'message': 'ok',
        'code': 'accepted',
        'status_code': 202,
        'data': 7,
        'metadata': <String, Object?>{'source': 'cache'},
      },
      (json) => json as int?,
    );

    expect(response.isSuccess, isTrue);
    expect(response.hasData, isTrue);
    expect(response.data, 7);
    expect(
      response.toJson((value) => value),
      <String, Object?>{
        'success': true,
        'message': 'ok',
        'code': 'accepted',
        'status_code': 202,
        'data': 7,
        'metadata': <String, Object?>{'source': 'cache'},
      },
    );
  });

  test(
    'treats failing status codes as unsuccessful even when status is absent',
    () {
      final response = AppResponse<String>.fromJson(
        <String, Object?>{
          'status_code': 500,
          'message': 'boom',
        },
        (_) => null,
      );

      expect(response.isSuccess, isFalse);
      expect(response.hasData, isFalse);
    },
  );
}
