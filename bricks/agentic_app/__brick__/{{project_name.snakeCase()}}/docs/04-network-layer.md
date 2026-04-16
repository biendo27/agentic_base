# Network Layer

## Technology: Dio

The scaffold ships a configured Dio seam in
`lib/core/network/api_client.dart`.
The day-0 starter flow still uses in-memory demo repositories, so this layer is
present as the default remote-data contract rather than an actively consumed
starter dependency.
{{#uses_get_it}}Generated apps register the Dio instance through `NetworkModule` + injectable/GetIt.{{/uses_get_it}}
{{#is_riverpod}}Riverpod projects keep the same Dio seam available in `lib/core/network/api_client.dart`, but the starter does not create a provider for it until a real API-backed repository needs one.{{/is_riverpod}}

Shared boundary contracts live in:
- `lib/core/contracts/app_result.dart`
- `lib/core/contracts/app_response.dart`
- `lib/core/contracts/app_list_response.dart`
- `lib/core/contracts/pagination.dart`
- `lib/core/contracts/localized_text.dart`

`AppFailure`, the response/pagination contracts, and `LocalizedText` keep the
shared model layer inspectable and runtime-agnostic:

- invariants live on the contract class
- explicit-input helpers stay on the contract when they do not reach into app state
- locale- or DI-aware convenience must stay outside raw contracts

## Setup

`lib/core/network/api_client.dart` defines `NetworkModule`, which constructs a
configured `Dio` instance with:
- Base URL from `FlavorConfig.instance.apiBaseUrl`
- Default timeout: 30 seconds (connect + receive)
- JSON content-type headers
- Default interceptor stack:
  - `LoggingInterceptor()`
  - `ErrorInterceptor()`
- `AuthInterceptor` ships as an extension seam, but the starter does not wire it by default

## Default Interceptors

Two interceptors are applied by default:

### 1. LoggingInterceptor (`logging_interceptor.dart`)
- Active only in debug builds (`kDebugMode`)
- Logs request method + path, response status + path, and failed status + path
- Keeps the starter scaffold inspectable without dumping full payload bodies by default

### 2. ErrorInterceptor (`error_interceptor.dart`)
- Logs failed requests and attaches typed `AppFailure` payloads to the
  propagated `DioException` so repositories can normalize transport errors
  through `ErrorHandler.handle(...)`:
  - `NetworkFailure` — no connectivity
  - `ServerFailure` — 5xx responses
  - `UnauthorizedFailure` — 401
  - `NotFoundFailure` — 404
  - `ValidationFailure` — 422 with field errors

## Optional Auth Seam

`auth_interceptor.dart` is scaffolded as the future hook for bearer-token
attachment or token-refresh behavior, but it is intentionally left unwired in
the default starter. Add it only when the project has a real auth/storage
contract to inject.

## Usage in Repositories

When you replace the demo starter repository with a real remote repository,
inject `Dio` directly and normalize failures through `ErrorHandler`:

```dart
@injectable
class FeatureRepositoryImpl implements FeatureRepository {
  FeatureRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<AppResult<FeatureEntity>> getData() async {
    try {
      final response = await _dio.get('/feature/data');
      return success(FeatureModel.fromJson(response.data).toEntity());
    } on Object catch (error) {
      return failure(ErrorHandler.handle(error));
    }
  }
}
```

## Error Handling Contract

All repository methods return `Either<AppFailure, T>` via `fpdart`.
Never throw from a repository — always return `Left(failure)`.
Transport failures are normalized by `ErrorHandler`, with
`ErrorInterceptor` pre-populating typed failure payloads for HTTP-layer
errors.
The presentation runtime maps repository/use case results into state transitions.

`AppResponse<T>` is the transport envelope shape for single payload responses.
`AppListResponse<T>` does the same for list payloads. `AppResult<T>` remains
the repository/use-case boundary returned to the rest of the app.

## Environment URLs

| Flavor | URL Source |
| --- | --- |
| dev | `env/dev.env.example` → `API_BASE_URL` |
| staging | `env/staging.env.example` → `API_BASE_URL` |
| prod | `env/prod.env.example` → `API_BASE_URL` |

The default scripts pass these flavor-specific example files directly via
`--dart-define-from-file`. Keep sensitive values in local overrides or CI
environment settings, not in committed example files.
