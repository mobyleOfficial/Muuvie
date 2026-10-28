import 'package:core/core.dart';

/// Progress of the current cycle (rewatch).
class WatchProgress {
  final int cycle;
  final int? minutes;
  final int? percent;
  final bool completed;

  const WatchProgress({
    required this.cycle,
    this.minutes,
    this.percent,
    required this.completed,
  });
}

/// The rating label with its review (phase 13). [id] is the comment target.
class MovieRating {
  final int id;
  final Rating rating;
  final String? review;
  final bool hasSpoiler;

  const MovieRating({
    required this.id,
    required this.rating,
    this.review,
    this.hasSpoiler = false,
  });
}

/// Fields of the rating form. [emotions] and [visibility] go to the 100%
/// session created with [createLog], which only a verdict can create.
class RatingDraft {
  final Rating rating;
  final String? review;
  final bool hasSpoiler;
  final List<Emotion> emotions;
  final bool createLog;
  final ContentVisibility visibility;

  const RatingDraft({
    required this.rating,
    this.review,
    this.hasSpoiler = false,
    this.emotions = const [],
    this.createLog = false,
    this.visibility = ContentVisibility.public,
  });
}

/// What the current user has for a movie: shelves, situation, progress and rating.
class MovieUserState {
  final Set<int> shelfIds;
  final WatchStatus? status;
  final WatchProgress? progress;
  final MovieRating? rating;
  final int rewatches;
  final bool watchingNow;

  const MovieUserState({
    this.shelfIds = const {},
    this.status,
    this.progress,
    this.rating,
    this.rewatches = 0,
    this.watchingNow = false,
  });

  bool get isWatched => status == WatchStatus.watched;

  /// "Assistir de novo" is only offered once the current cycle is done (F2.5).
  bool get canRewatch => progress?.completed ?? false;

  MovieUserState copyWith({
    WatchStatus? Function()? status,
    MovieRating? Function()? rating,
    bool? watchingNow,
  }) => MovieUserState(
    shelfIds: shelfIds,
    status: status != null ? status() : this.status,
    progress: progress,
    rating: rating != null ? rating() : this.rating,
    rewatches: rewatches,
    watchingNow: watchingNow ?? this.watchingNow,
  );
}

/// The movie a user is watching now, for the profile header (F2.6).
class WatchingNow {
  final int movieId;
  final int? tmdbId;
  final String title;
  final String? posterPath;
  final int? runtime;
  final WatchProgress? progress;

  const WatchingNow({
    required this.movieId,
    this.tmdbId,
    required this.title,
    this.posterPath,
    this.runtime,
    this.progress,
  });
}
