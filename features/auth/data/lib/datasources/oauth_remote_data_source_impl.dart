import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:auth_data/datasources/oauth_remote_data_source.dart';
import 'package:auth_data/models/auth_token_model.dart';
import 'package:auth_data/models/oauth_result_model.dart';

@injectable
class OAuthRemoteDataSourceImpl implements OAuthRemoteDataSource {
  OAuthRemoteDataSourceImpl();

  @override
  Future<Result<OAuthResultModel>> initiateOAuth(String provider) async {
    // Mock: simulate OAuth SDK returning a provider token
    await Future<void>.delayed(const Duration(milliseconds: 500));

    try {
      final mockToken = provider == 'google'
          ? 'mock-google-identity-token-${DateTime.now().millisecondsSinceEpoch}'
          : 'mock-facebook-access-token-${DateTime.now().millisecondsSinceEpoch}';

      return Success(
        OAuthResultModel(provider: provider, providerToken: mockToken),
      );
    } catch (exception) {
      return const Failure(AppError.unknown);
    }
  }

  @override
  Future<Result<AuthTokenModel>> completeOAuth(
    OAuthResultModel oauthResult,
  ) async {
    // Mock: simulate sending provider token to backend and receiving JWT
    await Future<void>.delayed(const Duration(milliseconds: 500));

    try {
      return Success(
        AuthTokenModel(
          accessToken:
              'mock-jwt-session-token-${DateTime.now().millisecondsSinceEpoch}',
          refreshToken: null,
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        ),
      );
    } catch (exception) {
      return const Failure(AppError.unknown);
    }
  }
}
