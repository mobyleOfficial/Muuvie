import 'package:core/core.dart';
import 'package:gamification/gamification.dart';

sealed class ShelterState {
  const ShelterState();
}

class ShelterLoading extends ShelterState {
  const ShelterLoading();
}

class ShelterError extends ShelterState {
  final AppError error;

  const ShelterError(this.error);
}

class ShelterSuccess extends ShelterState {
  final PetShelter shelter;
  final bool busy;

  const ShelterSuccess(this.shelter, {this.busy = false});
}
