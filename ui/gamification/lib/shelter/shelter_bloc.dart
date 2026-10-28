import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/shelter/shelter_state.dart';

/// The shelter of the bichinhos (F10.1): the starter pack, then every one.
/// Actions answer the error, or null when they worked.
class ShelterCubit extends Cubit<ShelterState> {
  final GetPetShelter _getShelter;
  final ChooseStarterPet _chooseStarter;
  final PinPet _pinPet;

  ShelterCubit({
    required GetPetShelter getShelter,
    required ChooseStarterPet chooseStarter,
    required PinPet pinPet,
  }) : _getShelter = getShelter,
       _chooseStarter = chooseStarter,
       _pinPet = pinPet,
       super(const ShelterLoading());

  Future<void> load() async {
    final result = await _getShelter();
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => ShelterSuccess(data),
      Failure(:final error) => ShelterError(error),
    });
  }

  Future<AppError?> chooseStarter(String slug) =>
      _act(() => _chooseStarter(slug));

  Future<AppError?> pin(String slug) => _act(() => _pinPet(slug));

  Future<AppError?> _act(Future<Result<PetShelter>> Function() action) async {
    final current = state;
    if (current is! ShelterSuccess) return null;
    emit(ShelterSuccess(current.shelter, busy: true));
    final result = await action();
    if (isClosed) return null;
    switch (result) {
      case Success(:final data):
        emit(ShelterSuccess(data));
        return null;
      case Failure(:final error):
        emit(ShelterSuccess(current.shelter));
        return error;
    }
  }
}
