import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:auth_domain/domain.dart';

class MockAuthRepository implements AuthRepository {
  Result<void>? loginResult;
  OAuthProvider? lastProvider;

  @override
  Future<Result<void>> login(OAuthProvider provider) async {
    lastProvider = provider;
    return loginResult ?? const Failure(AppError.unknown);
  }

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
  late Login useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = Login(mockRepository);
  });

  test('calls repository login with google provider', () async {
    mockRepository.loginResult = const Success(null);

    final result = await useCase(OAuthProvider.google);

    expect(result, isA<Success<void>>());
    expect(mockRepository.lastProvider, OAuthProvider.google);
  });

  test('calls repository login with facebook provider', () async {
    mockRepository.loginResult = const Success(null);

    final result = await useCase(OAuthProvider.facebook);

    expect(result, isA<Success<void>>());
    expect(mockRepository.lastProvider, OAuthProvider.facebook);
  });

  test('defaults to google when no provider given', () async {
    mockRepository.loginResult = const Success(null);

    await useCase();

    expect(mockRepository.lastProvider, OAuthProvider.google);
  });

  test('returns failure on error', () async {
    mockRepository.loginResult = const Failure(AppError.network);

    final result = await useCase(OAuthProvider.google);

    expect(result, isA<Failure<void>>());
    expect((result as Failure<void>).error, AppError.network);
  });
}
