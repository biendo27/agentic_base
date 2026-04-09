import 'dart:developer';

import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log(
      'API Error: ${err.requestOptions.method} ${err.requestOptions.path}',
      error: err,
    );
    handler.next(err);
  }
}
