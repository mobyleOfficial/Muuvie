import 'dart:convert';
import 'dart:typed_data';

import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muuvie/di/auth_interceptor.dart';

class _FakeTokenStorage extends SecureTokenStorage {
  Map<String, dynamic>? stored;
  int clearCalls = 0;

  _FakeTokenStorage(AuthTokenModel? token) : stored = token?.toJson();

  @override
  Future<void> saveToken(Map<String, dynamic> tokenJson) async =>
      stored = tokenJson;

  @override
  Future<Map<String, dynamic>?> getToken() async => stored;

  @override
  Future<void> clearToken() async {
    clearCalls++;
    stored = null;
  }

  String? get accessToken => stored?['access_token'] as String?;
}

class _Adapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) respond;
  final List<RequestOptions> requests = [];
  // Captured at send time: a retry reuses (and mutates) the same RequestOptions.
  final List<Object?> sentAuthorization = [];

  _Adapter(this.respond);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    sentAuthorization.add(options.headers['Authorization']);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

AuthTokenModel _token(
  String access, {
  Duration expiresIn = const Duration(hours: 1),
}) => AuthTokenModel(
  accessToken: access,
  refreshToken: 'refresh-$access',
  expiresAt: DateTime.now().add(expiresIn),
);

void main() {
  late _FakeTokenStorage storage;
  late Dio dio;
  late Dio refreshDio;
  late _Adapter backend;
  late _Adapter refreshBackend;

  // Backend accepts only the renewed token.
  Future<ResponseBody> backendAcceptingNew(RequestOptions options) async =>
      options.headers['Authorization'] == 'Bearer new'
      ? _json(200, {'ok': true})
      : _json(401, {'error': 'invalid_token'});

  Future<ResponseBody> refreshGranting(RequestOptions options) async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return _json(200, {
      'accessToken': 'new',
      'tokenType': 'Bearer',
      'expiresIn': 3600,
      'refreshToken': 'refresh-new',
    });
  }

  void setUpClients({
    required AuthTokenModel? token,
    required Future<ResponseBody> Function(RequestOptions) backendResponse,
    required Future<ResponseBody> Function(RequestOptions) refreshResponse,
  }) {
    storage = _FakeTokenStorage(token);
    backend = _Adapter(backendResponse);
    refreshBackend = _Adapter(refreshResponse);
    dio = Dio(BaseOptions(baseUrl: 'http://backend/'))
      ..httpClientAdapter = backend;
    refreshDio = Dio(BaseOptions(baseUrl: 'http://backend/'))
      ..httpClientAdapter = refreshBackend;
    dio.interceptors.add(AuthInterceptor(storage, dio, refreshDio: refreshDio));
  }

  test('renews an expired access token before sending the request', () async {
    setUpClients(
      token: _token('old', expiresIn: const Duration(minutes: -1)),
      backendResponse: backendAcceptingNew,
      refreshResponse: refreshGranting,
    );

    final response = await dio.get<dynamic>('profile');

    expect(response.statusCode, 200);
    expect(refreshBackend.requests, hasLength(1));
    expect(refreshBackend.requests.single.data, {
      'refreshToken': 'refresh-old',
    });
    expect(backend.requests, hasLength(1));
    expect(storage.accessToken, 'new');
    expect(storage.stored?['refresh_token'], 'refresh-new');
  });

  test('on 401 renews the token and retries the request once', () async {
    setUpClients(
      token: _token('old'),
      backendResponse: backendAcceptingNew,
      refreshResponse: refreshGranting,
    );

    final response = await dio.get<dynamic>('profile');

    expect(response.statusCode, 200);
    expect(refreshBackend.requests, hasLength(1));
    expect(backend.sentAuthorization, ['Bearer old', 'Bearer new']);
  });

  test('concurrent 401s share a single refresh', () async {
    setUpClients(
      token: _token('old'),
      backendResponse: backendAcceptingNew,
      refreshResponse: refreshGranting,
    );

    final responses = await Future.wait([
      dio.get<dynamic>('a'),
      dio.get<dynamic>('b'),
      dio.get<dynamic>('c'),
    ]);

    expect(responses.map((r) => r.statusCode), [200, 200, 200]);
    expect(refreshBackend.requests, hasLength(1));
  });

  test('a rejected refresh token ends the session', () async {
    setUpClients(
      token: _token('old'),
      backendResponse: backendAcceptingNew,
      refreshResponse: (_) async =>
          _json(401, {'error': 'invalid_refresh_token'}),
    );

    await expectLater(
      dio.get<dynamic>('profile'),
      throwsA(
        isA<DioException>().having(
          (e) => e.response?.statusCode,
          'status',
          401,
        ),
      ),
    );
    expect(storage.clearCalls, 1);
    expect(storage.stored, isNull);
  });

  test('a refresh that fails without a response keeps the session', () async {
    setUpClients(
      token: _token('old'),
      backendResponse: backendAcceptingNew,
      refreshResponse: (options) async => throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      ),
    );

    await expectLater(
      dio.get<dynamic>('profile'),
      throwsA(isA<DioException>()),
    );
    expect(storage.clearCalls, 0);
    expect(storage.accessToken, 'old');
  });

  test('requests without a session are sent without Authorization', () async {
    setUpClients(
      token: null,
      backendResponse: (_) async => _json(200, {'ok': true}),
      refreshResponse: refreshGranting,
    );

    await dio.get<dynamic>('movies/trending');

    expect(backend.requests.single.headers.containsKey('Authorization'), false);
    expect(refreshBackend.requests, isEmpty);
  });
}
