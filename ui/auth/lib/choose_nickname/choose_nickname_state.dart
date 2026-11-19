sealed class ChooseNicknameState {
  const ChooseNicknameState();
}

final class ChooseNicknameFormState extends ChooseNicknameState {
  /// `required`, `too_long` or `taken`.
  final String? nicknameError;
  final bool isSubmitting;

  /// `conflict`, `bad_request`, `network`, `server` or `generic`.
  final String? submitError;
  final bool isCheckingNickname;
  final bool? isNicknameAvailable;

  const ChooseNicknameFormState({
    this.nicknameError,
    this.isSubmitting = false,
    this.submitError,
    this.isCheckingNickname = false,
    this.isNicknameAvailable,
  });

  ChooseNicknameFormState copyWith({
    String? nicknameError,
    bool clearNicknameError = false,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
    bool? isCheckingNickname,
    bool? isNicknameAvailable,
    bool clearNicknameAvailability = false,
  }) => ChooseNicknameFormState(
    nicknameError: clearNicknameError
        ? null
        : (nicknameError ?? this.nicknameError),
    isSubmitting: isSubmitting ?? this.isSubmitting,
    submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    isCheckingNickname: isCheckingNickname ?? this.isCheckingNickname,
    isNicknameAvailable: clearNicknameAvailability
        ? null
        : (isNicknameAvailable ?? this.isNicknameAvailable),
  );
}

final class ChooseNicknameSuccess extends ChooseNicknameState {
  const ChooseNicknameSuccess();
}
