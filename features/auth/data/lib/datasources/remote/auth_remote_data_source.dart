import 'package:core/core.dart';
import 'package:auth_data/models/auth_token_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<Result<AuthTokenModel>> login(String email, String password);
  Future<Result<AuthTokenModel>> signUp(
    String email,
    String password,
    String nickname,
  );
  Future<Result<bool>> checkNicknameAvailability(String nickname);

  /// Revokes the access token (sent by the interceptor) and, if given, the refresh token.
  Future<Result<void>> logout(String? refreshToken);
}
