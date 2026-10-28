sealed class LoginState {
  const LoginState();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginAuthenticated extends LoginState {
  const LoginAuthenticated();
}

final class LoginUnauthenticated extends LoginState {
  const LoginUnauthenticated();
}

final class LoginError extends LoginState {
  final String message;

  const LoginError(this.message);
}

final class LoginFormState extends LoginState {
  final String? emailError;
  final String? passwordError;
  final bool isSubmitting;
  final String? loginError;

  const LoginFormState({
    this.emailError,
    this.passwordError,
    this.isSubmitting = false,
    this.loginError,
  });

  LoginFormState copyWith({
    String? emailError,
    String? passwordError,
    bool? isSubmitting,
    String? loginError,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearLoginError = false,
  }) => LoginFormState(
    emailError: clearEmailError ? null : (emailError ?? this.emailError),
    passwordError: clearPasswordError
        ? null
        : (passwordError ?? this.passwordError),
    isSubmitting: isSubmitting ?? this.isSubmitting,
    loginError: clearLoginError ? null : (loginError ?? this.loginError),
  );

  bool get isValid => emailError == null && passwordError == null;
}
