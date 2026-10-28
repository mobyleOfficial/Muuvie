import 'package:core/core.dart';
import 'package:watch_logs_data/models/remote_watch_logs.dart';
import 'package:watch_logs_domain/models/models.dart';

abstract interface class WatchLogsRemoteDataSource {
  Future<Result<MovieUserState>> getMovieState(int movieId);

  Future<Result<WatchLog>> logSession(int movieId, WatchLogDraft draft);

  Future<Result<WatchLog>> logSessionByTmdbId(
    int tmdbId,
    String title,
    WatchLogDraft draft,
  );

  Future<Result<MovieLogHistory>> getMovieLogs({
    required int movieId,
    String? userId,
    required int page,
  });

  Future<Result<DiaryPage>> getUserDiary({
    required String userId,
    required int page,
  });

  Future<Result<WatchLog>> updateLog(int logId, WatchLogDraft draft);

  Future<Result<void>> deleteLog(int logId);

  Future<Result<WatchProgress>> startRewatch(int movieId);

  Future<Result<MovieRating>> rate(int movieId, RatingDraft draft);

  Future<Result<void>> removeRating(int movieId);

  Future<Result<void>> setWatchingNow(int? movieId);

  Future<Result<WatchingNow?>> getWatchingNow(String userId);

  Future<Result<List<Emotion>>> getRecentEmotions();

  Future<Result<List<Gif>>> getRecentGifs();

  Future<Result<GifPage>> searchGifs(String query, String? cursor);

  Future<Result<CommentPage>> getComments(
    CommentTarget target,
    int targetId,
    int page,
  );

  Future<Result<ThreadComment>> postComment({
    required CommentTarget target,
    required int targetId,
    required String body,
    required bool hasSpoiler,
    int? parentId,
  });

  Future<Result<void>> deleteComment(int commentId);
}

/// Watch endpoints of the v1 API (`/api/v1`). See the backend README.
class WatchLogsRemoteDataSourceImpl implements WatchLogsRemoteDataSource {
  static const _base = '/api/v1';
  static const _pageSize = 20;

  final HttpClient _httpClient;

  WatchLogsRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Result<MovieUserState>> getMovieState(int movieId) async => _map(
    await _httpClient.get<Map<String, dynamic>>('$_base/movies/$movieId/me'),
    RemoteWatchLogs.userState,
  );

  @override
  Future<Result<WatchLog>> logSession(int movieId, WatchLogDraft draft) async =>
      _map(
        await _httpClient.post<Map<String, dynamic>>(
          '$_base/movies/$movieId/logs',
          body: RemoteWatchLogs.draftBody(draft),
        ),
        RemoteWatchLogs.watchLog,
      );

  @override
  Future<Result<WatchLog>> logSessionByTmdbId(
    int tmdbId,
    String title,
    WatchLogDraft draft,
  ) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      '$_base/movies/tmdb/$tmdbId/logs',
      body: {'title': title, 'log': RemoteWatchLogs.draftBody(draft)},
    ),
    RemoteWatchLogs.watchLog,
  );

  @override
  Future<Result<MovieLogHistory>> getMovieLogs({
    required int movieId,
    String? userId,
    required int page,
  }) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/movies/$movieId/logs',
      queryParams: {'userId': ?userId, 'page': page, 'limit': _pageSize},
    ),
    RemoteWatchLogs.history,
  );

  @override
  Future<Result<DiaryPage>> getUserDiary({
    required String userId,
    required int page,
  }) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/users/$userId/logs',
      queryParams: {'page': page, 'limit': _pageSize},
    ),
    RemoteWatchLogs.diary,
  );

  @override
  Future<Result<WatchLog>> updateLog(int logId, WatchLogDraft draft) async =>
      _map(
        await _httpClient.put<Map<String, dynamic>>(
          '$_base/logs/$logId',
          body: RemoteWatchLogs.draftBody(draft),
        ),
        RemoteWatchLogs.watchLog,
      );

  @override
  Future<Result<void>> deleteLog(int logId) async =>
      _ignoreBody(await _httpClient.delete<dynamic>('$_base/logs/$logId'));

  @override
  Future<Result<WatchProgress>> startRewatch(int movieId) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      '$_base/movies/$movieId/rewatch',
    ),
    RemoteWatchLogs.progress,
  );

  @override
  Future<Result<MovieRating>> rate(int movieId, RatingDraft draft) async =>
      _map(
        await _httpClient.put<Map<String, dynamic>>(
          '$_base/movies/$movieId/rating',
          body: RemoteWatchLogs.ratingBody(draft),
        ),
        RemoteWatchLogs.rating,
      );

  @override
  Future<Result<void>> removeRating(int movieId) async => _ignoreBody(
    await _httpClient.delete<dynamic>('$_base/movies/$movieId/rating'),
  );

  @override
  Future<Result<void>> setWatchingNow(int? movieId) async => _ignoreBody(
    await _httpClient.put<dynamic>(
      '$_base/users/me/watching-now',
      body: {'movieId': movieId},
    ),
  );

  @override
  Future<Result<WatchingNow?>> getWatchingNow(String userId) async {
    // 204 (nothing being watched) comes without a body.
    final result = await _httpClient.get<dynamic>(
      '$_base/users/$userId/watching-now',
    );
    return switch (result) {
      Success(:final data) => Success(
        data is Map<String, dynamic> ? RemoteWatchLogs.watchingNow(data) : null,
      ),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<Emotion>>> getRecentEmotions() async =>
      switch (await _httpClient.get<List<dynamic>>(
        '$_base/users/me/emotions/recent',
      )) {
        Success(:final data) => Success(RemoteWatchLogs.emotions(data)),
        Failure(:final error) => Failure(error),
      };

  @override
  Future<Result<List<Gif>>> getRecentGifs() async => switch (await _httpClient
      .get<List<dynamic>>('$_base/users/me/gifs/recent')) {
    Success(:final data) => Success(
      data.cast<Map<String, dynamic>>().map(RemoteWatchLogs.gif).toList(),
    ),
    Failure(:final error) => Failure(error),
  };

  @override
  Future<Result<GifPage>> searchGifs(String query, String? cursor) async =>
      _map(
        await _httpClient.get<Map<String, dynamic>>(
          '$_base/gifs/search',
          queryParams: {'q': query, 'cursor': ?cursor},
        ),
        RemoteWatchLogs.gifPage,
      );

  @override
  Future<Result<CommentPage>> getComments(
    CommentTarget target,
    int targetId,
    int page,
  ) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/comments',
      queryParams: {
        'targetType': target.wireValue,
        'targetId': targetId,
        'page': page,
        'limit': _pageSize,
      },
    ),
    RemoteWatchLogs.commentPage,
  );

  @override
  Future<Result<ThreadComment>> postComment({
    required CommentTarget target,
    required int targetId,
    required String body,
    required bool hasSpoiler,
    int? parentId,
  }) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      '$_base/comments',
      body: {
        'targetType': target.wireValue,
        'targetId': targetId,
        'parentId': ?parentId,
        'body': body,
        'hasSpoiler': hasSpoiler,
      },
    ),
    RemoteWatchLogs.comment,
  );

  @override
  Future<Result<void>> deleteComment(int commentId) async => _ignoreBody(
    await _httpClient.delete<dynamic>('$_base/comments/$commentId'),
  );

  Result<T> _map<T>(
    Result<Map<String, dynamic>> result,
    T Function(Map<String, dynamic>) fromJson,
  ) => switch (result) {
    Success(:final data) => Success(fromJson(data)),
    Failure(:final error) => Failure(error),
  };

  Result<void> _ignoreBody(Result<dynamic> result) => switch (result) {
    Success() => const Success(null),
    Failure(:final error) => Failure(error),
  };
}
