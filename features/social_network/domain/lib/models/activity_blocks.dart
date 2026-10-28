import 'package:core/core.dart';

/// The movie of an activity. [id] is the database id the movie detail opens.
class ActivityMovie {
  final int id;
  final int? tmdbId;
  final String title;
  final String? posterPath;

  const ActivityMovie({
    required this.id,
    this.tmdbId,
    required this.title,
    this.posterPath,
  });
}

/// The watch session of an activity, as it was logged.
class ActivityLog {
  final int id;
  final DateTime? watchedOn;
  final int cycle;
  final WatchMode mode;
  final int? minutes;
  final int? percent;
  final bool completed;
  final WatchVenue? venue;
  final String? providerName;
  final List<Emotion> emotions;
  final String? gifUrl;
  final String? comment;
  final bool hasSpoiler;

  const ActivityLog({
    required this.id,
    this.watchedOn,
    this.cycle = 1,
    this.mode = WatchMode.watched,
    this.minutes,
    this.percent,
    this.completed = false,
    this.venue,
    this.providerName,
    this.emotions = const [],
    this.gifUrl,
    this.comment,
    this.hasSpoiler = false,
  });

  /// A rewatch: any cycle after the first.
  bool get isRewatch => cycle > 1;
}

/// The rating label of an activity; null for a label this app version does not know.
class ActivityRating {
  final int id;
  final Rating? rating;
  final String? review;
  final bool hasSpoiler;

  const ActivityRating({
    required this.id,
    this.rating,
    this.review,
    this.hasSpoiler = false,
  });
}

class ActivityShelf {
  final int id;
  final String name;
  final String? color;
  final int totalMovies;
  final List<String> posterPaths;

  const ActivityShelf({
    required this.id,
    required this.name,
    this.color,
    this.totalMovies = 0,
    this.posterPaths = const [],
  });
}

class ActivityLocadora {
  final int id;
  final String name;
  final int totalShelves;
  final int totalMovies;
  final List<String> posterPaths;

  const ActivityLocadora({
    required this.id,
    required this.name,
    this.totalShelves = 0,
    this.totalMovies = 0,
    this.posterPaths = const [],
  });
}

/// The maratona of a maratona activity (phase 7). [slug] opens its detail.
class ActivityMaratona {
  final int id;
  final String slug;
  final String title;
  final String? logoUrl;
  final String? accentColor;

  const ActivityMaratona({
    required this.id,
    required this.slug,
    required this.title,
    this.logoUrl,
    this.accentColor,
  });
}

/// The challenge a "concluiu desafio" completed.
class ActivityChallenge {
  final int id;
  final String description;

  const ActivityChallenge({required this.id, required this.description});
}

/// The level a "concluiu maratona" reached, with the challenges done.
class ActivityLevel {
  final int id;
  final String name;
  final int completed;
  final int total;

  const ActivityLevel({
    required this.id,
    required this.name,
    this.completed = 0,
    this.total = 0,
  });
}

/// The CineClube of a CineClube activity (phase 8). [slug] opens its detail.
class ActivityCineClube {
  final int id;
  final String slug;
  final String title;
  final String? accentColor;
  final bool isCycle;

  const ActivityCineClube({
    required this.id,
    required this.slug,
    required this.title,
    this.accentColor,
    this.isCycle = false,
  });
}

/// The bichinho of a "desbloqueou bichinho" activity (phase 10).
class ActivityBichinho {
  final String slug;
  final String rarity;

  const ActivityBichinho({required this.slug, required this.rarity});
}

/// An import that finished: how many movies went to Já assisti and Quero ver.
class ActivityImport {
  final String source;
  final int watched;
  final int watchlist;

  const ActivityImport({
    required this.source,
    this.watched = 0,
    this.watchlist = 0,
  });
}
