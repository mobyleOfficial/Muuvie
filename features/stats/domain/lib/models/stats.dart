import 'package:core/core.dart';

/// One slice of a breakdown. [key] is stable (a TMDB id, "1970", "BR",
/// "cinema", an emotion or a rating label); [label] is for display when the
/// server has one (genre and director names).
class StatBucket {
  final String key;
  final String? label;
  final int movies;
  final int minutes;

  const StatBucket({
    required this.key,
    this.label,
    required this.movies,
    this.minutes = 0,
  });
}

class MonthStat {
  final int month;
  final int movies;
  final int minutes;
  final int sessions;

  const MonthStat({
    required this.month,
    this.movies = 0,
    this.minutes = 0,
    this.sessions = 0,
  });
}

/// A year of sessions as the viewer can see them (F9.1).
class YearStats {
  final int year;
  final int movies;
  final int sessions;
  final int minutes;
  final int rewatches;
  final List<MonthStat> months;
  final List<StatBucket> genres;
  final List<StatBucket> decades;
  final List<StatBucket> countries;
  final List<StatBucket> languages;
  final List<StatBucket> venues;
  final List<StatBucket> directors;
  final List<StatBucket> emotions;

  /// Finished movies by rating label, in the order of the labels (B13.4).
  final List<StatBucket> ratings;

  const YearStats({
    required this.year,
    this.movies = 0,
    this.sessions = 0,
    this.minutes = 0,
    this.rewatches = 0,
    this.months = const [],
    this.genres = const [],
    this.decades = const [],
    this.countries = const [],
    this.languages = const [],
    this.venues = const [],
    this.directors = const [],
    this.emotions = const [],
    this.ratings = const [],
  });

  bool get isEmpty => sessions == 0;
}

/// A day of the calendar heatmap.
class CalendarDay {
  final DateTime date;
  final int sessions;
  final int minutes;

  const CalendarDay({
    required this.date,
    required this.sessions,
    this.minutes = 0,
  });
}

class TopPerson {
  final int tmdbId;
  final String name;
  final String? profilePath;
  final int movies;

  const TopPerson({
    required this.tmdbId,
    required this.name,
    this.profilePath,
    required this.movies,
  });
}

class RetrospectiveMovie {
  final int movieId;
  final String title;
  final String? posterPath;
  final int? year;

  const RetrospectiveMovie({
    required this.movieId,
    required this.title,
    this.posterPath,
    this.year,
  });
}

/// "Assistir 100 filmes em 2027" (F9.4), with the movies finished so far.
class YearlyGoal {
  final int year;
  final int targetMovies;
  final int watched;

  const YearlyGoal({
    required this.year,
    required this.targetMovies,
    required this.watched,
  });

  double get progress =>
      targetMovies <= 0 ? 0 : (watched / targetMovies).clamp(0, 1).toDouble();

  bool get reached => watched >= targetMovies;
}

class RetrospectiveYear {
  final int year;
  final int movies;

  const RetrospectiveYear({required this.year, required this.movies});
}

/// The year in stories (F9.3).
class Retrospective {
  final int year;
  final int movies;
  final int sessions;
  final int minutes;
  final int rewatches;
  final List<StatBucket> topGenres;
  final List<TopPerson> topDirectors;
  final List<TopPerson> topActors;

  /// The wire value of the emotion of the year.
  final String? emotion;
  final RetrospectiveMovie? favorite;
  final Rating? favoriteRating;
  final int maratonasFinished;
  final int cineclubes;
  final MonthStat? bestMonth;
  final YearlyGoal? goal;

  const Retrospective({
    required this.year,
    this.movies = 0,
    this.sessions = 0,
    this.minutes = 0,
    this.rewatches = 0,
    this.topGenres = const [],
    this.topDirectors = const [],
    this.topActors = const [],
    this.emotion,
    this.favorite,
    this.favoriteRating,
    this.maratonasFinished = 0,
    this.cineclubes = 0,
    this.bestMonth,
    this.goal,
  });
}
