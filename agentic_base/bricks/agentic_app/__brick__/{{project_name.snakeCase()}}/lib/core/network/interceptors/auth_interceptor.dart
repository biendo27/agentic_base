import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Retrieve token from secure storage and attach as Bearer header.
    // Requires flutter_secure_storage or equivalent; injected via constructor.
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle token refresh or force logout here.
    }
    handler.next(err);
  }
}
