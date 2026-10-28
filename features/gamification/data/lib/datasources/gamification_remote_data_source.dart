import 'package:core/core.dart';
import 'package:gamification_data/models/remote_gamification.dart';
import 'package:gamification_domain/models/models.dart';

abstract interface class GamificationRemoteDataSource {
  Future<Result<PetShelter>> getShelter();

  Future<Result<PetShelter>> getPetsOf(String userId);

  Future<Result<PetShelter>> chooseStarter(String slug);

  Future<Result<PetShelter>> pin(String slug);

  Future<Result<MissionWeek>> getMissions();

  Future<Result<DiaryDay>> getDiaryDay(DateTime date);

  Future<Result<DiaryDay>> saveDiaryDay(DiaryDay day);

  Future<Result<List<DiaryDaySummary>>> getDiaryMonth(int year, int month);

  Future<Result<DiaryYear>> getDiaryYear(int year);

  Future<Result<WatchParty>> createParty(String? title, int? movieId);

  Future<Result<WatchParty>> getParty(String code);

  Future<Result<WatchParty>> joinParty(String code);

  Future<Result<void>> leaveParty(String code);

  Future<Result<WatchParty>> startParty(String code, int inSeconds);

  Future<Result<WatchParty>> sendPartyMessage(String code, String body);

  Future<Result<PosterRound>> getPosterRound();
}

/// Gamification and games endpoints of the v1 API (`/api/v1`).
class GamificationRemoteDataSourceImpl implements GamificationRemoteDataSource {
  static const _base = '/api/v1';
  static const _me = '$_base/users/me';

  final HttpClient _httpClient;
  final DateTime Function() _now;

  GamificationRemoteDataSourceImpl(this._httpClient, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  @override
  Future<Result<PetShelter>> getShelter() async => _map(
    await _httpClient.get<Map<String, dynamic>>('$_me/pets'),
    RemoteGamification.shelter,
  );

  @override
  Future<Result<PetShelter>> getPetsOf(String userId) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/users/${Uri.encodeComponent(userId)}/pets',
    ),
    RemoteGamification.shelter,
  );

  @override
  Future<Result<PetShelter>> chooseStarter(String slug) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      '$_me/pets/starter',
      body: {'slug': slug},
    ),
    RemoteGamification.shelter,
  );

  @override
  Future<Result<PetShelter>> pin(String slug) async => _map(
    await _httpClient.put<Map<String, dynamic>>(
      '$_me/pets/${Uri.encodeComponent(slug)}/pin',
    ),
    RemoteGamification.shelter,
  );

  @override
  Future<Result<MissionWeek>> getMissions() async => _map(
    await _httpClient.get<Map<String, dynamic>>('$_me/missions'),
    RemoteGamification.missions,
  );

  @override
  Future<Result<DiaryDay>> getDiaryDay(DateTime date) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_me/diary/${RemoteGamification.day(date)}',
    ),
    RemoteGamification.diaryDay,
  );

  @override
  Future<Result<DiaryDay>> saveDiaryDay(DiaryDay day) async => _map(
    await _httpClient.put<Map<String, dynamic>>(
      '$_me/diary/${RemoteGamification.day(day.date)}',
      body: RemoteGamification.diaryBody(day),
    ),
    RemoteGamification.diaryDay,
  );

  @override
  Future<Result<List<DiaryDaySummary>>> getDiaryMonth(
    int year,
    int month,
  ) async => switch (await _httpClient.get<List<dynamic>>(
    '$_me/diary',
    queryParams: {
      'month':
          '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}',
    },
  )) {
    Success(:final data) => Success(RemoteGamification.diaryMonth(data)),
    Failure(:final error) => Failure(error),
  };

  @override
  Future<Result<DiaryYear>> getDiaryYear(int year) async => _map(
    await _httpClient.get<Map<String, dynamic>>('$_me/diary/summary/$year'),
    RemoteGamification.diaryYear,
  );

  @override
  Future<Result<WatchParty>> createParty(String? title, int? movieId) async =>
      _party(
        await _httpClient.post<Map<String, dynamic>>(
          '$_base/watch-parties',
          body: {'title': ?title, 'movieId': ?movieId},
        ),
      );

  @override
  Future<Result<WatchParty>> getParty(String code) async =>
      _party(await _httpClient.get<Map<String, dynamic>>(_partyPath(code)));

  @override
  Future<Result<WatchParty>> joinParty(String code) async => _party(
    await _httpClient.post<Map<String, dynamic>>('${_partyPath(code)}/members'),
  );

  @override
  Future<Result<void>> leaveParty(String code) async =>
      switch (await _httpClient.delete<dynamic>(
        '${_partyPath(code)}/members/me',
      )) {
        Success() => const Success(null),
        Failure(:final error) => Failure(error),
      };

  @override
  Future<Result<WatchParty>> startParty(String code, int inSeconds) async =>
      _party(
        await _httpClient.post<Map<String, dynamic>>(
          '${_partyPath(code)}/start',
          body: {'inSeconds': inSeconds},
        ),
      );

  @override
  Future<Result<WatchParty>> sendPartyMessage(String code, String body) async =>
      _party(
        await _httpClient.post<Map<String, dynamic>>(
          '${_partyPath(code)}/messages',
          body: {'body': body},
        ),
      );

  @override
  Future<Result<PosterRound>> getPosterRound() async => _map(
    await _httpClient.get<Map<String, dynamic>>('$_base/games/poster/round'),
    RemoteGamification.posterRound,
  );

  String _partyPath(String code) =>
      '$_base/watch-parties/${Uri.encodeComponent(code.trim().toUpperCase())}';

  Result<WatchParty> _party(Result<Map<String, dynamic>> result) {
    final received = _now().toUtc();
    return _map(result, (json) => RemoteGamification.party(json, received));
  }

  Result<T> _map<T>(
    Result<Map<String, dynamic>> result,
    T Function(Map<String, dynamic>) fromJson,
  ) => switch (result) {
    Success(:final data) => Success(fromJson(data)),
    Failure(:final error) => Failure(error),
  };
}
