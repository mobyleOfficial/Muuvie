import 'package:core/core.dart';
import 'package:auth_domain/models/oauth_provider.dart';
import 'package:auth_domain/models/sign_in_outcome.dart';

abstract interface class AuthRepository {
  /// Signs in with the native Apple or Google sheet and saves the session.
  Future<Result<SignInOutcome>> login(OAuthProvider provider);

  /// Sets the nickname of the signed-in account.
  Future<Result<void>> chooseNickname(String nickname);
  Future<Result<bool>> checkNicknameAvailability(String nickname);
  Future<Result<bool>> isUserAuthenticated();
  Future<Result<void>> logout();

  /// Deletes the account and ends the session. An account that signs in with
  /// Apple asks Apple again first (to revoke its token); `Success(false)` when
  /// the user closed that sheet and nothing was deleted.
  Future<Result<bool>> deleteAccount();
  Stream<void> observeSessionEnded();

  /// Emits after each sign-in that saved a session.
  Stream<void> observeSessionStarted();
}
