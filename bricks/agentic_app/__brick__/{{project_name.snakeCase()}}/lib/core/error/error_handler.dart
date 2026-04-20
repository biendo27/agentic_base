import 'package:dio/dio.dart';
import 'package:{{project_name.snakeCase()}}/core/error/failures.dart';

class ErrorHandler {
  static AppFailure handle(Object error) {
    if (error is AppFailure) {
      return error;
    }
    if (error is DioException && error.error is AppFailure) {
      return error.error! as AppFailure;
    }
    if (error is DioException) {
      return _handleDioError(error);
    }
    return UnexpectedFailure(message: error.toString());
  }

  static AppFailure _handleDioError(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const NetworkFailure(
        message: 'Connection timeout',
      ),
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.badResponse => _handleBadResponse(error),
      _ => UnexpectedFailure(message: error.message ?? 'Unknown error'),
    };
  }

  static AppFailure _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    return switch (statusCode) {
      401 => const UnauthorizedFailure(),
      404 => const NotFoundFailure(),
      422 => ValidationFailure(
        message: error.response?.statusMessage ?? 'Validation failed',
        fieldErrors: _readFieldErrors(error.response?.data),
      ),
      _ => ServerFailure(
        message: error.response?.statusMessage ?? 'Server error',
        statusCode: statusCode,
      ),
    };
  }

  static Map<String, List<String>> _readFieldErrors(Object? data) {
    if (data is! Map<String, dynamic>) {
      return const {};
    }

    final fieldErrors = data['errors'];
    if (fieldErrors is! Map<String, dynamic>) {
      return const {};
    }

    return fieldErrors.map(
      (key, value) => MapEntry(key, _normalizeFieldErrorValue(value)),
    );
  }

  static List<String> _normalizeFieldErrorValue(Object? value) {
    if (value is List<Object?>) {
      return value.map((item) => '$item').toList(growable: false);
    }
    if (value == null) {
      return const [];
    }
    return <String>['$value'];
  }
}
