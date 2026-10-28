import 'package:core/core.dart';
import 'package:watch_logs_domain/models/models.dart';

/// Watch sessions, rating and comments on the v1 API (B2, B13.1).
/// [movieId] is the movie's database id (the `id` of the movie detail).
abstract interface class WatchLogsRepository {
  Future<Result<MovieUserState>> getMovieState(int movieId);

  Future<Result<WatchLog>> logSession({
    required int movieId,
    required WatchLogDraft draft,
  });

  /// For movies known only by their TMDB id (search results, cards).
  Future<Result<WatchLog>> logSessionByTmdbId({
    required int tmdbId,
    required String title,
    required WatchLogDraft draft,
  });

  /// [userId] null means the current user.
  Future<Result<MovieLogHistory>> getMovieLogs({
    required int movieId,
    String? userId,
    required int page,
  });

  /// Every session of [userId] the caller can see (`me` for the current user).
  Future<Result<DiaryPage>> getUserDiary({
    required String userId,
    required int page,
  });

  Future<Result<WatchLog>> updateLog(int logId, WatchLogDraft draft);

  Future<Result<void>> deleteLog(int logId);

  Future<Result<WatchProgress>> startRewatch(int movieId);

  Future<Result<MovieRating>> rate(int movieId, RatingDraft draft);

  Future<Result<void>> removeRating(int movieId);

  /// [movieId] null clears it.
  Future<Result<void>> setWatchingNow(int? movieId);

  /// Null when the user is not watching anything.
  Future<Result<WatchingNow?>> getWatchingNow(String userId);

  Future<Result<List<Emotion>>> getRecentEmotions();

  Future<Result<List<Gif>>> getRecentGifs();

  Future<Result<GifPage>> searchGifs(String query, {String? cursor});

  Future<Result<CommentPage>> getComments({
    required CommentTarget target,
    required int targetId,
    required int page,
  });

  Future<Result<ThreadComment>> postComment({
    required CommentTarget target,
    required int targetId,
    required String body,
    bool hasSpoiler = false,
    int? parentId,
  });

  Future<Result<void>> deleteComment(int commentId);
}
