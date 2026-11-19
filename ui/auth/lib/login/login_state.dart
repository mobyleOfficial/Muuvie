import 'package:auth/auth.dart';

sealed class LoginState {
  const LoginState();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginAuthenticated extends LoginState {
  const LoginAuthenticated();
}

/// Signed in to a new account that still has a generated nickname.
final class LoginNeedsNickname extends LoginState {
  final String? suggestedNickname;

  const LoginNeedsNickname({this.suggestedNickname});
}

final class LoginFormState extends LoginState {
  /// The provider whose sheet is open or whose sign-in is being sent.
  final OAuthProvider? submittingProvider;

  /// `generic` when the last sign-in failed.
  final String? loginError;

  const LoginFormState({this.submittingProvider, this.loginError});

  bool get isSubmitting => submittingProvider != null;
}
