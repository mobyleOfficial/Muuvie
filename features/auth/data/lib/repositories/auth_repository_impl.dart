import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:auth_domain/models/oauth_provider.dart';
import 'package:auth_domain/repositories/auth_repository.dart';
import 'package:auth_data/datasources/oauth_remote_data_source.dart';
import 'package:auth_data/datasources/remote/auth_remote_data_source.dart';
import 'package:auth_data/datasources/auth_local_data_source.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final OAuthRemoteDataSource _oauthRemoteDataSource;
  final AuthRemoteDataSource _authRemoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(
    this._oauthRemoteDataSource,
    this._authRemoteDataSource,
    this._localDataSource,
  );

  @override
  Future<Result<void>> login(OAuthProvider provider) async {
    final providerString = provider == OAuthProvider.google
        ? 'google'
        : 'facebook';

    final oauthResult = await _oauthRemoteDataSource.initiateOAuth(
      providerString,
    );

    switch (oauthResult) {
      case Success(:final data):
        final tokenResult = await _oauthRemoteDataSource.completeOAuth(data);

        switch (tokenResult) {
          case Success(:final data):
            return _localDataSource.saveToken(data);
          case Failure(:final error):
            return Failure(error);
        }
      case Failure(:final error):
        return Failure(error);
    }
  }

  @override
  Future<Result<void>> loginWithEmail(String email, String password) async {
    final result = await _authRemoteDataSource.login(email, password);

    switch (result) {
      case Success(:final data):
        return _localDataSource.saveToken(data);
      case Failure(:final error):
        return Failure(error);
    }
  }

  @override
  Future<Result<void>> signUp(
    String email,
    String password,
    String nickname,
  ) async {
    final result = await _authRemoteDataSource.signUp(
      email,
      password,
      nickname,
    );

    switch (result) {
      case Success(:final data):
        return _localDataSource.saveToken(data);
      case Failure(:final error):
        return Failure(error);
    }
  }

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
      Failure(:final error) => Failure(error),
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
    return _localDataSource.clearToken();
  }

  @override
  Stream<void> observeSessionEnded() => _localDataSource.observeTokenCleared();
}
