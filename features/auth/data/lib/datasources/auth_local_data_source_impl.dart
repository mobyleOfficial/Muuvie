import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:auth_data/datasources/auth_local_data_source.dart';
import 'package:auth_data/datasources/secure_token_storage.dart';
import 'package:auth_data/models/auth_token_model.dart';

@injectable
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureTokenStorage _secureStorage;

  AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<Result<AuthTokenModel?>> getToken() async {
    try {
      final tokenJson = await _secureStorage.getToken();
      if (tokenJson == null) {
        return const Success(null);
      }
      return Success(AuthTokenModel.fromJson(tokenJson));
    } catch (exception) {
      return const Failure(AppError.unknown);
    }
  }

  @override
  Future<Result<void>> saveToken(AuthTokenModel token) async {
    try {
      await _secureStorage.saveToken(token.toJson());
      return const Success(null);
    } catch (exception) {
      return const Failure(AppError.unknown);
    }
  }

  @override
  Future<Result<void>> clearToken() async {
    try {
      await _secureStorage.clearToken();
      return const Success(null);
    } catch (exception) {
      return const Failure(AppError.unknown);
    }
  }

  @override
  Stream<void> observeTokenCleared() => _secureStorage.onCleared;
}
