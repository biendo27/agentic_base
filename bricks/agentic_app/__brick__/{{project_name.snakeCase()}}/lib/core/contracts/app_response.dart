import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_response.freezed.dart';

@freezed
abstract class AppResponse<T> with _$AppResponse<T> {
  const AppResponse._();

  const factory AppResponse({
    @Default(true) bool success,
    String? message,
    String? code,
    int? statusCode,
    T? data,
    @Default(<String, Object?>{}) Map<String, Object?> metadata,
  }) = _AppResponse<T>;

  factory AppResponse.fromJson(
    Map<String, Object?> json,
    T? Function(Object? json) fromJsonT,
  ) {
    final statusCode = _readInt(json['status_code'] ?? json['statusCode']);
    final metadata = _readObjectMap(json['metadata']);
    final successValue = json['success'] ?? json['status'];

    return AppResponse<T>(
      success: _readSuccess(successValue, statusCode),
      message: _readString(json['message']),
      code: _readString(json['code']),
      statusCode: statusCode,
      data: json.containsKey('data') ? fromJsonT(json['data']) : null,
      metadata: metadata,
    );
  }
}

extension AppResponseX<T> on AppResponse<T> {
  bool get isSuccess => success && (statusCode == null || statusCode! < 400);
  bool get hasData => data != null;

  Map<String, Object?> toJson(Object? Function(T value) toJsonT) {
    return <String, Object?>{
      'success': success,
      if (message != null) 'message': message,
      if (code != null) 'code': code,
      if (statusCode != null) 'status_code': statusCode,
      if (data case final value?) 'data': toJsonT(value),
      if (metadata.isNotEmpty) 'metadata': metadata,
    };
  }
}

bool _readSuccess(Object? value, int? statusCode) {
  if (value is bool) {
    return value;
  }
  if (value is int) {
    return value >= 200 && value < 400;
  }
  if (value is String) {
    return value.toLowerCase() == 'true';
  }
  return statusCode == null || statusCode < 400;
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

String? _readString(Object? value) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return null;
}

Map<String, Object?> _readObjectMap(Object? value) {
  if (value is! Map<Object?, Object?>) {
    return const <String, Object?>{};
  }

  return value.map((key, entry) {
    return MapEntry(key.toString(), entry);
  });
}
