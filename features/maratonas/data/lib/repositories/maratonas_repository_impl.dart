import 'package:core/core.dart';
import 'package:maratonas_data/datasources/maratonas_remote_data_source.dart';
import 'package:maratonas_domain/models/models.dart';
import 'package:maratonas_domain/repositories/maratonas_repository.dart';

class MaratonasRepositoryImpl implements MaratonasRepository {
  final MaratonasRemoteDataSource _remoteDataSource;

  MaratonasRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<MaratonaPage>> getMaratonas(
    MaratonaFilter filter, {
    int page = 1,
  }) => _remoteDataSource.getMaratonas(filter, page);

  @override
  Future<Result<Maratona>> getMaratona(String slug) =>
      _remoteDataSource.getMaratona(slug);

  @override
  Future<Result<SlugAvailability>> checkSlug(String slug) =>
      _remoteDataSource.checkSlug(slug);

  @override
  Future<Result<Maratona>> create(MaratonaForm form) =>
      _remoteDataSource.create(form);

  @override
  Future<Result<Maratona>> update(String slug, MaratonaForm form) =>
      _remoteDataSource.update(slug, form);

  @override
  Future<Result<Maratona>> cancel(String slug) =>
      _remoteDataSource.cancel(slug);

  @override
  Future<Result<Maratona>> join(
    String slug, {
    int? levelId,
    int? teamId,
    String? password,
  }) => _remoteDataSource.join(slug, levelId, teamId, password);

  @override
  Future<Result<void>> leave(String slug) => _remoteDataSource.leave(slug);

  @override
  Future<Result<List<MaratonaCategory>>> getChallenges(String slug) =>
      _remoteDataSource.getChallenges(slug);

  @override
  Future<Result<SuggestionPage>> getSuggestions(
    String slug,
    int challengeId, {
    int page = 1,
  }) => _remoteDataSource.getSuggestions(slug, challengeId, page);

  @override
  Future<Result<MaratonaChallenge>> setLink(
    String slug,
    int challengeId,
    int movieId, {
    required bool linked,
  }) => _remoteDataSource.setLink(slug, challengeId, movieId, linked);

  @override
  Future<Result<RankingPage>> getRanking(String slug, {int page = 1}) =>
      _remoteDataSource.getRanking(slug, page);

  @override
  Future<Result<List<TeamRankingEntry>>> getTeamRanking(String slug) =>
      _remoteDataSource.getTeamRanking(slug);

  @override
  Future<Result<List<MaratonaTemplate>>> getTemplates() =>
      _remoteDataSource.getTemplates();

  @override
  Future<Result<Maratona>> createFromTemplate(
    String templateId, {
    required String slug,
    required DateTime startsOn,
    String? title,
  }) => _remoteDataSource.createFromTemplate(templateId, slug, startsOn, title);
}
