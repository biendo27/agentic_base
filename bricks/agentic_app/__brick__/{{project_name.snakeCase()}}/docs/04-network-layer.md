# Network Layer

## Technology: Dio

`ApiClient` wraps Dio and is registered as a `@singleton` in the DI container.

## Setup

`ApiClient` is configured in `lib/core/network/api_client.dart`:
- Base URL from `FlavorConfig.instance.apiBaseUrl`
- Default timeout: 30 seconds (connect + receive)
- JSON content-type headers

## Interceptors

Three interceptors applied in order:

### 1. AuthInterceptor (`auth_interceptor.dart`)
- Injects `Authorization: Bearer <token>` header on every request
- Reads token from secure storage (inject `TokenStorage`)
- On 401 response: attempt token refresh, retry original request once
- On refresh failure: emit unauthenticated event, clear tokens

### 2. ErrorInterceptor (`error_interceptor.dart`)
- Converts `DioException` into typed `AppFailure` subclasses:
  - `NetworkFailure` — no connectivity
  - `ServerFailure` — 5xx responses
  - `UnauthorizedFailure` — 401
  - `NotFoundFailure` — 404
  - `ValidationFailure` — 422 with field errors

### 3. LoggingInterceptor (`logging_interceptor.dart`)
- Active only in debug builds (`kDebugMode`)
- Logs request method, URL, headers, body
- Logs response status and body
- Logs errors with stack traces

## Usage in Repositories

```dart
@Injectable(as: FeatureRepository)
class FeatureRepositoryImpl implements FeatureRepository {
  FeatureRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Either<AppFailure, FeatureEntity>> getData() async {
    try {
      final response = await _apiClient.dio.get('/feature/data');
      return Right(FeatureModel.fromJson(response.data).toEntity());
    } on AppFailure catch (failure) {
      return Left(failure);
    }
  }
}
```

## Error Handling Contract

All repository methods return `Either<AppFailure, T>` (using `dartz` or inline).
Never throw from a repository — always return `Left(failure)`.
Cubits call `.fold()` on the result to emit appropriate states.

## Environment URLs

| Flavor | URL Source |
|--------|-----------|
| dev | `env/dev.env.example` → `API_BASE_URL` |
| staging | `env/staging.env.example` → `API_BASE_URL` |
| prod | `env/prod.env.example` → `API_BASE_URL` |

Copy `.env.example` to `.env` locally. Never commit `.env` files.
