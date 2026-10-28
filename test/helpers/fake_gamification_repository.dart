import 'dart:async';

import 'package:core/core.dart';
import 'package:gamification/gamification.dart';

/// Answers with what the test sets and records what was asked.
class FakeGamificationRepository implements GamificationRepository {
  PetShelter shelter = const PetShelter(
    pets: [
      Pet(slug: 'pipoca-doce', rarity: PetRarity.starter),
      Pet(slug: 'pipoca-salgada', rarity: PetRarity.starter),
      Pet(slug: 'pipoca-caramelo', rarity: PetRarity.starter),
    ],
  );
  Result<PetShelter>? starterResult;
  MissionWeek? missions;
  DiaryDay? day;
  final savedDays = <DiaryDay>[];
  final starters = <String>[];
  final pins = <String>[];
  WatchParty? party;
  Result<WatchParty>? joinResult;
  final sent = <String>[];
  final starts = <int>[];
  final events = StreamController<PartyEvent>.broadcast();
  PosterRound? round;

  @override
  Future<Result<PetShelter>> getShelter() async => Success(shelter);

  @override
  Future<Result<PetShelter>> getPetsOf(String userId) async => Success(shelter);

  @override
  Future<Result<PetShelter>> chooseStarter(String slug) async {
    starters.add(slug);
    return starterResult ?? Success(shelter);
  }

  @override
  Future<Result<PetShelter>> pin(String slug) async {
    pins.add(slug);
    return Success(shelter);
  }

  @override
  Future<Result<MissionWeek>> getMissions() async =>
      missions == null ? const Failure(AppError.server) : Success(missions!);

  @override
  Future<Result<DiaryDay>> getDiaryDay(DateTime date) async =>
      Success(day ?? DiaryDay(date: date));

  @override
  Future<Result<DiaryDay>> saveDiaryDay(DiaryDay value) async {
    savedDays.add(value);
    return Success(
      DiaryDay(
        date: value.date,
        mood: value.mood,
        note: value.note,
        tasks: value.tasks,
        saved: true,
      ),
    );
  }

  @override
  Future<Result<List<DiaryDaySummary>>> getDiaryMonth(
    int year,
    int month,
  ) async => const Success([]);

  @override
  Future<Result<DiaryYear>> getDiaryYear(int year) async =>
      Success(DiaryYear(year: year));

  @override
  Future<Result<WatchParty>> createParty({String? title, int? movieId}) async =>
      Success(party!);

  @override
  Future<Result<WatchParty>> getParty(String code) async => Success(party!);

  @override
  Future<Result<WatchParty>> joinParty(String code) async =>
      joinResult ?? Success(party!);

  @override
  Future<Result<void>> leaveParty(String code) async => const Success(null);

  @override
  Future<Result<WatchParty>> startParty(String code, int inSeconds) async {
    starts.add(inSeconds);
    return Success(party!);
  }

  @override
  Future<Result<WatchParty>> sendPartyMessage(String code, String body) async {
    sent.add(body);
    return Success(party!);
  }

  @override
  Stream<PartyEvent> partyEvents() => events.stream;

  @override
  Future<Result<PosterRound>> getPosterRound() async => Success(round!);

  Future<void> dispose() => events.close();
}
