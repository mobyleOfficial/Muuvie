import 'package:core/core.dart';
import 'package:auth_domain/models/oauth_provider.dart';
import 'package:auth_data/models/social_credential_model.dart';

abstract interface class SocialSignInDataSource {
  /// Opens the native sheet of [provider]. `Success(null)` when the user
  /// closed it without signing in.
  Future<Result<SocialCredentialModel?>> signIn(OAuthProvider provider);

  /// Forgets the provider account picked on this device, so the next sign-in
  /// asks which account to use. Best effort.
  Future<void> signOut();

  /// Whether Sign in with Apple can run on this device (iOS and macOS).
  Future<bool> isAppleAvailable();

  /// Asks Apple again for a fresh authorization code, so the server can revoke
  /// the app's Apple token when the account is deleted. `Success(null)` when the
  /// user closed the sheet.
  Future<Result<String?>> appleAuthorizationCode();
}
