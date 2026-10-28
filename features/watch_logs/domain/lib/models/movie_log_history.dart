import 'package:core/core.dart';
import 'package:watch_logs_domain/models/watch_log.dart';

/// Totals of a user's sessions of one movie (F2.3).
class WatchLogSummary {
  final int totalMinutes;
  final int sessions;
  final int rewatches;
  final int currentCycle;
  final List<Emotion> topEmotions;

  const WatchLogSummary({
    required this.totalMinutes,
    required this.sessions,
    required this.rewatches,
    required this.currentCycle,
    this.topEmotions = const [],
  });
}

/// A session of the profile's Registros tab (F5.2), with its movie.
class DiaryEntry {
  final WatchLog log;

  /// Database id of the movie (opens the movie detail).
  final int movieId;
  final int? tmdbId;
  final String title;
  final String? posterPath;
  final int? year;

  const DiaryEntry({
    required this.log,
    required this.movieId,
    this.tmdbId,
    required this.title,
    this.posterPath,
    this.year,
  });
}

/// One page of a user's sessions across movies, newest first.
class DiaryPage {
  final List<DiaryEntry> entries;
  final int page;
  final int totalResults;
  final bool hasNext;

  const DiaryPage({
    required this.entries,
    required this.page,
    required this.totalResults,
    required this.hasNext,
  });
}

/// One page of a movie's history, newest first, with the summary of every visible session.
class MovieLogHistory {
  final WatchLogSummary summary;
  final List<WatchLog> logs;
  final int page;
  final int totalResults;
  final bool hasNext;

  const MovieLogHistory({
    required this.summary,
    required this.logs,
    required this.page,
    required this.totalResults,
    required this.hasNext,
  });
}
