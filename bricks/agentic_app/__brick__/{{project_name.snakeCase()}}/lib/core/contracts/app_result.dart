import 'package:fpdart/fpdart.dart';
import 'package:{{project_name.snakeCase()}}/core/error/failures.dart';

typedef AppResult<T> = Either<AppFailure, T>;
typedef AppTaskResult<T> = TaskEither<AppFailure, T>;

AppResult<T> success<T>(T value) => Right(value);
AppResult<T> failure<T>(AppFailure error) => Left(error);
