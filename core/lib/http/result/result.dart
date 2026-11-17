import 'package:core/http/errors/http_error.dart';

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final AppError error;

  /// The `error` key of the server's error envelope (e.g. `ambiguous_file`),
  /// when the server sent one. It tells apart failures that share a status.
  final String? code;

  const Failure(this.error, {this.code});
}
