import 'package:auth/auth.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:muuvie/config/app_config.dart';
import 'package:muuvie/di/auth_interceptor.dart';

@module
abstract class HttpDiModule {
  @singleton
  @Named('tmdb')
  Dio get tmdbDio {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.themoviedb.org/3/',
        headers: {
          'Authorization':
              'Bearer ${const String.fromEnvironment('TMDB_API_KEY')}',
          'accept': 'application/json',
        },
      ),
    );
    if (AppConfig.instance.flavor == AppFlavor.dev) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }
    return dio;
  }

  @singleton
  @Named('backend')
  Dio backendDio(SecureTokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: '${AppConfig.instance.backendUrl}/',
        headers: {
          'accept': 'application/json',
        },
      ),
    )..interceptors.add(AuthInterceptor(tokenStorage));
    if (AppConfig.instance.flavor == AppFlavor.dev) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }
    return dio;
  }

  @singleton
  @Named('tmdb')
  HttpClient tmdbClient(@Named('tmdb') Dio dio) => DioHttpClient(dio);

  @singleton
  @Named('backend')
  HttpClient backendClient(@Named('backend') Dio dio) => DioHttpClient(dio);

  @singleton
  LocalClient get localClient => ObjectBoxClient();

  @singleton
  WebSocketClient webSocketClient(@Named('backend') Dio dio) =>
      WebSocketClient(
        baseUrl: AppConfig.instance.backendUrl,
        dio: dio,
      );
}
