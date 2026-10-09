import 'package:core/http/result/result.dart';

abstract interface class HttpClient {
  Future<Result<T>> get<T>(String path, {Map<String, dynamic>? queryParams});

  Future<Result<T>> post<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  });

  Future<Result<T>> put<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  });

  Future<Result<T>> patch<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  });

  Future<Result<T>> delete<T>(String path, {Map<String, dynamic>? queryParams});
}
