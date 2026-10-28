import 'package:core/core.dart';
import 'package:maratonas/maratonas.dart';

/// In-memory [MaratonasRepository] for widget and cubit tests. Each call is
/// recorded in [calls]; results are set per test.
class FakeMaratonasRepository implements MaratonasRepository {
  final calls = <String>[];
  final filters = <MaratonaFilter>[];

  Result<MaratonaPage> pageResult = const Success(MaratonaPage(maratonas: []));
  Result<Maratona>? maratonaResult;
  Result<List<MaratonaCategory>> challengesResult = const Success([]);
  Result<Maratona>? joinResult;
  Result<void> leaveResult = const Success(null);
  Result<MaratonaChallenge>? linkResult;
  Result<Maratona>? saveResult;

  @override
  Future<Result<MaratonaPage>> getMaratonas(
    MaratonaFilter filter, {
    int page = 1,
  }) async {
    calls.add('list $page');
    filters.add(filter);
    return pageResult;
  }

  @override
  Future<Result<Maratona>> getMaratona(String slug) async {
    calls.add('get $slug');
    return maratonaResult ?? const Failure(AppError.notFound);
  }

  @override
  Future<Result<SlugAvailability>> checkSlug(String slug) async =>
      Success(SlugAvailability(slug: slug, valid: true, available: true));

  @override
  Future<Result<Maratona>> create(MaratonaForm form) async {
    calls.add('create ${form.slug}');
    return saveResult ?? const Failure(AppError.server);
  }

  @override
  Future<Result<Maratona>> update(String slug, MaratonaForm form) async {
    calls.add('update $slug');
    return saveResult ?? const Failure(AppError.server);
  }

  @override
  Future<Result<Maratona>> cancel(String slug) async {
    calls.add('cancel $slug');
    return maratonaResult ?? const Failure(AppError.server);
  }

  @override
  Future<Result<Maratona>> join(
    String slug, {
    int? levelId,
    int? teamId,
    String? password,
  }) async {
    calls.add('join $slug $levelId $teamId $password');
    return joinResult ?? const Failure(AppError.server);
  }

  @override
  Future<Result<void>> leave(String slug) async {
    calls.add('leave $slug');
    return leaveResult;
  }

  @override
  Future<Result<List<MaratonaCategory>>> getChallenges(String slug) async {
    calls.add('challenges $slug');
    return challengesResult;
  }

  @override
  Future<Result<SuggestionPage>> getSuggestions(
    String slug,
    int challengeId, {
    int page = 1,
  }) async => const Success(SuggestionPage(movies: []));

  @override
  Future<Result<MaratonaChallenge>> setLink(
    String slug,
    int challengeId,
    int movieId, {
    required bool linked,
  }) async {
    calls.add('link $challengeId $movieId $linked');
    return linkResult ?? const Failure(AppError.server);
  }

  @override
  Future<Result<RankingPage>> getRanking(String slug, {int page = 1}) async =>
      const Success(RankingPage(entries: []));

  @override
  Future<Result<List<TeamRankingEntry>>> getTeamRanking(String slug) async =>
      const Success([]);

  @override
  Future<Result<List<MaratonaTemplate>>> getTemplates() async =>
      const Success([]);

  @override
  Future<Result<Maratona>> createFromTemplate(
    String templateId, {
    required String slug,
    required DateTime startsOn,
    String? title,
  }) async => saveResult ?? const Failure(AppError.server);
}
