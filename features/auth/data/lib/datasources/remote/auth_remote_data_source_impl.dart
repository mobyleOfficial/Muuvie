import 'package:core/core.dart';
import 'package:auth_data/datasources/remote/auth_remote_data_source.dart';
import 'package:auth_data/models/login_response_model.dart';
import 'package:auth_data/models/nickname_availability_model.dart';
import 'package:auth_data/models/social_credential_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final HttpClient _httpClient;

  AuthRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Result<LoginResponseModel>> signInWithProvider(
    SocialCredentialModel credential,
  ) async {
    final result = await _httpClient.post<Map<String, dynamic>>(
      '/api/v1/auth/social',
      body: credential.toJson(),
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) => Success(
        LoginResponseModel.fromJson(data),
      ),
      Failure<Map<String, dynamic>>(:final error, :final code) => Failure(
        error,
        code: code,
      ),
    };
  }

  @override
  Future<Result<void>> chooseNickname(String nickname) async {
    final result = await _httpClient.put<dynamic>(
      '/api/v1/auth/nickname',
      body: {'nickname': nickname},
    );

    return switch (result) {
      Success() => const Success(null),
      Failure(:final error, :final code) => Failure(error, code: code),
    };
  }

  @override
  Future<Result<bool>> checkNicknameAvailability(String nickname) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '/api/v1/auth/check-nickname',
      queryParams: {'nickname': nickname},
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) => Success(
        NicknameAvailabilityModel.fromJson(data).available,
      ),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> deleteAccount({
    String? appleAuthorizationCode,
    bool skipAppleRevocation = false,
  }) async {
    final result = await _httpClient.delete<dynamic>(
      '/api/v1/users/me',
      body: {
        'appleAuthorizationCode': ?appleAuthorizationCode,
        'skipAppleRevocation': skipAppleRevocation,
      },
    );

    return switch (result) {
      Success() => const Success(null),
      Failure(:final error, :final code) => Failure(error, code: code),
    };
  }

  @override
  Future<Result<void>> logout(String? refreshToken) async {
    final result = await _httpClient.post<dynamic>(
      '/api/v1/auth/logout',
      body: refreshToken == null ? null : {'refreshToken': refreshToken},
    );

    return switch (result) {
      Success() => const Success(null),
      Failure(:final error, :final code) => Failure(error, code: code),
    };
  }
}
