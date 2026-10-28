import 'package:core/core.dart';
import 'package:auth_data/datasources/remote/auth_remote_data_source.dart';
import 'package:auth_data/models/auth_token_model.dart';
import 'package:auth_data/models/login_response_model.dart';
import 'package:auth_data/models/nickname_availability_model.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final HttpClient _httpClient;

  AuthRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Result<AuthTokenModel>> login(String email, String password) async {
    final result = await _httpClient.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      body: {'email': email, 'password': password},
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) => Success(
        LoginResponseModel.fromJson(data).toAuthTokenModel(),
      ),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<AuthTokenModel>> signUp(
    String email,
    String password,
    String nickname,
  ) async {
    final result = await _httpClient.post<Map<String, dynamic>>(
      '/api/v1/auth/signup',
      body: {'email': email, 'password': password, 'nickname': nickname},
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) => Success(
        LoginResponseModel.fromJson(data).toAuthTokenModel(),
      ),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
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
  Future<Result<void>> logout(String? refreshToken) async {
    final result = await _httpClient.post<dynamic>(
      '/api/v1/auth/logout',
      body: refreshToken == null ? null : {'refreshToken': refreshToken},
    );

    return switch (result) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }
}
