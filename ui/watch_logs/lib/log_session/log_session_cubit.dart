import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watch_logs/watch_logs.dart';

import 'package:watch_logs_ui/log_session/log_session_state.dart';

/// Creates a session, or edits [existing] (F2.1, F2.3).
class LogSessionCubit extends Cubit<LogSessionState> {
  /// Minutes cap when TMDB has no runtime for the movie (same as the server).
  static const unknownRuntimeMaxMinutes = 600;

  final int? movieId;
  final int? tmdbId;
  final String movieTitle;
  final int? runtime;
  final WatchLog? existing;
  final LogWatchSession _logWatchSession;
  final UpdateWatchLog _updateWatchLog;
  final GetRecentEmotions _getRecentEmotions;

  LogSessionCubit({
    this.movieId,
    this.tmdbId,
    required this.movieTitle,
    this.runtime,
    this.existing,
    required LogWatchSession logWatchSession,
    required UpdateWatchLog updateWatchLog,
    required GetRecentEmotions getRecentEmotions,
    DateTime? today,
  }) : _logWatchSession = logWatchSession,
       _updateWatchLog = updateWatchLog,
       _getRecentEmotions = getRecentEmotions,
       super(_initialState(existing, today ?? DateTime.now())) {
    _loadRecentEmotions();
  }

  static LogSessionState _initialState(WatchLog? log, DateTime today) {
    if (log == null) {
      return LogSessionState(
        watchedOn: DateTime(today.year, today.month, today.day),
      );
    }
    return LogSessionState(
      watchedOn: log.watchedOn,
      mode: log.mode,
      minutes: log.minutesWatched ?? 0,
      percent: log.percent ?? 0,
      venue: log.venue,
      providerName: log.providerName ?? '',
      emotions: log.emotions.toSet(),
      gif: log.gif,
      comment: log.comment ?? '',
      hasSpoiler: log.hasSpoiler,
      visibility: log.visibility,
    );
  }

  int get maxMinutes =>
      (runtime ?? 0) > 0 ? runtime! : unknownRuntimeMaxMinutes;

  Future<void> _loadRecentEmotions() async {
    final result = await _getRecentEmotions();
    if (isClosed) return;
    if (result case Success(:final data)) {
      emit(state.copyWith(recentEmotions: data));
    }
  }

  void setDate(DateTime date) => emit(state.copyWith(watchedOn: date));

  void setMode(WatchMode mode) => emit(state.copyWith(mode: mode));

  void setMinutes(int minutes) =>
      emit(state.copyWith(minutes: minutes.clamp(0, maxMinutes)));

  void setPercent(int percent) =>
      emit(state.copyWith(percent: percent.clamp(0, 100)));

  /// Tapping the selected venue clears it.
  void toggleVenue(WatchVenue venue) =>
      emit(state.copyWith(venue: () => state.venue == venue ? null : venue));

  void setProviderName(String value) =>
      emit(state.copyWith(providerName: value));

  void setEmotions(Set<Emotion> emotions) =>
      emit(state.copyWith(emotions: emotions));

  void setGif(Gif? gif) => emit(state.copyWith(gif: () => gif));

  void setComment(String value) => emit(state.copyWith(comment: value));

  void setSpoiler(bool value) => emit(state.copyWith(hasSpoiler: value));

  void setVisibility(ContentVisibility value) =>
      emit(state.copyWith(visibility: value));

  /// Returns the saved session, or null when it failed.
  Future<WatchLog?> save() async {
    if (state.isSaving) return null;
    emit(state.copyWith(isSaving: true));
    final draft = state.toDraft();
    final log = existing;
    final result = log != null
        ? await _updateWatchLog(
            UpdateWatchLogParams(logId: log.id, runtime: runtime, draft: draft),
          )
        : await _logWatchSession(
            LogWatchSessionParams(
              movieId: movieId,
              tmdbId: tmdbId,
              title: movieTitle,
              runtime: runtime,
              draft: draft,
            ),
          );
    if (isClosed) return null;
    emit(state.copyWith(isSaving: false));
    return switch (result) {
      Success(:final data) => data,
      Failure() => null,
    };
  }
}
