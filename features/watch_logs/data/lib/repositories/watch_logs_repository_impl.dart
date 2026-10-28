import 'package:core/core.dart';
import 'package:watch_logs_data/datasources/watch_logs_remote_data_source.dart';
import 'package:watch_logs_domain/models/models.dart';
import 'package:watch_logs_domain/repositories/watch_logs_repository.dart';

class WatchLogsRepositoryImpl implements WatchLogsRepository {
  final WatchLogsRemoteDataSource _remoteDataSource;

  WatchLogsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<MovieUserState>> getMovieState(int movieId) =>
      _remoteDataSource.getMovieState(movieId);

  @override
  Future<Result<WatchLog>> logSession({
    required int movieId,
    required WatchLogDraft draft,
  }) => _remoteDataSource.logSession(movieId, draft);

  @override
  Future<Result<WatchLog>> logSessionByTmdbId({
    required int tmdbId,
    required String title,
    required WatchLogDraft draft,
  }) => _remoteDataSource.logSessionByTmdbId(tmdbId, title, draft);

  @override
  Future<Result<MovieLogHistory>> getMovieLogs({
    required int movieId,
    String? userId,
    required int page,
  }) => _remoteDataSource.getMovieLogs(
    movieId: movieId,
    userId: userId,
    page: page,
  );

  @override
  Future<Result<DiaryPage>> getUserDiary({
    required String userId,
    required int page,
  }) => _remoteDataSource.getUserDiary(userId: userId, page: page);

  @override
  Future<Result<WatchLog>> updateLog(int logId, WatchLogDraft draft) =>
      _remoteDataSource.updateLog(logId, draft);

  @override
  Future<Result<void>> deleteLog(int logId) =>
      _remoteDataSource.deleteLog(logId);

  @override
  Future<Result<WatchProgress>> startRewatch(int movieId) =>
      _remoteDataSource.startRewatch(movieId);

  @override
  Future<Result<MovieRating>> rate(int movieId, RatingDraft draft) =>
      _remoteDataSource.rate(movieId, draft);

  @override
  Future<Result<void>> removeRating(int movieId) =>
      _remoteDataSource.removeRating(movieId);

  @override
  Future<Result<void>> setWatchingNow(int? movieId) =>
      _remoteDataSource.setWatchingNow(movieId);

  @override
  Future<Result<WatchingNow?>> getWatchingNow(String userId) =>
      _remoteDataSource.getWatchingNow(userId);

  @override
  Future<Result<List<Emotion>>> getRecentEmotions() =>
      _remoteDataSource.getRecentEmotions();

  @override
  Future<Result<List<Gif>>> getRecentGifs() =>
      _remoteDataSource.getRecentGifs();

  @override
  Future<Result<GifPage>> searchGifs(String query, {String? cursor}) =>
      _remoteDataSource.searchGifs(query, cursor);

  @override
  Future<Result<CommentPage>> getComments({
    required CommentTarget target,
    required int targetId,
    required int page,
  }) => _remoteDataSource.getComments(target, targetId, page);

  @override
  Future<Result<ThreadComment>> postComment({
    required CommentTarget target,
    required int targetId,
    required String body,
    bool hasSpoiler = false,
    int? parentId,
  }) => _remoteDataSource.postComment(
    target: target,
    targetId: targetId,
    body: body,
    hasSpoiler: hasSpoiler,
    parentId: parentId,
  );

  @override
  Future<Result<void>> deleteComment(int commentId) =>
      _remoteDataSource.deleteComment(commentId);
}
