import 'package:core/core.dart';

class FakeCall {
  final String method;
  final String path;
  final Map<String, dynamic>? query;
  final Object? body;

  const FakeCall(this.method, this.path, this.query, this.body);
}

/// Records every request and answers with [response], or with the answer of
/// [responses] for the request path when there is one.
class FakeHttpClient implements HttpClient {
  final calls = <FakeCall>[];
  Result<dynamic> response = const Success(null);
  final responses = <String, Result<dynamic>>{};

  Future<Result<T>> _record<T>(
    String method,
    String path,
    Map<String, dynamic>? query,
    Object? body,
  ) async {
    calls.add(FakeCall(method, path, query, body));
    return switch (responses[path] ?? response) {
      Success(:final data) => Success(data as T),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<T>> get<T>(String path, {Map<String, dynamic>? queryParams}) =>
      _record('GET', path, queryParams, null);

  @override
  Future<Result<T>> post<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  }) => _record('POST', path, queryParams, body);

  @override
  Future<Result<T>> put<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  }) => _record('PUT', path, queryParams, body);

  @override
  Future<Result<T>> patch<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  }) => _record('PATCH', path, queryParams, body);

  @override
  Future<Result<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParams,
  }) => _record('DELETE', path, queryParams, null);
}
