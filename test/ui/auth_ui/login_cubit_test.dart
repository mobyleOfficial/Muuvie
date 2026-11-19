import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:auth_domain/domain.dart';
import 'package:auth_ui/login/login_cubit.dart';
import 'package:auth_ui/login/login_state.dart';

class MockLoginUseCase extends Login {
  Result<SignInOutcome>? mockResult;
  OAuthProvider? lastProvider;

  MockLoginUseCase() : super(_FakeAuthRepository());

  @override
  Future<Result<SignInOutcome>> call([OAuthProvider? params]) async {
    lastProvider = params;
    return mockResult ?? const Failure(AppError.unknown);
  }
}

class MockIsUserAuthenticatedUseCase extends IsUserAuthenticated {
  Result<bool>? mockResult;

  MockIsUserAuthenticatedUseCase() : super(_FakeAuthRepository());

  @override
  Future<Result<bool>> call([void params]) async =>
      mockResult ?? const Failure(AppError.unknown);
}

class _FakeAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late MockLoginUseCase mockLogin;
  late MockIsUserAuthenticatedUseCase mockIsUserAuthenticated;

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockIsUserAuthenticated = MockIsUserAuthenticatedUseCase();
  });

  LoginCubit buildCubit() => LoginCubit(
    loginUseCase: mockLogin,
    isUserAuthenticatedUseCase: mockIsUserAuthenticated,
  );

  Matcher submitting(OAuthProvider provider) => isA<LoginFormState>().having(
    (s) => s.submittingProvider,
    'submittingProvider',
    provider,
  );

  group('checkAuthStatus', () {
    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginAuthenticated] when user is authenticated',
      build: () {
        mockIsUserAuthenticated.mockResult = const Success(true);
        return buildCubit();
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [isA<LoginLoading>(), isA<LoginAuthenticated>()],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginFormState] when not authenticated',
      build: () {
        mockIsUserAuthenticated.mockResult = const Success(false);
        return buildCubit();
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [isA<LoginLoading>(), isA<LoginFormState>()],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginFormState] on failure',
      build: () {
        mockIsUserAuthenticated.mockResult = const Failure(AppError.unknown);
        return buildCubit();
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [isA<LoginLoading>(), isA<LoginFormState>()],
    );
  });

  group('signIn', () {
    blocTest<LoginCubit, LoginState>(
      'an existing account is authenticated',
      build: () {
        mockLogin.mockResult = const Success(SignedIn(needsNickname: false));
        return buildCubit();
      },
      act: (cubit) => cubit.signIn(OAuthProvider.google),
      expect: () => [
        submitting(OAuthProvider.google),
        isA<LoginAuthenticated>(),
      ],
      verify: (_) => expect(mockLogin.lastProvider, OAuthProvider.google),
    );

    blocTest<LoginCubit, LoginState>(
      'a new account is asked for a nickname, with the suggestion',
      build: () {
        mockLogin.mockResult = const Success(
          SignedIn(needsNickname: true, suggestedNickname: 'Ana'),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.signIn(OAuthProvider.apple),
      expect: () => [
        submitting(OAuthProvider.apple),
        isA<LoginNeedsNickname>().having(
          (s) => s.suggestedNickname,
          'suggestedNickname',
          'Ana',
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'closing the provider sheet goes back to the buttons without an error',
      build: () {
        mockLogin.mockResult = const Success(SignInCancelled());
        return buildCubit();
      },
      act: (cubit) => cubit.signIn(OAuthProvider.apple),
      expect: () => [
        submitting(OAuthProvider.apple),
        isA<LoginFormState>()
            .having((s) => s.isSubmitting, 'isSubmitting', false)
            .having((s) => s.loginError, 'loginError', isNull),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'a failure shows the error',
      build: () {
        mockLogin.mockResult = const Failure(AppError.network);
        return buildCubit();
      },
      act: (cubit) => cubit.signIn(OAuthProvider.google),
      expect: () => [
        submitting(OAuthProvider.google),
        isA<LoginFormState>().having(
          (s) => s.loginError,
          'loginError',
          'generic',
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'a second tap while signing in is ignored',
      build: () {
        mockLogin.mockResult = const Success(SignedIn(needsNickname: false));
        return buildCubit();
      },
      seed: () => const LoginFormState(submittingProvider: OAuthProvider.apple),
      act: (cubit) => cubit.signIn(OAuthProvider.google),
      expect: () => const <LoginState>[],
    );
  });
}
