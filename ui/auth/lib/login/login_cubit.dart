import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:auth/auth.dart';
import 'package:auth_ui/login/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final Login _loginUseCase;
  final LoginWithEmail _loginWithEmailUseCase;
  final IsUserAuthenticated _isUserAuthenticatedUseCase;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  LoginCubit({
    required Login loginUseCase,
    required LoginWithEmail loginWithEmailUseCase,
    required IsUserAuthenticated isUserAuthenticatedUseCase,
  }) : _loginUseCase = loginUseCase,
       _loginWithEmailUseCase = loginWithEmailUseCase,
       _isUserAuthenticatedUseCase = isUserAuthenticatedUseCase,
       super(const LoginFormState());

  Future<void> checkAuthStatus() async {
    emit(const LoginLoading());

    final result = await _isUserAuthenticatedUseCase();

    switch (result) {
      case Success(:final data):
        data ? emit(const LoginAuthenticated()) : emit(const LoginFormState());
      case Failure():
        emit(const LoginFormState());
    }
  }

  String? validateEmail(String email) {
    if (email.isEmpty) return 'required';
    if (!_emailRegex.hasMatch(email)) return 'invalid';
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return 'required';
    if (password.length < 8) return 'too_short';
    return null;
  }

  void onEmailChanged(String email) {
    final current = state;
    if (current is! LoginFormState) return;
    final emailError = validateEmail(email);
    emit(
      current.copyWith(
        emailError: emailError,
        clearEmailError: emailError == null,
        clearLoginError: true,
      ),
    );
  }

  void onPasswordChanged(String password) {
    final current = state;
    if (current is! LoginFormState) return;
    final passwordError = validatePassword(password);
    emit(
      current.copyWith(
        passwordError: passwordError,
        clearPasswordError: passwordError == null,
        clearLoginError: true,
      ),
    );
  }

  Future<void> loginWithEmail(String email, String password) async {
    final emailError = validateEmail(email);
    final passwordError = validatePassword(password);

    if (emailError != null || passwordError != null) {
      emit(
        LoginFormState(emailError: emailError, passwordError: passwordError),
      );
      return;
    }

    emit(const LoginFormState(isSubmitting: true));

    final result = await _loginWithEmailUseCase(
      LoginWithEmailParams(email: email, password: password),
    );

    switch (result) {
      case Success():
        emit(const LoginAuthenticated());
      case Failure(:final error):
        final errorKey = error == AppError.unauthorized
            ? 'invalid_credentials'
            : 'generic';
        emit(LoginFormState(loginError: errorKey));
    }
  }

  Future<void> loginWithGoogle() async =>
      _loginWithProvider(OAuthProvider.google);

  Future<void> loginWithFacebook() async =>
      _loginWithProvider(OAuthProvider.facebook);

  Future<void> _loginWithProvider(OAuthProvider provider) async {
    emit(const LoginFormState(isSubmitting: true));

    final result = await _loginUseCase(provider);

    switch (result) {
      case Success():
        emit(const LoginAuthenticated());
      case Failure(:final error):
        final errorKey = error == AppError.unauthorized
            ? 'invalid_credentials'
            : 'generic';
        emit(LoginFormState(loginError: errorKey));
    }
  }
}
