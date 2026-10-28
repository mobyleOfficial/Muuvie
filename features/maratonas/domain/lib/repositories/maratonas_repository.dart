import 'package:core/core.dart';
import 'package:maratonas_domain/models/models.dart';

/// Maratonas of the v1 API (B7). The list, the detail and the challenges
/// work without login.
abstract interface class MaratonasRepository {
  Future<Result<MaratonaPage>> getMaratonas(
    MaratonaFilter filter, {
    int page = 1,
  });

  Future<Result<Maratona>> getMaratona(String slug);

  Future<Result<SlugAvailability>> checkSlug(String slug);

  /// Fails with `conflict` when the slug is taken.
  Future<Result<Maratona>> create(MaratonaForm form);

  Future<Result<Maratona>> update(String slug, MaratonaForm form);

  Future<Result<Maratona>> cancel(String slug);

  /// Fails with `forbidden` for a wrong password and `conflict` when the
  /// maratona is closed or the user already joined.
  Future<Result<Maratona>> join(
    String slug, {
    int? levelId,
    int? teamId,
    String? password,
  });

  Future<Result<void>> leave(String slug);

  /// Categories with the challenges the current user completed and the
  /// movies they tied.
  Future<Result<List<MaratonaCategory>>> getChallenges(String slug);

  Future<Result<SuggestionPage>> getSuggestions(
    String slug,
    int challengeId, {
    int page = 1,
  });

  /// Ties [movieId] (database id) to a challenge, or unties it.
  Future<Result<MaratonaChallenge>> setLink(
    String slug,
    int challengeId,
    int movieId, {
    required bool linked,
  });

  Future<Result<RankingPage>> getRanking(String slug, {int page = 1});

  Future<Result<List<TeamRankingEntry>>> getTeamRanking(String slug);

  Future<Result<List<MaratonaTemplate>>> getTemplates();

  Future<Result<Maratona>> createFromTemplate(
    String templateId, {
    required String slug,
    required DateTime startsOn,
    String? title,
  });
}
