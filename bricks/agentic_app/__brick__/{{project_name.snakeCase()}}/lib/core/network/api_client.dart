import 'package:dio/dio.dart';
{{^is_riverpod}}
import 'package:injectable/injectable.dart';
{{/is_riverpod}}
import 'package:{{project_name.snakeCase()}}/app/flavors.dart';
import 'package:{{project_name.snakeCase()}}/core/network/interceptors/error_interceptor.dart';
import 'package:{{project_name.snakeCase()}}/core/network/interceptors/logging_interceptor.dart';
import 'package:{{project_name.snakeCase()}}/core/network/interceptors/observability_interceptor.dart';

{{^is_riverpod}}
@module
{{/is_riverpod}}
abstract class NetworkModule {
{{^is_riverpod}}
  @lazySingleton
{{/is_riverpod}}
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
      ObservabilityInterceptor(),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
    return dio;
  }
}
