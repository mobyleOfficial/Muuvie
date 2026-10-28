import 'package:core/core.dart';
import 'package:auth_data/models/auth_token_model.dart';

abstract interface class AuthLocalDataSource {
  Future<Result<AuthTokenModel?>> getToken();
  Future<Result<void>> saveToken(AuthTokenModel token);
  Future<Result<void>> clearToken();
  Stream<void> observeTokenCleared();
}
