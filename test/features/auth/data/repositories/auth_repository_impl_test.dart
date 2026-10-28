import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:auth/auth.dart';

class MockOAuthRemoteDataSource implements OAuthRemoteDataSource {
  Result<OAuthResultModel>? initiateOAuthResult;
  Result<AuthTokenModel>? completeOAuthResult;

  @override
  Future<Result<OAuthResultModel>> initiateOAuth(String provider) async =>
      initiateOAuthResult ?? const Failure(AppError.unknown);

  @override
  Future<Result<AuthTokenModel>> completeOAuth(
    OAuthResultModel oauthResult,
  ) async => completeOAuthResult ?? const Failure(AppError.unknown);
}

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  Result<AuthTokenModel>? loginResult;
  Result<AuthTokenModel>? signUpResult;
  Result<bool>? checkNicknameResult;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<Result<AuthTokenModel>> login(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
    return loginResult ?? const Failure(AppError.unknown);
  }

  @override
  Future<Result<AuthTokenModel>> signUp(
    String email,
    String password,
    String nickname,
  ) async => signUpResult ?? const Failure(AppError.unknown);

  @override
  Future<Result<bool>> checkNicknameAvailability(String nickname) async =>
      checkNicknameResult ?? const Failure(AppError.unknown);

  Result<void>? logoutResult;
  String? lastLogoutRefreshToken;

  @override
  Future<Result<void>> logout(String? refreshToken) async {
    lastLogoutRefreshToken = refreshToken;
    return logoutResult ?? const Success(null);
  }
}

class MockAuthLocalDataSource implements AuthLocalDataSource {
  Result<AuthTokenModel?>? getTokenResult;
  Result<void>? saveTokenResult;
  Result<void>? clearTokenResult;
  AuthTokenModel? lastSavedToken;

  @override
  Future<Result<AuthTokenModel?>> getToken() async =>
      getTokenResult ?? const Failure(AppError.unknown);

  @override
  Future<Result<void>> saveToken(AuthTokenModel token) async {
    lastSavedToken = token;
    return saveTokenResult ?? const Failure(AppError.unknown);
  }

  bool clearTokenCalled = false;

  @override
  Future<Result<void>> clearToken() async {
    clearTokenCalled = true;
    return clearTokenResult ?? const Failure(AppError.unknown);
  }

  @override
  Stream<void> observeTokenCleared() => const Stream.empty();
}

void main() {
  late AuthRepositoryImpl repository;
  late MockOAuthRemoteDataSource mockOAuthRemote;
  late MockAuthRemoteDataSource mockAuthRemote;
  late MockAuthLocalDataSource mockLocal;

  setUp(() {
    mockOAuthRemote = MockOAuthRemoteDataSource();
    mockAuthRemote = MockAuthRemoteDataSource();
    mockLocal = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(mockOAuthRemote, mockAuthRemote, mockLocal);
  });

  group('login (OAuth)', () {
    test('initiates OAuth, completes it, and saves the token', () async {
      mockOAuthRemote.initiateOAuthResult = const Success(
        OAuthResultModel(provider: 'google', providerToken: 'mock-token'),
      );
      mockOAuthRemote.completeOAuthResult = Success(
        AuthTokenModel(
          accessToken: 'jwt-token',
          expiresAt: DateTime(2026, 6, 19),
        ),
      );
      mockLocal.saveTokenResult = const Success(null);

      final result = await repository.login(OAuthProvider.google);

      expect(result, isA<Success<void>>());
      expect(mockLocal.lastSavedToken?.accessToken, 'jwt-token');
    });

    test('returns failure when OAuth initiation fails', () async {
      mockOAuthRemote.initiateOAuthResult = const Failure(AppError.network);

      final result = await repository.login(OAuthProvider.google);

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, AppError.network);
    });

    test('returns failure when OAuth completion fails', () async {
      mockOAuthRemote.initiateOAuthResult = const Success(
        OAuthResultModel(provider: 'google', providerToken: 'mock-token'),
      );
      mockOAuthRemote.completeOAuthResult = const Failure(AppError.server);

      final result = await repository.login(OAuthProvider.google);

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, AppError.server);
    });

    test('returns failure when token save fails', () async {
      mockOAuthRemote.initiateOAuthResult = const Success(
        OAuthResultModel(provider: 'facebook', providerToken: 'mock-token'),
      );
      mockOAuthRemote.completeOAuthResult = Success(
        AuthTokenModel(
          accessToken: 'jwt-token',
          expiresAt: DateTime(2026, 6, 19),
        ),
      );
      mockLocal.saveTokenResult = const Failure(AppError.unknown);

      final result = await repository.login(OAuthProvider.facebook);

      expect(result, isA<Failure<void>>());
    });
  });

  group('loginWithEmail', () {
    test('calls remote data source and saves token on success', () async {
      mockAuthRemote.loginResult = Success(
        AuthTokenModel(
          accessToken: 'email-jwt-token',
          expiresAt: DateTime(2026, 8, 1),
        ),
      );
      mockLocal.saveTokenResult = const Success(null);

      final result = await repository.loginWithEmail(
        'test@example.com',
        'password123',
      );

      expect(result, isA<Success<void>>());
      expect(mockAuthRemote.lastEmail, 'test@example.com');
      expect(mockAuthRemote.lastPassword, 'password123');
      expect(mockLocal.lastSavedToken?.accessToken, 'email-jwt-token');
    });

    test('returns failure when remote login fails', () async {
      mockAuthRemote.loginResult = const Failure(AppError.unauthorized);

      final result = await repository.loginWithEmail(
        'test@example.com',
        'wrong',
      );

      expect(result, isA<Failure<void>>());
      expect((result as Failure<void>).error, AppError.unauthorized);
    });

    test('returns failure when token save fails', () async {
      mockAuthRemote.loginResult = Success(
        AuthTokenModel(accessToken: 'token', expiresAt: DateTime(2026, 8, 1)),
      );
      mockLocal.saveTokenResult = const Failure(AppError.unknown);

      final result = await repository.loginWithEmail(
        'test@example.com',
        'password123',
      );

      expect(result, isA<Failure<void>>());
    });
  });

  group('isUserAuthenticated', () {
    test('returns true when valid token exists', () async {
      mockLocal.getTokenResult = Success(
        AuthTokenModel(
          accessToken: 'valid-token',
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        ),
      );

      final result = await repository.isUserAuthenticated();

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, true);
    });

    test('returns false when no token exists', () async {
      mockLocal.getTokenResult = const Success(null);

      final result = await repository.isUserAuthenticated();

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, false);
    });

    test('returns false when token is expired', () async {
      mockLocal.getTokenResult = Success(
        AuthTokenModel(
          accessToken: 'expired-token',
          expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      );

      final result = await repository.isUserAuthenticated();

      expect(result, isA<Success<bool>>());
      expect((result as Success<bool>).data, false);
    });

    test(
      'returns true when access token expired but a refresh token exists',
      () async {
        mockLocal.getTokenResult = Success(
          AuthTokenModel(
            accessToken: 'expired-token',
            refreshToken: 'refresh',
            expiresAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        );

        final result = await repository.isUserAuthenticated();

        expect((result as Success<bool>).data, true);
      },
    );
  });

  group('logout', () {
    test('sends the refresh token and clears the local session', () async {
      mockLocal.getTokenResult = Success(
        AuthTokenModel(
          accessToken: 'token',
          refreshToken: 'refresh',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        ),
      );
      mockLocal.clearTokenResult = const Success(null);

      final result = await repository.logout();

      expect(result, isA<Success<void>>());
      expect(mockAuthRemote.lastLogoutRefreshToken, 'refresh');
      expect(mockLocal.clearTokenCalled, true);
    });

    test('clears the local session even when the server call fails', () async {
      mockLocal.getTokenResult = const Success(null);
      mockLocal.clearTokenResult = const Success(null);
      mockAuthRemote.logoutResult = const Failure(AppError.unknown);

      final result = await repository.logout();

      expect(result, isA<Success<void>>());
      expect(mockLocal.clearTokenCalled, true);
    });
  });
}
