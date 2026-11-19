import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:auth_domain/domain.dart';
import 'package:auth_ui/choose_nickname/choose_nickname_cubit.dart';
import 'package:auth_ui/choose_nickname/choose_nickname_state.dart';

class _FakeAuthRepository implements AuthRepository {
  Result<void> chooseResult = const Success(null);
  Result<bool> availableResult = const Success(true);
  String? lastNickname;

  @override
  Future<Result<void>> chooseNickname(String nickname) async {
    lastNickname = nickname;
    return chooseResult;
  }

  @override
  Future<Result<bool>> checkNicknameAvailability(String nickname) async =>
      availableResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FakeAuthRepository repository;

  setUp(() => repository = _FakeAuthRepository());

  ChooseNicknameCubit buildCubit() => ChooseNicknameCubit(
    chooseNickname: ChooseNickname(repository),
    checkNicknameAvailability: CheckNicknameAvailability(repository),
  );

  group('validateNickname', () {
    test('requires a nickname of at most 30 characters', () {
      final cubit = buildCubit();
      expect(cubit.validateNickname(''), 'required');
      expect(cubit.validateNickname('a' * 31), 'too_long');
      expect(cubit.validateNickname('Ana'), isNull);
    });
  });

  group('onNicknameChanged', () {
    blocTest<ChooseNicknameCubit, ChooseNicknameState>(
      'checks the availability after a pause',
      build: buildCubit,
      act: (cubit) => cubit.onNicknameChanged('ana'),
      wait: const Duration(seconds: 1),
      expect: () => [
        isA<ChooseNicknameFormState>(),
        isA<ChooseNicknameFormState>().having(
          (s) => s.isCheckingNickname,
          'isCheckingNickname',
          true,
        ),
        isA<ChooseNicknameFormState>().having(
          (s) => s.isNicknameAvailable,
          'isNicknameAvailable',
          true,
        ),
      ],
    );

    blocTest<ChooseNicknameCubit, ChooseNicknameState>(
      'flags a taken nickname',
      build: () {
        repository.availableResult = const Success(false);
        return buildCubit();
      },
      act: (cubit) => cubit.onNicknameChanged('ana'),
      wait: const Duration(seconds: 1),
      skip: 2,
      expect: () => [
        isA<ChooseNicknameFormState>().having(
          (s) => s.nicknameError,
          'nicknameError',
          'taken',
        ),
      ],
    );
  });

  group('submit', () {
    blocTest<ChooseNicknameCubit, ChooseNicknameState>(
      'saves the nickname',
      build: buildCubit,
      act: (cubit) => cubit.submit('Ana'),
      expect: () => [
        isA<ChooseNicknameFormState>().having(
          (s) => s.isSubmitting,
          'isSubmitting',
          true,
        ),
        isA<ChooseNicknameSuccess>(),
      ],
      verify: (_) => expect(repository.lastNickname, 'Ana'),
    );

    blocTest<ChooseNicknameCubit, ChooseNicknameState>(
      'does not send an empty nickname',
      build: buildCubit,
      act: (cubit) => cubit.submit(''),
      expect: () => [
        isA<ChooseNicknameFormState>().having(
          (s) => s.nicknameError,
          'nicknameError',
          'required',
        ),
      ],
      verify: (_) => expect(repository.lastNickname, isNull),
    );

    blocTest<ChooseNicknameCubit, ChooseNicknameState>(
      'a conflict marks the nickname as taken',
      build: () {
        repository.chooseResult = const Failure(AppError.conflict);
        return buildCubit();
      },
      act: (cubit) => cubit.submit('Ana'),
      skip: 1,
      expect: () => [
        isA<ChooseNicknameFormState>().having(
          (s) => s.nicknameError,
          'nicknameError',
          'taken',
        ),
      ],
    );

    blocTest<ChooseNicknameCubit, ChooseNicknameState>(
      'a network failure shows the error banner',
      build: () {
        repository.chooseResult = const Failure(AppError.network);
        return buildCubit();
      },
      act: (cubit) => cubit.submit('Ana'),
      skip: 1,
      expect: () => [
        isA<ChooseNicknameFormState>().having(
          (s) => s.submitError,
          'submitError',
          'network',
        ),
      ],
    );
  });
}
