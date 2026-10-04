import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:muuvie/config/app_config.dart';

class AuthInterceptor extends Interceptor {
  final SecureTokenStorage _tokenStorage;
  final Dio _dio;
  bool _isRefreshing = false;

  AuthInterceptor(this._tokenStorage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokenJson = await _tokenStorage.getToken();
    if (tokenJson != null) {
      final token = AuthTokenModel.fromJson(tokenJson);
      if (token.expiresAt.isAfter(DateTime.now())) {
        options.headers['Authorization'] = 'Bearer ${token.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      final tokenJson = await _tokenStorage.getToken();
      if (tokenJson == null) return handler.next(err);

      final token = AuthTokenModel.fromJson(tokenJson);
      final refreshToken = token.refreshToken;
      if (refreshToken == null) return handler.next(err);

      _isRefreshing = true;
      try {
        // Use a clean Dio (no interceptors) to avoid infinite loops
        final refreshDio = Dio(
          BaseOptions(baseUrl: '${AppConfig.instance.backendUrl}/'),
        );
        final response = await refreshDio.post<Map<String, dynamic>>(
          'auth/refresh',
          data: {'refreshToken': refreshToken},
        );

        final data = response.data!;
        final newToken = AuthTokenModel(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String?,
          expiresAt: DateTime.now().add(
            Duration(seconds: data['expiresIn'] as int),
          ),
        );
        await _tokenStorage.saveToken(newToken.toJson());

        // Retry the original request with the new access token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${newToken.accessToken}';
        final retryResponse = await _dio.fetch(opts);
        return handler.resolve(retryResponse);
      } catch (_) {
        await _tokenStorage.clearToken();
        return handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    }
    handler.next(err);
  }
}
