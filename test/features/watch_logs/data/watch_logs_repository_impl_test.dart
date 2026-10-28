import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watch_logs/watch_logs.dart';

class _Call {
  final String method;
  final String path;
  final Map<String, dynamic>? query;
  final Object? body;

  const _Call(this.method, this.path, this.query, this.body);
}

/// Records every request and answers with [response].
class _FakeHttpClient implements HttpClient {
  final calls = <_Call>[];
  Result<dynamic> response = const Success(null);

  Future<Result<T>> _record<T>(
    String method,
    String path,
    Map<String, dynamic>? query,
    Object? body,
  ) async {
    calls.add(_Call(method, path, query, body));
    return switch (response) {
      Success(:final data) => Success(data as T),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<T>> get<T>(String path, {Map<String, dynamic>? queryParams}) =>
      _record('GET', path, queryParams, null);

  @override
  Future<Result<T>> post<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  }) => _record('POST', path, queryParams, body);

  @override
  Future<Result<T>> put<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  }) => _record('PUT', path, queryParams, body);

  @override
  Future<Result<T>> patch<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Object? body,
  }) => _record('PATCH', path, queryParams, body);

  @override
  Future<Result<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParams,
  }) => _record('DELETE', path, queryParams, null);
}

const _logJson = {
  'id': 5,
  'userId': 'ana',
  'movieId': 10,
  'watchedOn': '2026-10-01',
  'cycle': 2,
  'mode': 'minutes',
  'minutesWatched': 40,
  'percent': 33,
  'completed': false,
  'venue': 'cinema',
  'providerName': 'Cine Belas Artes',
  'emotions': ['joy', 'unknown_one', 'fear'],
  'gif': {'id': 'g1', 'url': 'https://media.tenor.com/g1.gif'},
  'comment': 'Bom',
  'hasSpoiler': true,
  'visibility': 'mutual',
  'createdAt': '2026-10-01T20:00:00Z',
  'updatedAt': '2026-10-01T20:00:00Z',
  'self': true,
};

void main() {
  late _FakeHttpClient http;
  late WatchLogsRepositoryImpl repository;

  setUp(() {
    http = _FakeHttpClient();
    repository = WatchLogsRepositoryImpl(WatchLogsRemoteDataSourceImpl(http));
  });

  test('logging a session posts the form and parses the log', () async {
    http.response = const Success(_logJson);

    final result = await repository.logSession(
      movieId: 10,
      draft: WatchLogDraft(
        watchedOn: DateTime(2026, 10, 1),
        mode: WatchMode.minutes,
        minutesWatched: 40,
        venue: WatchVenue.cinema,
        emotions: const [Emotion.joy, Emotion.fear],
        gif: const Gif(id: 'g1', url: 'https://media.tenor.com/g1.gif'),
        visibility: ContentVisibility.mutual,
      ),
    );

    final call = http.calls.single;
    expect(call.method, 'POST');
    expect(call.path, '/api/v1/movies/10/logs');
    final body = call.body as Map<String, dynamic>;
    expect(body['watchedOn'], '2026-10-01');
    expect(body['mode'], 'minutes');
    expect(body['minutesWatched'], 40);
    expect(body.containsKey('percent'), isFalse);
    expect(body['emotions'], ['joy', 'fear']);
    expect(body['gif'], {'id': 'g1', 'url': 'https://media.tenor.com/g1.gif'});
    expect(body['visibility'], 'mutual');

    final log = (result as Success<WatchLog>).data;
    expect(log.cycle, 2);
    expect(log.venue, WatchVenue.cinema);
    // Unknown emotions from a newer server are skipped, not a crash.
    expect(log.emotions, [Emotion.joy, Emotion.fear]);
    expect(log.gif?.id, 'g1');
    expect(log.visibility, ContentVisibility.mutual);
    expect(log.self, isTrue);
  });

  test('the one-tap Ja assisti sends only the date and the defaults', () async {
    http.response = const Success(_logJson);

    await repository.logSessionByTmdbId(
      tmdbId: 603,
      title: 'Matrix',
      draft: WatchLogDraft.watchedOn(DateTime(2026, 10, 26)),
    );

    final call = http.calls.single;
    expect(call.path, '/api/v1/movies/tmdb/603/logs');
    final body = call.body as Map<String, dynamic>;
    expect(body['title'], 'Matrix');
    expect((body['log'] as Map)['mode'], 'watched');
    expect((body['log'] as Map)['watchedOn'], '2026-10-26');
  });

  test('history parses the summary and the page', () async {
    http.response = const Success({
      'summary': {
        'totalMinutes': 140,
        'sessions': 2,
        'rewatches': 1,
        'currentCycle': 2,
        'topEmotions': ['joy'],
      },
      'logs': {
        'results': [_logJson],
        'page': 1,
        'totalPages': 1,
        'totalResults': 1,
        'hasNext': false,
      },
    });

    final result = await repository.getMovieLogs(movieId: 10, page: 1);

    expect(http.calls.single.path, '/api/v1/movies/10/logs');
    expect(http.calls.single.query, {'page': 1, 'limit': 20});
    final history = (result as Success<MovieLogHistory>).data;
    expect(history.summary.totalMinutes, 140);
    expect(history.summary.rewatches, 1);
    expect(history.summary.topEmotions, [Emotion.joy]);
    expect(history.logs.single.id, 5);
    expect(history.hasNext, isFalse);
  });

  test('movie state parses shelves, progress, rating and situation', () async {
    http.response = const Success({
      'shelfIds': [1, 7],
      'status': 'watched',
      'progress': {
        'cycle': 1,
        'minutes': 30,
        'percent': 25,
        'completed': false,
      },
      'rating': {
        'id': 3,
        'rating': 'liked',
        'review': null,
        'hasSpoiler': false,
      },
      'rewatches': 0,
      'watchingNow': true,
    });

    final state =
        (await repository.getMovieState(10) as Success<MovieUserState>).data;

    expect(http.calls.single.path, '/api/v1/movies/10/me');
    expect(state.shelfIds, {1, 7});
    expect(state.status, WatchStatus.watched);
    expect(state.progress?.percent, 25);
    expect(state.rating?.rating, Rating.liked);
    expect(state.watchingNow, isTrue);
    expect(state.canRewatch, isFalse);
  });

  test('rating sends the label and the 100% session fields', () async {
    http.response = const Success({
      'id': 3,
      'rating': 'favorite',
      'hasSpoiler': false,
    });
    final rating = await repository.rate(
      10,
      const RatingDraft(
        rating: Rating.favorite,
        emotions: [Emotion.joy],
        createLog: true,
        visibility: ContentVisibility.mutual,
      ),
    );
    expect((rating as Success<MovieRating>).data.rating, Rating.favorite);
    expect(http.calls.last.method, 'PUT');
    expect(http.calls.last.path, '/api/v1/movies/10/rating');
    expect(http.calls.last.body, {
      'rating': 'favorite',
      'hasSpoiler': false,
      'emotions': ['joy'],
      'createLog': true,
      'visibility': 'mutual',
    });
  });

  test('watching now is null on 204 and parsed otherwise', () async {
    http.response = const Success('');
    expect((await repository.getWatchingNow('me') as Success).data, isNull);

    http.response = const Success({
      'movieId': 10,
      'title': 'Casablanca',
      'runtime': 102,
      'progress': {
        'cycle': 1,
        'minutes': 51,
        'percent': 50,
        'completed': false,
      },
    });
    final movie =
        (await repository.getWatchingNow('me') as Success<WatchingNow?>).data!;
    expect(http.calls.last.path, '/api/v1/users/me/watching-now');
    expect(movie.title, 'Casablanca');
    expect(movie.progress?.minutes, 51);
  });

  test('comments target the session or the rating', () async {
    http.response = const Success({
      'results': [
        {
          'id': 1,
          'targetType': 'watch_log',
          'targetId': 5,
          'parentId': null,
          'author': {'id': 'bia', 'username': 'bia', 'avatarUrl': null},
          'body': 'Que filme',
          'hasSpoiler': false,
          'createdAt': '2026-10-01T20:00:00Z',
          'self': false,
        },
      ],
      'page': 1,
      'totalPages': 1,
      'totalResults': 1,
      'hasNext': false,
    });

    final page = await repository.getComments(
      target: CommentTarget.watchLog,
      targetId: 5,
      page: 1,
    );

    expect(http.calls.single.query?['targetType'], 'watch_log');
    expect(http.calls.single.query?['targetId'], 5);
    expect(
      (page as Success<CommentPage>).data.comments.single.authorName,
      'bia',
    );
  });

  test('failures pass through', () async {
    http.response = const Failure(AppError.conflict);

    final result = await repository.startRewatch(10);

    expect(http.calls.single.path, '/api/v1/movies/10/rewatch');
    expect((result as Failure).error, AppError.conflict);
  });
}
