import 'package:core/core.dart';
import 'package:movies_domain/models/models.dart';

/// `GET /api/v1/movies/{id}/community`, `/events` (F12.1), `/cineclubes`,
/// `/maratonas` and `/timeline` (B13.5). All are public.
class MovieCommunityRemoteDataSource {
  static const _pageSize = 20;

  final HttpClient _httpClient;

  MovieCommunityRemoteDataSource(this._httpClient);

  Future<Result<MovieCommunity>> getCommunity(int movieId) =>
      _get('/api/v1/movies/$movieId/community', community);

  Future<Result<MovieEvents>> getEvents(int movieId) =>
      _get('/api/v1/movies/$movieId/events', events);

  Future<Result<MovieEventPage>> getCineClubes(int movieId, {int page = 1}) =>
      _get(
        '/api/v1/movies/$movieId/cineclubes',
        eventPage,
        queryParams: {'page': page, 'limit': _pageSize},
      );

  Future<Result<MovieEventPage>> getMaratonas(int movieId, {int page = 1}) =>
      _get(
        '/api/v1/movies/$movieId/maratonas',
        eventPage,
        queryParams: {'page': page, 'limit': _pageSize},
      );

  Future<Result<MovieTimeline>> getTimeline(int movieId, {int months = 12}) =>
      _get(
        '/api/v1/movies/$movieId/timeline',
        timeline,
        queryParams: {'months': months},
      );

  Future<Result<T>> _get<T>(
    String path,
    T Function(Map<String, dynamic>) parse, {
    Map<String, dynamic>? queryParams,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      path,
      queryParams: queryParams,
    );
    return switch (result) {
      Success(:final data) => Success(parse(data)),
      Failure(:final error) => Failure(error),
    };
  }

  static MovieCommunity community(Map<String, dynamic> json) => MovieCommunity(
    ratings: {
      for (final entry
          in (json['ratings'] as Map<String, dynamic>? ?? const {}).entries)
        ?Rating.fromWireValue(entry.key): (entry.value as num).toInt(),
    },
    watched: (json['watched'] as num?)?.toInt() ?? 0,
    wantToWatch: (json['wantToWatch'] as num?)?.toInt() ?? 0,
    shelves: (json['shelves'] as num?)?.toInt() ?? 0,
    emotions: [
      for (final item in _list(json['emotions']))
        if (Emotion.fromWireValue(item['emotion'] as String?)
            case final emotion?)
          EmotionCount(
            emotion: emotion,
            count: (item['count'] as num?)?.toInt() ?? 0,
          ),
    ],
  );

  static MovieEvents events(Map<String, dynamic> json) => MovieEvents(
    maratonas: [
      for (final item in _list(json['maratonas']))
        _event(
          item['maratona'] as Map<String, dynamic>,
          challenges: (item['challenges'] as List<dynamic>? ?? const [])
              .cast<String>(),
        ),
    ],
    cineclubes: [for (final item in _list(json['cineclubes'])) _event(item)],
  );

  /// A `Page` of maratona or CineClube summaries.
  static MovieEventPage eventPage(Map<String, dynamic> json) => MovieEventPage(
    items: [for (final item in _list(json['results'])) _event(item)],
    page: (json['page'] as num?)?.toInt() ?? 1,
    totalResults: (json['totalResults'] as num?)?.toInt() ?? 0,
    hasNext: json['hasNext'] as bool? ?? false,
  );

  static MovieTimeline timeline(Map<String, dynamic> json) => MovieTimeline(
    months: [
      for (final item in _list(json['months']))
        MonthActivity(
          // "YYYY-MM".
          month: DateTime.parse('${item['month'] as String}-01'),
          sessions: (item['sessions'] as num?)?.toInt() ?? 0,
          ratings: (item['ratings'] as num?)?.toInt() ?? 0,
        ),
    ],
  );

  static List<Map<String, dynamic>> _list(dynamic raw) =>
      (raw as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();

  static MovieEvent _event(
    Map<String, dynamic> json, {
    List<String> challenges = const [],
  }) => MovieEvent(
    slug: json['slug'] as String,
    title: json['title'] as String? ?? '',
    accentColor: json['accentColor'] as String?,
    status: json['status'] as String? ?? 'active',
    startsOn: DateTime.parse(json['startsOn'] as String),
    endsOn: DateTime.parse(json['endsOn'] as String),
    participants: (json['totalParticipants'] as num?)?.toInt() ?? 0,
    joined: json['joined'] as bool? ?? false,
    challenges: challenges,
  );
}
