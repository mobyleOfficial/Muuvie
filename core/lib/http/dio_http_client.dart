import 'package:dio/dio.dart';

import 'package:core/http/errors/http_error.dart';
import 'package:core/http/http_client.dart';
import 'package:core/http/result/result.dart';

class DioHttpClient implements HttpClient {
  final Dio _dio;

  DioHttpClient(this._dio);

  @override
  Future<Result<T>> get<T>(String path, {Map<String, dynamic>? queryParams}) =>
      _request(() => _dio.get(path, queryParameters: queryParams));

  @override
  Future<Result<T>> post<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  }) =>
      _request(() => _dio.post(path, queryParameters: queryParams, data: body));

  @override
  Future<Result<T>> put<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  }) =>
      _request(() => _dio.put(path, queryParameters: queryParams, data: body));

  @override
  Future<Result<T>> patch<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  }) => _request(
    () => _dio.patch(path, queryParameters: queryParams, data: body),
  );

  @override
  Future<Result<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParams,
  }) => _request(() => _dio.delete(path, queryParameters: queryParams));

  Future<Result<T>> _request<T>(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      final response = await call();
      return Success(response.data as T);
    } on DioException catch (e) {
      return Failure(_mapDioError(e));
    } catch (_) {
      return const Failure(AppError.unknown);
    }
  }

  AppError _mapDioError(DioException e) => switch (e.type) {
    DioExceptionType.connectionError => AppError.network,
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout => AppError.timeout,
    DioExceptionType.badResponse => _mapStatusCode(e.response?.statusCode),
    _ => AppError.unknown,
  };

  AppError _mapStatusCode(int? statusCode) => switch (statusCode) {
    400 => AppError.badRequest,
    401 => AppError.unauthorized,
    404 => AppError.notFound,
    409 => AppError.conflict,
    _ when statusCode != null && statusCode >= 500 => AppError.server,
    _ => AppError.unknown,
  };
}
