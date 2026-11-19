import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auth_domain/usecases/check_nickname_availability.dart';
import 'package:auth_domain/usecases/choose_nickname.dart';
import 'package:auth_ui/choose_nickname/choose_nickname_state.dart';

/// The nickname a new account picks after its first sign-in. Availability is
/// checked while typing; the server has the last word on submit.
class ChooseNicknameCubit extends Cubit<ChooseNicknameState> {
  static const maxNicknameLength = 30;
  static const _nicknameDebounceDelay = Duration(milliseconds: 700);

  final ChooseNickname _chooseNickname;
  final CheckNicknameAvailability _checkNicknameAvailability;
  Timer? _nicknameDebounce;

  ChooseNicknameCubit({
    required ChooseNickname chooseNickname,
    required CheckNicknameAvailability checkNicknameAvailability,
  }) : _chooseNickname = chooseNickname,
       _checkNicknameAvailability = checkNicknameAvailability,
       super(const ChooseNicknameFormState());

  String? validateNickname(String nickname) {
    if (nickname.isEmpty) return 'required';
    if (nickname.length > maxNicknameLength) return 'too_long';
    return null;
  }

  void onNicknameChanged(String nickname) {
    final current = state;
    if (current is! ChooseNicknameFormState) return;

    _nicknameDebounce?.cancel();

    final error = validateNickname(nickname);
    emit(
      current.copyWith(
        nicknameError: error,
        clearNicknameError: error == null,
        clearSubmitError: true,
        isCheckingNickname: false,
        clearNicknameAvailability: true,
      ),
    );

    if (error != null) return;

    emit((state as ChooseNicknameFormState).copyWith(isCheckingNickname: true));

    _nicknameDebounce = Timer(_nicknameDebounceDelay, () {
      _checkNickname(nickname);
    });
  }

  Future<void> _checkNickname(String nickname) async {
    final result = await _checkNicknameAvailability(nickname);

    if (isClosed) return;
    final current = state;
    if (current is! ChooseNicknameFormState) return;

    switch (result) {
      case Success(:final data):
        emit(
          current.copyWith(
            isCheckingNickname: false,
            isNicknameAvailable: data,
            nicknameError: data ? null : 'taken',
            clearNicknameError: data,
          ),
        );
      case Failure():
        emit(current.copyWith(isCheckingNickname: false));
    }
  }

  Future<void> submit(String nickname) async {
    final error = validateNickname(nickname);
    if (error != null) {
      emit(ChooseNicknameFormState(nicknameError: error));
      return;
    }

    _nicknameDebounce?.cancel();
    emit(const ChooseNicknameFormState(isSubmitting: true));

    final result = await _chooseNickname(nickname);
    if (isClosed) return;

    switch (result) {
      case Success():
        emit(const ChooseNicknameSuccess());
      case Failure(:final error):
        emit(
          switch (error) {
            AppError.conflict => const ChooseNicknameFormState(
              nicknameError: 'taken',
            ),
            AppError.badRequest => const ChooseNicknameFormState(
              submitError: 'bad_request',
            ),
            AppError.network => const ChooseNicknameFormState(
              submitError: 'network',
            ),
            AppError.server => const ChooseNicknameFormState(
              submitError: 'server',
            ),
            _ => const ChooseNicknameFormState(submitError: 'generic'),
          },
        );
    }
  }

  @override
  Future<void> close() {
    _nicknameDebounce?.cancel();
    return super.close();
  }
}
