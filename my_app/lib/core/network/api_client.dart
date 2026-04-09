import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:my_app/app/flavors.dart';
import 'package:my_app/core/network/interceptors/error_interceptor.dart';
import 'package:my_app/core/network/interceptors/logging_interceptor.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: FlavorConfig.instance.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.addAll([
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
    return dio;
  }
}
