import 'package:dio/dio.dart';
import 'package:{{project_name.snakeCase()}}/core/observability/observability_service.dart';
import 'package:{{project_name.snakeCase()}}/core/observability/redaction_policy.dart';
import 'package:{{project_name.snakeCase()}}/core/observability/trace_context.dart';

class ObservabilityInterceptor extends Interceptor {
  static const _traceKey = 'observability_trace_context';
  static const _redactionPolicy = RedactionPolicy();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final trace = ObservabilityService.instance.startSpan(
      'network.request',
      fields: <String, Object?>{
        'method': options.method,
        'path': _redactionPolicy.sanitizePath(options.path),
        'header_keys': _redactionPolicy.sanitizeKeys(options.headers.keys),
        'query_keys': _redactionPolicy.sanitizeKeys(
          options.queryParameters.keys,
        ),
        'has_body': options.data != null,
      },
    );
    options.extra[_traceKey] = trace;
    options.headers.putIfAbsent('x-correlation-id', () => trace.traceId);
    ObservabilityService.instance.increment('network_requests');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final requestOptions = response.requestOptions;
    final trace = requestOptions.extra[_traceKey] as TraceContext?;
    if (trace != null) {
      ObservabilityService.instance.finishSpan(
        trace,
        fields: <String, Object?>{
          'path': _redactionPolicy.sanitizePath(requestOptions.path),
          'status_code': response.statusCode,
        },
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final requestOptions = err.requestOptions;
    final trace = requestOptions.extra[_traceKey] as TraceContext?;
    ObservabilityService.instance.increment('network_errors');
    if (trace != null) {
      ObservabilityService.instance.finishSpan(
        trace,
        state: 'error',
        fields: <String, Object?>{
          'path': _redactionPolicy.sanitizePath(requestOptions.path),
          'status_code': err.response?.statusCode,
          'error_type': err.type.name,
        },
      );
    }
    handler.next(err);
  }
}
