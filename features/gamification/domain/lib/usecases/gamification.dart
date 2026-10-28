import 'package:core/core.dart';
import 'package:gamification_domain/models/models.dart';
import 'package:gamification_domain/repositories/gamification_repository.dart';

/// The shelter of the current user (F10.1).
class GetPetShelter extends UseCase<void, Result<PetShelter>> {
  final GamificationRepository _repository;

  GetPetShelter(this._repository);

  @override
  Future<Result<PetShelter>> call([void params]) => _repository.getShelter();
}

/// The unlocked bichinhos of a profile, to show the pinned one.
class GetProfilePets extends UseCase<String, Result<PetShelter>> {
  final GamificationRepository _repository;

  GetProfilePets(this._repository);

  @override
  Future<Result<PetShelter>> call([String? userId]) =>
      _repository.getPetsOf(userId!);
}

/// The starter pack: permanent.
class ChooseStarterPet extends UseCase<String, Result<PetShelter>> {
  final GamificationRepository _repository;

  ChooseStarterPet(this._repository);

  @override
  Future<Result<PetShelter>> call([String? slug]) =>
      _repository.chooseStarter(slug!);
}

class PinPet extends UseCase<String, Result<PetShelter>> {
  final GamificationRepository _repository;

  PinPet(this._repository);

  @override
  Future<Result<PetShelter>> call([String? slug]) => _repository.pin(slug!);
}

/// The missions of the week (F10.2).
class GetMissions extends UseCase<void, Result<MissionWeek>> {
  final GamificationRepository _repository;

  GetMissions(this._repository);

  @override
  Future<Result<MissionWeek>> call([void params]) => _repository.getMissions();
}

/// A day of the Caderninho (F10.3); reading never creates it.
class GetDiaryDay extends UseCase<DateTime, Result<DiaryDay>> {
  final GamificationRepository _repository;

  GetDiaryDay(this._repository);

  @override
  Future<Result<DiaryDay>> call([DateTime? date]) =>
      _repository.getDiaryDay(date!);
}

class SaveDiaryDay extends UseCase<DiaryDay, Result<DiaryDay>> {
  final GamificationRepository _repository;

  SaveDiaryDay(this._repository);

  @override
  Future<Result<DiaryDay>> call([DiaryDay? day]) =>
      _repository.saveDiaryDay(day!);
}

class DiaryMonthParams {
  final int year;
  final int month;

  const DiaryMonthParams({required this.year, required this.month});
}

class GetDiaryMonth
    extends UseCase<DiaryMonthParams, Result<List<DiaryDaySummary>>> {
  final GamificationRepository _repository;

  GetDiaryMonth(this._repository);

  @override
  Future<Result<List<DiaryDaySummary>>> call([DiaryMonthParams? params]) =>
      _repository.getDiaryMonth(params!.year, params.month);
}

/// The year of moods (F10.3).
class GetDiaryYear extends UseCase<int, Result<DiaryYear>> {
  final GamificationRepository _repository;

  GetDiaryYear(this._repository);

  @override
  Future<Result<DiaryYear>> call([int? year]) =>
      _repository.getDiaryYear(year!);
}

/// The watch parties (F10.4): every call of a room in one place.
class WatchPartyActions {
  final GamificationRepository _repository;

  WatchPartyActions(this._repository);

  Future<Result<WatchParty>> create({String? title, int? movieId}) =>
      _repository.createParty(title: title, movieId: movieId);

  Future<Result<WatchParty>> get(String code) => _repository.getParty(code);

  Future<Result<WatchParty>> join(String code) => _repository.joinParty(code);

  Future<Result<void>> leave(String code) => _repository.leaveParty(code);

  Future<Result<WatchParty>> start(String code, int inSeconds) =>
      _repository.startParty(code, inSeconds);

  Future<Result<WatchParty>> send(String code, String body) =>
      _repository.sendPartyMessage(code, body);

  Stream<PartyEvent> events(String code) =>
      _repository.partyEvents().where((event) => event.code == code);
}

/// A round of the poster game (F10.5).
class GetPosterRound extends UseCase<void, Result<PosterRound>> {
  final GamificationRepository _repository;

  GetPosterRound(this._repository);

  @override
  Future<Result<PosterRound>> call([void params]) =>
      _repository.getPosterRound();
}
