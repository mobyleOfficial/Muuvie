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
  Stream<void> observeSessionStarted() => const Stream.empty();

  @override
  Future<Result<bool>> deleteAccount() async => const Success(true);

  @override
  Future<Result<SignInOutcome>> login(OAuthProvider provider) async =>
      const Failure(AppError.unknown);

  @override
  Future<Result<void>> chooseNickname(String nickname) async =>
      const Failure(AppError.unknown);

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
