import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_response.freezed.dart';

@freezed
abstract class AppResponse<T> with _$AppResponse<T> {
  const AppResponse._();

  const factory AppResponse({
    required T data,
    String? message,
    int? statusCode,
    @Default(<String, Object?>{}) Map<String, Object?> metadata,
  }) = _AppResponse<T>;

  bool get isSuccess => statusCode == null || statusCode! < 400;
}
