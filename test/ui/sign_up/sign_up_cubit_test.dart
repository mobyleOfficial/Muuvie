import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:auth_domain/domain.dart';
import 'package:auth_ui/sign_up/sign_up_cubit.dart';
import 'package:auth_ui/sign_up/sign_up_state.dart';

class MockSignUpUseCase extends SignUp {
  Result<void>? mockResult;

  MockSignUpUseCase() : super(_FakeAuthRepository());

  @override
  Future<Result<void>> call([SignUpParams? params]) async =>
      mockResult ?? const Failure(AppError.unknown);
}

class MockCheckNicknameAvailabilityUseCase extends CheckNicknameAvailability {
  Result<bool>? mockResult;

  MockCheckNicknameAvailabilityUseCase() : super(_FakeAuthRepository());

  @override
  Future<Result<bool>> call([String? params]) async =>
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
  late MockSignUpUseCase mockSignUp;
  late MockCheckNicknameAvailabilityUseCase mockCheckNickname;

  setUp(() {
    mockSignUp = MockSignUpUseCase();
    mockCheckNickname = MockCheckNicknameAvailabilityUseCase();
  });

  SignUpCubit buildCubit() => SignUpCubit(
    signUp: mockSignUp,
    checkNicknameAvailability: mockCheckNickname,
  );

  group('createAccount', () {
    blocTest<SignUpCubit, SignUpState>(
      'emits [SignUpFormState(submitting), SignUpSuccess] on success',
      build: () {
        mockSignUp.mockResult = const Success(null);
        return buildCubit();
      },
      act: (cubit) =>
          cubit.createAccount('test@example.com', 'password123', 'nick'),
      expect: () => [
        isA<SignUpFormState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<SignUpSuccess>(),
      ],
    );

    blocTest<SignUpCubit, SignUpState>(
      'emits [SignUpFormState(submitting), SignUpFormState(signUpError)] on conflict',
      build: () {
        mockSignUp.mockResult = const Failure(AppError.conflict);
        return buildCubit();
      },
      act: (cubit) =>
          cubit.createAccount('test@example.com', 'password123', 'nick'),
      expect: () => [
        isA<SignUpFormState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<SignUpFormState>().having(
          (s) => s.signUpError,
          'signUpError',
          'conflict',
        ),
      ],
    );

    blocTest<SignUpCubit, SignUpState>(
      'emits [SignUpFormState with emailError] for invalid email',
      build: buildCubit,
      act: (cubit) => cubit.createAccount('invalid', 'password123', 'nick'),
      expect: () => [
        isA<SignUpFormState>().having(
          (s) => s.emailError,
          'emailError',
          isNotNull,
        ),
      ],
    );

    blocTest<SignUpCubit, SignUpState>(
      'emits [SignUpFormState with passwordError] for short password',
      build: buildCubit,
      act: (cubit) =>
          cubit.createAccount('test@example.com', '1234567', 'nick'),
      expect: () => [
        isA<SignUpFormState>().having(
          (s) => s.passwordError,
          'passwordError',
          isNotNull,
        ),
      ],
    );

    blocTest<SignUpCubit, SignUpState>(
      'emits [SignUpFormState with nicknameError] for empty nickname',
      build: buildCubit,
      act: (cubit) =>
          cubit.createAccount('test@example.com', 'password123', ''),
      expect: () => [
        isA<SignUpFormState>().having(
          (s) => s.nicknameError,
          'nicknameError',
          isNotNull,
        ),
      ],
    );
  });

  group('validation', () {
    test('validateEmail returns null for valid email', () {
      final cubit = buildCubit();
      expect(cubit.validateEmail('test@example.com'), isNull);
    });

    test('validateEmail returns required for empty', () {
      final cubit = buildCubit();
      expect(cubit.validateEmail(''), 'required');
    });

    test('validateEmail returns invalid for bad format', () {
      final cubit = buildCubit();
      expect(cubit.validateEmail('no-at-sign'), 'invalid');
    });

    test('validatePassword returns null for valid password', () {
      final cubit = buildCubit();
      expect(cubit.validatePassword('12345678'), isNull);
    });

    test('validatePassword returns required for empty', () {
      final cubit = buildCubit();
      expect(cubit.validatePassword(''), 'required');
    });

    test('validatePassword returns too_short for < 8 chars', () {
      final cubit = buildCubit();
      expect(cubit.validatePassword('1234567'), 'too_short');
    });

    test('validatePassword returns too_long for > 72 chars', () {
      final cubit = buildCubit();
      expect(cubit.validatePassword('a' * 73), 'too_long');
    });

    test('validateNickname returns null for non-empty', () {
      final cubit = buildCubit();
      expect(cubit.validateNickname('nick'), isNull);
    });

    test('validateNickname returns required for empty', () {
      final cubit = buildCubit();
      expect(cubit.validateNickname(''), 'required');
    });

    test('validateNickname returns too_long for > 30 chars', () {
      final cubit = buildCubit();
      expect(cubit.validateNickname('a' * 31), 'too_long');
    });
  });
}
