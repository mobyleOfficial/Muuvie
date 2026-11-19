import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:auth_domain/models/oauth_provider.dart';
import 'package:auth_domain/models/sign_in_outcome.dart';
import 'package:auth_domain/repositories/auth_repository.dart';
import 'package:auth_data/datasources/social_sign_in_data_source.dart';
import 'package:auth_data/datasources/remote/auth_remote_data_source.dart';
import 'package:auth_data/datasources/auth_local_data_source.dart';
import 'package:auth_data/models/social_credential_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final SocialSignInDataSource _socialSignInDataSource;
  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(
    this._socialSignInDataSource,
    this._authRemoteDataSource,
    this._localDataSource,
  );

  @override
  Future<Result<SignInOutcome>> login(OAuthProvider provider) async {
    final SocialCredentialModel? credential;
    switch (await _socialSignInDataSource.signIn(provider)) {
      case Success(:final data):
        credential = data;
      case Failure(:final error, :final code):
        return Failure(error, code: code);
    }
    if (credential == null) return const Success(SignInCancelled());

    final response = await _authRemoteDataSource.signInWithProvider(
      credential,
    );
    switch (response) {
      case Failure(:final error, :final code):
        return Failure(error, code: code);
      case Success(:final data):
        final saved = await _localDataSource.saveToken(data.toAuthTokenModel());
        if (saved case Failure(:final error, :final code)) {
          return Failure(error, code: code);
        }
        return Success(
          SignedIn(
            needsNickname: data.needsNickname,
            suggestedNickname: credential.displayName,
          ),
        );
    }
  }

  @override
  Future<Result<void>> chooseNickname(String nickname) =>
      _authRemoteDataSource.chooseNickname(nickname);

  @override
  Future<Result<bool>> checkNicknameAvailability(String nickname) =>
      _authRemoteDataSource.checkNicknameAvailability(nickname);

  @override
  Future<Result<bool>> isUserAuthenticated() async {
    final result = await _localDataSource.getToken();

    // An expired access token still counts while there is a refresh token:
    // the interceptor renews it, and clears it if the refresh is rejected.
    return switch (result) {
      Success(:final data) => Success(
        data != null &&
            (data.expiresAt.isAfter(DateTime.now()) ||
                data.refreshToken != null),
      ),
      Failure(:final error, :final code) => Failure(error, code: code),
    };
  }

  @override
  Future<Result<void>> logout() async {
    final tokenResult = await _localDataSource.getToken();
    final refreshToken = switch (tokenResult) {
      Success(:final data) => data?.refreshToken,
      Failure() => null,
    };

    // Best effort on the server: the local session ends even when offline.
    await _authRemoteDataSource.logout(refreshToken);
    await _socialSignInDataSource.signOut();
    return _localDataSource.clearToken();
  }

  @override
  Stream<void> observeSessionEnded() => _localDataSource.observeTokenCleared();
}
