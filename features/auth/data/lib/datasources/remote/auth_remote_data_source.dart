import 'package:core/core.dart';
import 'package:auth_data/models/login_response_model.dart';
import 'package:auth_data/models/social_credential_model.dart';

abstract interface class AuthRemoteDataSource {
  /// `POST /api/v1/auth/social`: exchanges the provider's ID token for a session.
  Future<Result<LoginResponseModel>> signInWithProvider(
    SocialCredentialModel credential,
  );

  /// `PUT /api/v1/auth/nickname` (needs the session).
  Future<Result<void>> chooseNickname(String nickname);
  Future<Result<bool>> checkNicknameAvailability(String nickname);

  /// Revokes the access token (sent by the interceptor) and, if given, the refresh token.
  Future<Result<void>> logout(String? refreshToken);
}
