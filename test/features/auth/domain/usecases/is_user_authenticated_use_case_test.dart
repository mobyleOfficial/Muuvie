import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:auth_domain/domain.dart';

class MockAuthRepository implements AuthRepository {
  Result<bool>? isUserAuthenticatedResult;

  @override
  Future<Result<bool>> isUserAuthenticated() async =>
      isUserAuthenticatedResult ?? const Failure(AppError.unknown);

  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Stream<void> observeSessionEnded() => const Stream.empty();

  @override
  Future<Result<void>> login(OAuthProvider provider) async =>
      const Failure(AppError.unknown);

  @override
  Future<Result<void>> loginWithEmail(String email, String password) async =>
      const Failure(AppError.unknown);

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
  late IsUserAuthenticated useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = IsUserAuthenticated(mockRepository);
  });

  test('returns true when user is authenticated', () async {
    mockRepository.isUserAuthenticatedResult = const Success(true);

    final result = await useCase();

    expect(result, isA<Success<bool>>());
    expect((result as Success<bool>).data, true);
  });

  test('returns false when user is not authenticated', () async {
    mockRepository.isUserAuthenticatedResult = const Success(false);

    final result = await useCase();

    expect(result, isA<Success<bool>>());
    expect((result as Success<bool>).data, false);
  });

  test('returns failure on error', () async {
    mockRepository.isUserAuthenticatedResult = const Failure(AppError.unknown);

    final result = await useCase();

    expect(result, isA<Failure<bool>>());
  });
}
