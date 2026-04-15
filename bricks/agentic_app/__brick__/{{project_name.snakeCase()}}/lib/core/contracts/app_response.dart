final class AppResponse<T> {
  const AppResponse({
    required this.data,
    this.message,
    this.statusCode,
    this.metadata = const {},
  });

  final T data;
  final String? message;
  final int? statusCode;
  final Map<String, Object?> metadata;

  bool get isSuccess => statusCode == null || statusCode! < 400;
}
