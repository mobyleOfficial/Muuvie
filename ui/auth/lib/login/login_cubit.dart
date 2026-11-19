import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:auth/auth.dart';
import 'package:auth_ui/login/login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final Login _loginUseCase;
  final IsUserAuthenticated _isUserAuthenticatedUseCase;

  LoginCubit({
    required Login loginUseCase,
    required IsUserAuthenticated isUserAuthenticatedUseCase,
  }) : _loginUseCase = loginUseCase,
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

  Future<void> signIn(OAuthProvider provider) async {
    if (state case LoginFormState(isSubmitting: true)) return;
    emit(LoginFormState(submittingProvider: provider));

    final result = await _loginUseCase(provider);
    if (isClosed) return;

    switch (result) {
      case Success(data: SignInCancelled()):
        emit(const LoginFormState());
      case Success(data: SignedIn(:final needsNickname, :final suggestedNickname)):
        Telemetry.analytics.logEvent(needsNickname ? 'sign_up' : 'login', {
          'method': provider.name,
        });
        emit(
          needsNickname
              ? LoginNeedsNickname(suggestedNickname: suggestedNickname)
              : const LoginAuthenticated(),
        );
      case Failure():
        emit(const LoginFormState(loginError: 'generic'));
    }
  }
}
