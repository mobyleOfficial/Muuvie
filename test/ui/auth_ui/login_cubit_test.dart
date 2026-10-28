import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:auth_domain/domain.dart';
import 'package:auth_ui/login/login_cubit.dart';
import 'package:auth_ui/login/login_state.dart';

class MockLoginUseCase extends Login {
  Result<void>? mockResult;

  MockLoginUseCase() : super(_FakeAuthRepository());

  @override
  Future<Result<void>> call([OAuthProvider? params]) async =>
      mockResult ?? const Failure(AppError.unknown);
}

class MockLoginWithEmailUseCase extends LoginWithEmail {
  Result<void>? mockResult;

  MockLoginWithEmailUseCase() : super(_FakeAuthRepository());

  @override
  Future<Result<void>> call([LoginWithEmailParams? params]) async =>
      mockResult ?? const Failure(AppError.unknown);
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
  Future<Result<void>> login(OAuthProvider provider) async =>
      const Failure(AppError.unknown);

  @override
  Future<Result<void>> loginWithEmail(String email, String password) async =>
      const Failure(AppError.unknown);

  @override
  Future<Result<bool>> isUserAuthenticated() async =>
      const Failure(AppError.unknown);

  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Stream<void> observeSessionEnded() => const Stream.empty();

  @override
  Future<Result<void>> signUp(
    String email,
    String password,
    String nickname,
  ) async => const Failure(AppError.unknown);

  @override
  Future<Result<bool>> checkNicknameAvailability(String nickname) async =>
      const Failure(AppError.unknown);
}

void main() {
  late MockLoginUseCase mockLogin;
  late MockLoginWithEmailUseCase mockLoginWithEmail;
  late MockIsUserAuthenticatedUseCase mockIsUserAuthenticated;

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockLoginWithEmail = MockLoginWithEmailUseCase();
    mockIsUserAuthenticated = MockIsUserAuthenticatedUseCase();
  });

  LoginCubit buildCubit() => LoginCubit(
    loginUseCase: mockLogin,
    loginWithEmailUseCase: mockLoginWithEmail,
    isUserAuthenticatedUseCase: mockIsUserAuthenticated,
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

  group('loginWithEmail', () {
    blocTest<LoginCubit, LoginState>(
      'emits [LoginFormState(submitting), LoginAuthenticated] on success',
      build: () {
        mockLoginWithEmail.mockResult = const Success(null);
        return buildCubit();
      },
      act: (cubit) => cubit.loginWithEmail('test@example.com', 'password123'),
      expect: () => [
        isA<LoginFormState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<LoginAuthenticated>(),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginFormState(submitting), LoginFormState(loginError)] on failure',
      build: () {
        mockLoginWithEmail.mockResult = const Failure(AppError.unauthorized);
        return buildCubit();
      },
      act: (cubit) => cubit.loginWithEmail('test@example.com', 'wrongpassword'),
      expect: () => [
        isA<LoginFormState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<LoginFormState>().having(
          (s) => s.loginError,
          'loginError',
          isNotNull,
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits validation errors for invalid email',
      build: buildCubit,
      act: (cubit) => cubit.loginWithEmail('invalid', 'password123'),
      expect: () => [
        isA<LoginFormState>().having(
          (s) => s.emailError,
          'emailError',
          isNotNull,
        ),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits validation errors for short password',
      build: buildCubit,
      act: (cubit) => cubit.loginWithEmail('test@example.com', '12345'),
      expect: () => [
        isA<LoginFormState>().having(
          (s) => s.passwordError,
          'passwordError',
          isNotNull,
        ),
      ],
    );
  });

  group('loginWithGoogle', () {
    blocTest<LoginCubit, LoginState>(
      'emits [LoginFormState(submitting), LoginAuthenticated] on success',
      build: () {
        mockLogin.mockResult = const Success(null);
        return buildCubit();
      },
      act: (cubit) => cubit.loginWithGoogle(),
      expect: () => [
        isA<LoginFormState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<LoginAuthenticated>(),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginFormState(submitting), LoginFormState(loginError)] on failure',
      build: () {
        mockLogin.mockResult = const Failure(AppError.network);
        return buildCubit();
      },
      act: (cubit) => cubit.loginWithGoogle(),
      expect: () => [
        isA<LoginFormState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<LoginFormState>().having(
          (s) => s.loginError,
          'loginError',
          isNotNull,
        ),
      ],
    );
  });

  group('loginWithFacebook', () {
    blocTest<LoginCubit, LoginState>(
      'emits [LoginFormState(submitting), LoginAuthenticated] on success',
      build: () {
        mockLogin.mockResult = const Success(null);
        return buildCubit();
      },
      act: (cubit) => cubit.loginWithFacebook(),
      expect: () => [
        isA<LoginFormState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<LoginAuthenticated>(),
      ],
    );
  });

  group('validation', () {
    test('validateEmail returns null for valid email', () {
      final cubit = buildCubit();
      expect(cubit.validateEmail('test@example.com'), isNull);
    });

    test('validateEmail returns error for empty email', () {
      final cubit = buildCubit();
      expect(cubit.validateEmail(''), 'required');
    });

    test('validateEmail returns error for invalid email', () {
      final cubit = buildCubit();
      expect(cubit.validateEmail('invalid'), 'invalid');
    });

    test('validatePassword returns null for valid password', () {
      final cubit = buildCubit();
      expect(cubit.validatePassword('password123'), isNull);
    });

    test('validatePassword returns error for empty password', () {
      final cubit = buildCubit();
      expect(cubit.validatePassword(''), 'required');
    });

    test('validatePassword returns error for short password', () {
      final cubit = buildCubit();
      expect(cubit.validatePassword('12345'), 'too_short');
    });
  });
}
