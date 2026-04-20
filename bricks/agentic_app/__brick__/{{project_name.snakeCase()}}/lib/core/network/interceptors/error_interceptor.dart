import 'package:dio/dio.dart';
import 'package:{{project_name.snakeCase()}}/core/error/error_handler.dart';
import 'package:{{project_name.snakeCase()}}/core/observability/observability_service.dart';
import 'package:{{project_name.snakeCase()}}/core/observability/redaction_policy.dart';

class ErrorInterceptor extends Interceptor {
  static const _redactionPolicy = RedactionPolicy();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final mappedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: ErrorHandler.handle(err),
      stackTrace: err.stackTrace,
      message: err.message,
    );
    ObservabilityService.instance.log(
      'network.error',
      level: 'error',
      fields: <String, Object?>{
        'method': err.requestOptions.method,
        'path': _redactionPolicy.sanitizePath(err.requestOptions.path),
        'status_code': err.response?.statusCode,
        'error_type': mappedError.error.runtimeType.toString(),
        'error_message': _redactionPolicy.summarizeObject(mappedError.error),
      },
    );
    handler.next(mappedError);
  }
}
