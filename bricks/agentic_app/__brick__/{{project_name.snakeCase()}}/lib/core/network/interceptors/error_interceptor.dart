import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:{{project_name.snakeCase()}}/core/error/error_handler.dart';

class ErrorInterceptor extends Interceptor {
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
    log(
      'API Error: ${err.requestOptions.method} ${err.requestOptions.path}',
      error: mappedError.error,
    );
    handler.next(mappedError);
  }
}
