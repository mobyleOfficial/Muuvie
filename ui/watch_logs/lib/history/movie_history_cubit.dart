import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watch_logs/watch_logs.dart';

sealed class MovieHistoryState {
  const MovieHistoryState();
}

class MovieHistoryLoading extends MovieHistoryState {
  const MovieHistoryLoading();
}

class MovieHistoryError extends MovieHistoryState {
  final String message;

  const MovieHistoryError(this.message);
}

class MovieHistorySuccess extends MovieHistoryState {
  final WatchLogSummary summary;
  final List<WatchLog> logs;
  final int page;
  final bool hasNext;

  const MovieHistorySuccess({
    required this.summary,
    required this.logs,
    required this.page,
    required this.hasNext,
  });
}

/// A movie's sessions, newest first, with the summary (F2.3).
class MovieHistoryCubit extends Cubit<MovieHistoryState> {
  final int movieId;
  final String? userId;
  final GetMovieLogs _getMovieLogs;
  final DeleteWatchLog _deleteWatchLog;
  bool _loadingMore = false;

  MovieHistoryCubit({
    required this.movieId,
    this.userId,
    required GetMovieLogs getMovieLogs,
    required DeleteWatchLog deleteWatchLog,
  }) : _getMovieLogs = getMovieLogs,
       _deleteWatchLog = deleteWatchLog,
       super(const MovieHistoryLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const MovieHistoryLoading());
    final result = await _getMovieLogs(
      GetMovieLogsParams(movieId: movieId, userId: userId),
    );
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => MovieHistorySuccess(
        summary: data.summary,
        logs: data.logs,
        page: data.page,
        hasNext: data.hasNext,
      ),
      Failure(:final error) => MovieHistoryError(error.message),
    });
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! MovieHistorySuccess || !current.hasNext || _loadingMore) {
      return;
    }
    _loadingMore = true;
    final result = await _getMovieLogs(
      GetMovieLogsParams(
        movieId: movieId,
        userId: userId,
        page: current.page + 1,
      ),
    );
    _loadingMore = false;
    if (isClosed) return;
    if (result case Success(:final data)) {
      emit(
        MovieHistorySuccess(
          summary: data.summary,
          logs: [...current.logs, ...data.logs],
          page: data.page,
          hasNext: data.hasNext,
        ),
      );
    }
  }

  /// Deletes the session and reloads, since the summary and progress change.
  Future<bool> delete(int logId) async {
    final result = await _deleteWatchLog(logId);
    if (isClosed || result is Failure) return false;
    await load();
    return true;
  }
}
