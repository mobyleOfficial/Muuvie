import 'package:core/core.dart';
import 'package:gamification_data/datasources/gamification_remote_data_source.dart';
import 'package:gamification_domain/models/models.dart';
import 'package:gamification_domain/repositories/gamification_repository.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  final GamificationRemoteDataSource _remoteDataSource;
  final WebSocketClient _webSocketClient;

  GamificationRepositoryImpl(this._remoteDataSource, this._webSocketClient);

  @override
  Future<Result<PetShelter>> getShelter() => _remoteDataSource.getShelter();

  @override
  Future<Result<PetShelter>> getPetsOf(String userId) =>
      _remoteDataSource.getPetsOf(userId);

  @override
  Future<Result<PetShelter>> chooseStarter(String slug) =>
      _remoteDataSource.chooseStarter(slug);

  @override
  Future<Result<PetShelter>> pin(String slug) => _remoteDataSource.pin(slug);

  @override
  Future<Result<MissionWeek>> getMissions() => _remoteDataSource.getMissions();

  @override
  Future<Result<DiaryDay>> getDiaryDay(DateTime date) =>
      _remoteDataSource.getDiaryDay(date);

  @override
  Future<Result<DiaryDay>> saveDiaryDay(DiaryDay day) =>
      _remoteDataSource.saveDiaryDay(day);

  @override
  Future<Result<List<DiaryDaySummary>>> getDiaryMonth(int year, int month) =>
      _remoteDataSource.getDiaryMonth(year, month);

  @override
  Future<Result<DiaryYear>> getDiaryYear(int year) =>
      _remoteDataSource.getDiaryYear(year);

  @override
  Future<Result<WatchParty>> createParty({String? title, int? movieId}) =>
      _remoteDataSource.createParty(title, movieId);

  @override
  Future<Result<WatchParty>> getParty(String code) =>
      _remoteDataSource.getParty(code);

  @override
  Future<Result<WatchParty>> joinParty(String code) =>
      _remoteDataSource.joinParty(code);

  @override
  Future<Result<void>> leaveParty(String code) =>
      _remoteDataSource.leaveParty(code);

  @override
  Future<Result<WatchParty>> startParty(String code, int inSeconds) =>
      _remoteDataSource.startParty(code, inSeconds);

  @override
  Future<Result<WatchParty>> sendPartyMessage(String code, String body) =>
      _remoteDataSource.sendPartyMessage(code, body);

  @override
  Stream<PartyEvent> partyEvents() => _webSocketClient.messages
      .where((message) => message.type == WsMessageType.watchParty)
      .map(
        (message) => PartyEvent(
          code: '${message.data?['code'] ?? ''}',
          event: '${message.data?['event'] ?? ''}',
        ),
      );

  @override
  Future<Result<PosterRound>> getPosterRound() =>
      _remoteDataSource.getPosterRound();
}
