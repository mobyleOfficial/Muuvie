import 'package:core/core.dart';
import 'package:watch_logs_domain/models/models.dart';
import 'package:watch_logs_domain/repositories/watch_logs_repository.dart';

/// The movie by database id, or by TMDB id (with its title) when it may not be saved yet.
class LogWatchSessionParams {
  final int? movieId;
  final int? tmdbId;
  final String title;
  final int? runtime;
  final WatchLogDraft draft;

  const LogWatchSessionParams({
    this.movieId,
    this.tmdbId,
    this.title = '',
    this.runtime,
    required this.draft,
  });
}

/// Registers a watch session (F2.1); a completed one moves the movie to Já assisti.
class LogWatchSession extends UseCase<LogWatchSessionParams, Result<WatchLog>> {
  final WatchLogsRepository _repository;

  LogWatchSession(this._repository);

  @override
  Future<Result<WatchLog>> call([LogWatchSessionParams? params]) async {
    final value = params!;
    if (!isValidWatchLogDraft(value.draft, value.runtime)) {
      return const Failure(AppError.badRequest);
    }
    final movieId = value.movieId;
    if (movieId != null) {
      return _repository.logSession(movieId: movieId, draft: value.draft);
    }
    final tmdbId = value.tmdbId;
    if (tmdbId == null) return const Failure(AppError.badRequest);
    return _repository.logSessionByTmdbId(
      tmdbId: tmdbId,
      title: value.title,
      draft: value.draft,
    );
  }
}

/// Mirrors the server checks: at most [Emotion.maxPerLog] emotions and no
/// minutes past the runtime.
bool isValidWatchLogDraft(WatchLogDraft draft, int? runtime) {
  if (draft.emotions.toSet().length > Emotion.maxPerLog) return false;
  final knownRuntime = runtime != null && runtime > 0 ? runtime : null;
  return switch (draft.mode) {
    WatchMode.watched => true,
    WatchMode.minutes => switch (draft.minutesWatched) {
      final minutes? =>
        minutes >= 0 && (knownRuntime == null || minutes <= knownRuntime),
      null => false,
    },
    WatchMode.percent => switch (draft.percent) {
      final percent? => percent >= 0 && percent <= 100,
      null => false,
    },
  };
}
