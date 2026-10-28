import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auth_domain/usecases/sign_up.dart';
import 'package:auth_domain/usecases/check_nickname_availability.dart';
import 'package:auth_ui/sign_up/sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const _minPasswordLength = 8;
  static const _maxPasswordLength = 72;
  static const _maxNicknameLength = 30;
  static const _nicknameDebounceDelay = Duration(milliseconds: 700);

  final SignUp _signUp;
  final CheckNicknameAvailability _checkNicknameAvailability;
  Timer? _nicknameDebounce;

  SignUpCubit({
    required SignUp signUp,
    required CheckNicknameAvailability checkNicknameAvailability,
  }) : _signUp = signUp,
       _checkNicknameAvailability = checkNicknameAvailability,
       super(const SignUpFormState());

  String? validateEmail(String email) {
    if (email.isEmpty) return 'required';
    if (!_emailRegex.hasMatch(email)) return 'invalid';
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'required';
    if (password.length < _minPasswordLength) return 'too_short';
    if (password.length > _maxPasswordLength) return 'too_long';
    return null;
  }

  String? validateNickname(String nickname) {
    if (nickname.isEmpty) return 'required';
    if (nickname.length > _maxNicknameLength) return 'too_long';
    return null;
  }

  void onEmailChanged(String email) {
    final current = state;
    if (current is! SignUpFormState) return;

    final error = validateEmail(email);
    emit(
      current.copyWith(
        emailError: error,
        clearEmailError: error == null,
        clearSignUpError: true,
      ),
    );
  }

  void onPasswordChanged(String password) {
    final current = state;
    if (current is! SignUpFormState) return;

    final error = validatePassword(password);
    emit(
      current.copyWith(
        passwordError: error,
        clearPasswordError: error == null,
        clearSignUpError: true,
      ),
    );
  }

  void onNicknameChanged(String nickname) {
    final current = state;
    if (current is! SignUpFormState) return;

    _nicknameDebounce?.cancel();

    final error = validateNickname(nickname);
    emit(
      current.copyWith(
        nicknameError: error,
        clearNicknameError: error == null,
        clearSignUpError: true,
        isCheckingNickname: false,
        clearNicknameAvailability: true,
      ),
    );

    if (error != null || nickname.isEmpty) return;

    emit((state as SignUpFormState).copyWith(isCheckingNickname: true));

    _nicknameDebounce = Timer(_nicknameDebounceDelay, () {
      _checkNickname(nickname);
    });
  }

  Future<void> _checkNickname(String nickname) async {
    final result = await _checkNicknameAvailability(nickname);

    if (isClosed) return;
    final current = state;
    if (current is! SignUpFormState) return;

    switch (result) {
      case Success(:final data):
        emit(
          current.copyWith(
            isCheckingNickname: false,
            isNicknameAvailable: data,
            nicknameError: data ? null : 'taken',
            clearNicknameError: data,
          ),
        );
      case Failure():
        emit(current.copyWith(isCheckingNickname: false));
    }
  }

  Future<void> createAccount(
    String email,
    String password,
    String nickname,
  ) async {
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);
    final nicknameError = validateNickname(nickname);

    if (emailError != null || passwordError != null || nicknameError != null) {
      emit(
        SignUpFormState(
          emailError: emailError,
          passwordError: passwordError,
          nicknameError: nicknameError,
        ),
      );
      return;
    }

    emit(const SignUpFormState(isSubmitting: true));

    final result = await _signUp(
      SignUpParams(email: email, password: password, nickname: nickname),
    );

    if (isClosed) return;

    switch (result) {
      case Success():
        emit(const SignUpSuccess());
      case Failure(:final error):
        final errorKey = switch (error) {
          AppError.conflict => 'conflict',
          AppError.badRequest => 'bad_request',
          AppError.network => 'network',
          AppError.server => 'server',
          _ => 'generic',
        };
        emit(SignUpFormState(signUpError: errorKey));
    }
  }

  @override
  Future<void> close() {
    _nicknameDebounce?.cancel();
    return super.close();
  }
}
