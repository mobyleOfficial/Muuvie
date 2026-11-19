import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:auth/auth.dart';

class MockSocialSignInDataSource implements SocialSignInDataSource {
  Result<SocialCredentialModel?> signInResult = const Failure(AppError.unknown);
  OAuthProvider? lastProvider;
  bool signOutCalled = false;

  @override
  Future<Result<SocialCredentialModel?>> signIn(OAuthProvider provider) async {
    lastProvider = provider;
    return signInResult;
  }

  @override
  Future<void> signOut() async => signOutCalled = true;
}

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  Result<LoginResponseModel>? signInResult;
  Result<void>? chooseNicknameResult;
  Result<bool>? checkNicknameResult;
  SocialCredentialModel? lastCredential;
  String? lastNickname;

  @override
  Future<Result<LoginResponseModel>> signInWithProvider(
    SocialCredentialModel credential,
  ) async {
    lastCredential = credential;
    return signInResult ?? const Failure(AppError.unknown);
  }

  @override
  Future<Result<void>> chooseNickname(String nickname) async {
    lastNickname = nickname;
    return chooseNicknameResult ?? const Failure(AppError.unknown);
  }

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

LoginResponseModel _response({bool needsNickname = false}) =>
    LoginResponseModel(
      accessToken: 'jwt-token',
      tokenType: 'Bearer',
      expiresIn: 3600,
      refreshToken: 'refresh',
      profile: const LoginProfileModel(
        photoUrl: '',
        username: 'cosmic_ripley_42',
        bio: '',
      ),
      needsNickname: needsNickname,
    );

const _appleCredential = SocialCredentialModel(
  provider: 'apple',
  idToken: 'apple-id-token',
  nonce: 'raw-nonce',
  displayName: 'Ana Clara',
);

void main() {
  late AuthRepositoryImpl repository;
  late MockSocialSignInDataSource mockSocial;
  late MockAuthRemoteDataSource mockAuthRemote;
  late MockAuthLocalDataSource mockLocal;

  setUp(() {
    mockSocial = MockSocialSignInDataSource();
    mockAuthRemote = MockAuthRemoteDataSource();
    mockLocal = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(mockSocial, mockAuthRemote, mockLocal);
  });

  group('login', () {
    test('sends the provider token, saves the session and signs in', () async {
      mockSocial.signInResult = const Success(_appleCredential);
      mockAuthRemote.signInResult = Success(_response());
      mockLocal.saveTokenResult = const Success(null);

      final result = await repository.login(OAuthProvider.apple);

      final outcome = (result as Success<SignInOutcome>).data as SignedIn;
      expect(outcome.needsNickname, false);
      expect(mockSocial.lastProvider, OAuthProvider.apple);
      expect(mockAuthRemote.lastCredential?.idToken, 'apple-id-token');
      expect(mockAuthRemote.lastCredential?.nonce, 'raw-nonce');
      expect(mockLocal.lastSavedToken?.accessToken, 'jwt-token');
      expect(mockLocal.lastSavedToken?.refreshToken, 'refresh');
    });

    test(
      'a new account asks for a nickname, suggesting the provider name',
      () async {
        mockSocial.signInResult = const Success(_appleCredential);
        mockAuthRemote.signInResult = Success(_response(needsNickname: true));
        mockLocal.saveTokenResult = const Success(null);

        final result = await repository.login(OAuthProvider.apple);

        final outcome = (result as Success<SignInOutcome>).data as SignedIn;
        expect(outcome.needsNickname, true);
        expect(outcome.suggestedNickname, 'Ana Clara');
      },
    );

    test('a closed sheet is a cancellation, not an error', () async {
      mockSocial.signInResult = const Success(null);

      final result = await repository.login(OAuthProvider.google);

      expect((result as Success<SignInOutcome>).data, isA<SignInCancelled>());
      expect(mockAuthRemote.lastCredential, isNull);
      expect(mockLocal.lastSavedToken, isNull);
    });

    test('returns failure when the native sign-in fails', () async {
      mockSocial.signInResult = const Failure(AppError.unknown);

      final result = await repository.login(OAuthProvider.google);

      expect((result as Failure<SignInOutcome>).error, AppError.unknown);
    });

    test('returns failure when the server rejects the token', () async {
      mockSocial.signInResult = const Success(_appleCredential);
      mockAuthRemote.signInResult = const Failure(
        AppError.unauthorized,
        code: 'invalid_token',
      );

      final result = await repository.login(OAuthProvider.apple);

      final failure = result as Failure<SignInOutcome>;
      expect(failure.error, AppError.unauthorized);
      expect(failure.code, 'invalid_token');
      expect(mockLocal.lastSavedToken, isNull);
    });

    test('returns failure when the session cannot be saved', () async {
      mockSocial.signInResult = const Success(_appleCredential);
      mockAuthRemote.signInResult = Success(_response());
      mockLocal.saveTokenResult = const Failure(AppError.unknown);

      final result = await repository.login(OAuthProvider.apple);

      expect(result, isA<Failure<SignInOutcome>>());
    });
  });

  group('chooseNickname', () {
    test('sends the nickname to the server', () async {
      mockAuthRemote.chooseNicknameResult = const Success(null);

      final result = await repository.chooseNickname('Ana');

      expect(result, isA<Success<void>>());
      expect(mockAuthRemote.lastNickname, 'Ana');
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
      expect(mockSocial.signOutCalled, true);
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
