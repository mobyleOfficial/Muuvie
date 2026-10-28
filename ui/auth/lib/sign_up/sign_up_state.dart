sealed class SignUpState {
  const SignUpState();
}

final class SignUpFormState extends SignUpState {
  final String? emailError;
  final String? passwordError;
  final String? nicknameError;
  final bool isSubmitting;
  final String? signUpError;
  final bool isCheckingNickname;
  final bool? isNicknameAvailable;

  const SignUpFormState({
    this.emailError,
    this.passwordError,
    this.nicknameError,
    this.isSubmitting = false,
    this.signUpError,
    this.isCheckingNickname = false,
    this.isNicknameAvailable,
  });

  SignUpFormState copyWith({
    String? emailError,
    bool clearEmailError = false,
    String? passwordError,
    bool clearPasswordError = false,
    String? nicknameError,
    bool clearNicknameError = false,
    bool? isSubmitting,
    String? signUpError,
    bool clearSignUpError = false,
    bool? isCheckingNickname,
    bool? isNicknameAvailable,
    bool clearNicknameAvailability = false,
  }) => SignUpFormState(
    emailError: clearEmailError ? null : (emailError ?? this.emailError),
    passwordError: clearPasswordError
        ? null
        : (passwordError ?? this.passwordError),
    nicknameError: clearNicknameError
        ? null
        : (nicknameError ?? this.nicknameError),
    isSubmitting: isSubmitting ?? this.isSubmitting,
    signUpError: clearSignUpError ? null : (signUpError ?? this.signUpError),
    isCheckingNickname: isCheckingNickname ?? this.isCheckingNickname,
    isNicknameAvailable: clearNicknameAvailability
        ? null
        : (isNicknameAvailable ?? this.isNicknameAvailable),
  );
}

final class SignUpSuccess extends SignUpState {
  const SignUpSuccess();
}
