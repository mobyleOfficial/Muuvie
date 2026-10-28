import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:auth_domain/domain.dart';

class MockAuthRepository implements AuthRepository {
  Result<void>? loginWithEmailResult;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<Result<void>> login(OAuthProvider provider) async =>
      const Failure(AppError.unknown);

  @override
  Future<Result<void>> loginWithEmail(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
    return loginWithEmailResult ?? const Failure(AppError.unknown);
  }

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
  late LoginWithEmail useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginWithEmail(mockRepository);
  });

  test('calls repository loginWithEmail with correct params', () async {
    mockRepository.loginWithEmailResult = const Success(null);

    final result = await useCase(
      const LoginWithEmailParams(
        email: 'test@example.com',
        password: 'password123',
      ),
    );

    expect(result, isA<Success<void>>());
    expect(mockRepository.lastEmail, 'test@example.com');
    expect(mockRepository.lastPassword, 'password123');
  });

  test('returns failure on error', () async {
    mockRepository.loginWithEmailResult = const Failure(AppError.unauthorized);

    final result = await useCase(
      const LoginWithEmailParams(email: 'test@example.com', password: 'wrong'),
    );

    expect(result, isA<Failure<void>>());
    expect((result as Failure<void>).error, AppError.unauthorized);
  });
}
