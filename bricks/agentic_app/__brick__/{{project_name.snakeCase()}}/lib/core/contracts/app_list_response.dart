import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_list_response.freezed.dart';

@freezed
abstract class AppListResponse<T> with _$AppListResponse<T> {
  const AppListResponse._();

  const factory AppListResponse({
    @Default(true) bool success,
    String? message,
    String? code,
    int? statusCode,
    required List<T> data,
    @Default(<String, Object?>{}) Map<String, Object?> metadata,
  }) = _AppListResponse<T>;

  factory AppListResponse.fromJson(
    Map<String, Object?> json,
    T Function(Object? json) fromJsonItem,
  ) {
    final statusCode = _readInt(json['status_code'] ?? json['statusCode']);
    final metadata = _readObjectMap(json['metadata']);
    final successValue = json['success'] ?? json['status'];

    return AppListResponse<T>(
      success: _readSuccess(successValue, statusCode),
      message: _readString(json['message']),
      code: _readString(json['code']),
      statusCode: statusCode,
      data: _readItemList(json['data'], fromJsonItem),
      metadata: metadata,
    );
  }
}

extension AppListResponseX<T> on AppListResponse<T> {
  bool get isSuccess => success && (statusCode == null || statusCode! < 400);
  bool get hasData => data.isNotEmpty;

  Map<String, Object?> toJson(Object? Function(T value) toJsonItem) {
    return <String, Object?>{
      'success': success,
      if (message != null) 'message': message,
      if (code != null) 'code': code,
      if (statusCode != null) 'status_code': statusCode,
      'data': data.map(toJsonItem).toList(growable: false),
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

List<T> _readItemList<T>(
  Object? value,
  T Function(Object? json) fromJsonItem,
) {
  if (value == null) {
    return <T>[];
  }
  if (value is! List<Object?>) {
    throw const FormatException('AppListResponse data must be a JSON list.');
  }

  return value.map(fromJsonItem).toList(growable: false);
}
