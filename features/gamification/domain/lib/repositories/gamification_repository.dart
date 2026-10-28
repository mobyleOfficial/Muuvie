import 'package:core/core.dart';
import 'package:gamification_domain/models/models.dart';

/// Bichinho, missions, Caderninho, watch parties and the poster game of the
/// v1 API (B10). Everything is the current user's but [getPetsOf].
abstract interface class GamificationRepository {
  Future<Result<PetShelter>> getShelter();

  /// The unlocked bichinhos of a profile ([userId] or `me`).
  Future<Result<PetShelter>> getPetsOf(String userId);

  /// Fails with `conflict` when the starter was already chosen.
  Future<Result<PetShelter>> chooseStarter(String slug);

  Future<Result<PetShelter>> pin(String slug);

  Future<Result<MissionWeek>> getMissions();

  Future<Result<DiaryDay>> getDiaryDay(DateTime date);

  /// Saving an empty day deletes it.
  Future<Result<DiaryDay>> saveDiaryDay(DiaryDay day);

  Future<Result<List<DiaryDaySummary>>> getDiaryMonth(int year, int month);

  Future<Result<DiaryYear>> getDiaryYear(int year);

  Future<Result<WatchParty>> createParty({String? title, int? movieId});

  Future<Result<WatchParty>> getParty(String code);

  /// Fails with `notFound` for an unknown code and `conflict` when full.
  Future<Result<WatchParty>> joinParty(String code);

  Future<Result<void>> leaveParty(String code);

  Future<Result<WatchParty>> startParty(String code, int inSeconds);

  Future<Result<WatchParty>> sendPartyMessage(String code, String body);

  /// Changes of the parties the user is in, from the WebSocket.
  Stream<PartyEvent> partyEvents();

  Future<Result<PosterRound>> getPosterRound();
}
