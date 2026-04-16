import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

@freezed
sealed class AppFailure with _$AppFailure {
  const AppFailure._();

  const factory AppFailure.server({
    required String message,
    int? statusCode,
    @Default('server_error') String code,
  }) = ServerFailure;

  const factory AppFailure.cache({
    required String message,
    @Default('cache_error') String code,
    int? statusCode,
  }) = CacheFailure;

  const factory AppFailure.network({
    @Default('No internet connection') String message,
    @Default('network_error') String code,
    int? statusCode,
  }) = NetworkFailure;

  const factory AppFailure.unauthorized({
    @Default('Authentication is required') String message,
    @Default(401) int statusCode,
    @Default('unauthorized') String code,
  }) = UnauthorizedFailure;

  const factory AppFailure.notFound({
    @Default('The requested resource was not found') String message,
    @Default(404) int statusCode,
    @Default('not_found') String code,
  }) = NotFoundFailure;

  const factory AppFailure.validation({
    @Default('Validation failed') String message,
    @Default(422) int statusCode,
    @Default('validation_error') String code,
    required Map<String, List<String>> fieldErrors,
  }) = ValidationFailure;

  const factory AppFailure.unexpected({
    @Default('An unexpected error occurred') String message,
    @Default('unexpected_error') String code,
    int? statusCode,
  }) = UnexpectedFailure;
}

typedef Failure = AppFailure;
