import 'package:dio/dio.dart';
import 'package:my_app/core/error/failures.dart';

class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    }
    return UnexpectedFailure(message: error.toString());
  }

  static Failure _handleDioError(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const NetworkFailure(message: 'Connection timeout'),
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.badResponse => ServerFailure(
          message: error.response?.statusMessage ?? 'Server error',
          statusCode: error.response?.statusCode,
        ),
      _ => UnexpectedFailure(message: error.message ?? 'Unknown error'),
    };
  }
}
