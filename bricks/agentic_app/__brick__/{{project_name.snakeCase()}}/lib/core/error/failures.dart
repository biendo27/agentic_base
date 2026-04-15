sealed class AppFailure {
  const AppFailure({
    required this.message,
    this.statusCode,
    this.code,
  });

  final String message;
  final int? statusCode;
  final String? code;
}

typedef Failure = AppFailure;

class ServerFailure extends AppFailure {
  const ServerFailure({
    required super.message,
    super.statusCode,
    super.code = 'server_error',
  });
}

class CacheFailure extends AppFailure {
  const CacheFailure({
    required super.message,
    super.code = 'cache_error',
  });
}

class NetworkFailure extends AppFailure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.code = 'network_error',
  });
}

class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({
    super.message = 'Authentication is required',
    super.statusCode = 401,
    super.code = 'unauthorized',
  });
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found',
    super.statusCode = 404,
    super.code = 'not_found',
  });
}

class ValidationFailure extends AppFailure {
  const ValidationFailure({
    required this.fieldErrors,
    super.message = 'Validation failed',
    super.statusCode = 422,
    super.code = 'validation_error',
  });

  final Map<String, List<String>> fieldErrors;
}

class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred',
    super.code = 'unexpected_error',
  });
}
