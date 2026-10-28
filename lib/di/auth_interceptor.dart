import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:muuvie/config/app_config.dart';

/// Adds the access token to backend requests and renews it with the refresh token.
///
/// It is a [QueuedInterceptor]: while one refresh is running, other requests wait
/// for it instead of starting their own (the backend rotates refresh tokens, so a
/// second refresh with the old one would be treated as reuse and end the session).
class AuthInterceptor extends QueuedInterceptor {
  static const _retriedKey = 'auth_retried';

  // Renew a little before the real expiry so the request doesn't race the clock.
  static const _expirySkew = Duration(seconds: 30);

  final SecureTokenStorage _tokenStorage;
  final Dio _dio;
  final Dio _refreshDio;

  AuthInterceptor(this._tokenStorage, this._dio, {Dio? refreshDio})
    // A clean Dio (no interceptors) so the refresh call can't loop back here.
    : _refreshDio =
          refreshDio ??
          Dio(BaseOptions(baseUrl: '${AppConfig.instance.backendUrl}/'));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    var token = await _readToken();
    if (token != null && _isExpired(token) && token.refreshToken != null) {
      token = await _refresh(token);
    }
    if (token != null && !_isExpired(token)) {
      options.headers['Authorization'] = _bearer(token);
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 || request.extra[_retriedKey] == true) {
      return handler.next(err);
    }

    var token = await _readToken();
    if (token == null) return handler.next(err);

    if (request.headers['Authorization'] == _bearer(token)) {
      // The current access token was rejected: renew it.
      if (token.refreshToken == null) {
        await _tokenStorage.clearToken();
        return handler.next(err);
      }
      token = await _refresh(token);
      if (token == null) return handler.next(err);
    } else if (_isExpired(token)) {
      // Sent with an older token, but there's no valid one to retry with.
      return handler.next(err);
    }
    // Otherwise another request already renewed it: just retry with the stored token.

    request.headers['Authorization'] = _bearer(token);
    request.extra[_retriedKey] = true;
    try {
      handler.resolve(await _dio.fetch(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<AuthTokenModel?> _refresh(AuthTokenModel token) async {
    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        'api/v1/auth/refresh',
        data: {'refreshToken': token.refreshToken},
      );
      final data = response.data!;
      final renewed = AuthTokenModel(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String? ?? token.refreshToken,
        expiresAt: DateTime.now().add(
          Duration(seconds: (data['expiresIn'] as num).toInt()),
        ),
      );
      await _tokenStorage.saveToken(renewed.toJson());
      return renewed;
    } on DioException catch (error) {
      // Only the server rejecting the refresh token ends the session; being
      // offline keeps it so the next request can try again.
      final status = error.response?.statusCode;
      if (status == 400 || status == 401) await _tokenStorage.clearToken();
      return null;
    }
  }

  Future<AuthTokenModel?> _readToken() async {
    final tokenJson = await _tokenStorage.getToken();
    return tokenJson == null ? null : AuthTokenModel.fromJson(tokenJson);
  }

  bool _isExpired(AuthTokenModel token) =>
      !token.expiresAt.subtract(_expirySkew).isAfter(DateTime.now());

  String _bearer(AuthTokenModel token) => 'Bearer ${token.accessToken}';
}
