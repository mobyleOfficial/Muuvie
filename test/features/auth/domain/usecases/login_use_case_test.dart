import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:auth_domain/domain.dart';

class MockAuthRepository implements AuthRepository {
  Result<SignInOutcome>? loginResult;
  OAuthProvider? lastProvider;
  String? lastNickname;

  @override
  Future<Result<SignInOutcome>> login(OAuthProvider provider) async {
    lastProvider = provider;
    return loginResult ?? const Failure(AppError.unknown);
  }

  @override
  Future<Result<void>> chooseNickname(String nickname) async {
    lastNickname = nickname;
    return const Success(null);
  }

  @override
  Future<Result<bool>> isUserAuthenticated() async =>
      const Failure(AppError.unknown);

  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Stream<void> observeSessionEnded() => const Stream.empty();

  @override
  Future<Result<bool>> checkNicknameAvailability(String nickname) async =>
      const Failure(AppError.unknown);
}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() => mockRepository = MockAuthRepository());

  test('Login signs in with the given provider', () async {
    mockRepository.loginResult = const Success(
      SignedIn(needsNickname: false),
    );

    final result = await Login(mockRepository)(OAuthProvider.apple);

    expect(mockRepository.lastProvider, OAuthProvider.apple);
    expect((result as Success<SignInOutcome>).data, isA<SignedIn>());
  });

  test('Login passes the failure through', () async {
    mockRepository.loginResult = const Failure(AppError.network);

    final result = await Login(mockRepository)(OAuthProvider.google);

    expect((result as Failure<SignInOutcome>).error, AppError.network);
  });

  test('ChooseNickname sends the nickname', () async {
    final result = await ChooseNickname(mockRepository)('Ana');

    expect(result, isA<Success<void>>());
    expect(mockRepository.lastNickname, 'Ana');
  });
}
