import 'package:core/core.dart';
import 'package:watch_logs_domain/models/models.dart';
import 'package:watch_logs_domain/repositories/watch_logs_repository.dart';

class GetMovieLogsParams {
  final int movieId;

  /// Null for the current user.
  final String? userId;
  final int page;

  const GetMovieLogsParams({required this.movieId, this.userId, this.page = 1});
}

/// A movie's sessions with their summary (F2.3).
class GetMovieLogs
    extends UseCase<GetMovieLogsParams, Result<MovieLogHistory>> {
  final WatchLogsRepository _repository;

  GetMovieLogs(this._repository);

  @override
  Future<Result<MovieLogHistory>> call([GetMovieLogsParams? params]) {
    final value = params!;
    return _repository.getMovieLogs(
      movieId: value.movieId,
      userId: value.userId,
      page: value.page,
    );
  }
}

class GetUserDiaryParams {
  /// The owner, or `me` for the current user.
  final String userId;
  final int page;

  const GetUserDiaryParams({this.userId = 'me', this.page = 1});
}

/// Every session of a user across movies, newest first (Registros, F5.2).
class GetUserDiary extends UseCase<GetUserDiaryParams, Result<DiaryPage>> {
  final WatchLogsRepository _repository;

  GetUserDiary(this._repository);

  @override
  Future<Result<DiaryPage>> call([GetUserDiaryParams? params]) {
    final value = params ?? const GetUserDiaryParams();
    return _repository.getUserDiary(userId: value.userId, page: value.page);
  }
}

/// "Assistir de novo" (F2.5): opens a new cycle. Fails with conflict while
/// the current one is unfinished.
class StartRewatch extends UseCase<int, Result<WatchProgress>> {
  final WatchLogsRepository _repository;

  StartRewatch(this._repository);

  @override
  Future<Result<WatchProgress>> call([int? movieId]) =>
      _repository.startRewatch(movieId!);
}
