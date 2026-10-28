import 'package:core/core.dart';
import 'package:stats_domain/models/models.dart';

/// JSON of the v1 chart, retrospective and goal endpoints (backend README,
/// "Charts, retrospective and yearly goals") to domain models.
abstract final class RemoteStats {
  static List<int> years(Map<String, dynamic> json) =>
      (json['years'] as List? ?? const [])
          .whereType<num>()
          .map((y) => y.toInt())
          .toList();

  static YearStats year(Map<String, dynamic> json) => YearStats(
    year: _int(json['year']),
    movies: _int(json['movies']),
    sessions: _int(json['sessions']),
    minutes: _int(json['minutes']),
    rewatches: _int(json['rewatches']),
    months: _list(json['months']).map(month).toList(),
    genres: _buckets(json['genres']),
    decades: _buckets(json['decades']),
    countries: _buckets(json['countries']),
    languages: _buckets(json['languages']),
    venues: _buckets(json['venues']),
    directors: _buckets(json['directors']),
    emotions: _buckets(json['emotions']),
    ratings: _buckets(json['ratings']),
  );

  static MonthStat month(Map<String, dynamic> json) => MonthStat(
    month: _int(json['month'], 1),
    movies: _int(json['movies']),
    minutes: _int(json['minutes']),
    sessions: _int(json['sessions']),
  );

  static List<CalendarDay> calendar(List<dynamic> json) => json
      .whereType<Map<String, dynamic>>()
      .map(
        (day) => CalendarDay(
          date: _date(day['date']) ?? DateTime(0),
          sessions: _int(day['sessions']),
          minutes: _int(day['minutes']),
        ),
      )
      .toList();

  static List<RetrospectiveYear> retrospectiveYears(List<dynamic> json) => json
      .whereType<Map<String, dynamic>>()
      .map(
        (year) => RetrospectiveYear(
          year: _int(year['year']),
          movies: _int(year['movies']),
        ),
      )
      .toList();

  static Retrospective retrospective(Map<String, dynamic> json) {
    final favorite = json['favorite'];
    final bestMonth = json['bestMonth'];
    final goal = json['goal'];
    return Retrospective(
      year: _int(json['year']),
      movies: _int(json['movies']),
      sessions: _int(json['sessions']),
      minutes: _int(json['minutes']),
      rewatches: _int(json['rewatches']),
      topGenres: _buckets(json['topGenres']),
      topDirectors: _people(json['topDirectors']),
      topActors: _people(json['topActors']),
      emotion: json['emotion'] as String?,
      favorite: favorite is Map<String, dynamic>
          ? RetrospectiveMovie(
              movieId: _int(favorite['movieId']),
              title: favorite['title'] as String? ?? '',
              posterPath: favorite['posterPath'] as String?,
              year: favorite['year'] as int?,
            )
          : null,
      favoriteRating: Rating.fromWireValue(json['favoriteRating'] as String?),
      maratonasFinished: _int(json['maratonasFinished']),
      cineclubes: _int(json['cineclubes']),
      bestMonth: bestMonth is Map<String, dynamic> ? month(bestMonth) : null,
      goal: goal is Map<String, dynamic> ? RemoteStats.goal(goal) : null,
    );
  }

  static YearlyGoal goal(Map<String, dynamic> json) => YearlyGoal(
    year: _int(json['year']),
    targetMovies: _int(json['targetMovies']),
    watched: _int(json['watched']),
  );

  static List<StatBucket> _buckets(Object? json) => _list(json)
      .map(
        (bucket) => StatBucket(
          key: '${bucket['key'] ?? ''}',
          label: bucket['label'] as String?,
          movies: _int(bucket['movies']),
          minutes: _int(bucket['minutes']),
        ),
      )
      .toList();

  static List<TopPerson> _people(Object? json) => _list(json)
      .map(
        (person) => TopPerson(
          tmdbId: _int(person['tmdbId']),
          name: person['name'] as String? ?? '',
          profilePath: person['profilePath'] as String?,
          movies: _int(person['movies']),
        ),
      )
      .toList();

  static List<Map<String, dynamic>> _list(Object? value) => value is List
      ? value.whereType<Map<String, dynamic>>().toList()
      : const [];

  static int _int(Object? value, [int fallback = 0]) =>
      value is num ? value.toInt() : fallback;

  static DateTime? _date(Object? value) {
    if (value is! String) return null;
    final parsed = DateTime.tryParse(value);
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }
}
