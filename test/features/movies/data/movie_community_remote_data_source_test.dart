import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/movies.dart';

import '../../../helpers/fake_http_client.dart';

const _owner = {'id': 'ana-id', 'username': 'ana', 'displayName': 'Ana'};

/// GET /movies/{id}/events (F12.1): a MaratonaSummary with the challenges,
/// and a CineClubeSummary.
const _events = {
  'maratonas': [
    {
      'maratona': {
        'id': 1,
        'slug': 'halloween',
        'title': 'Halloween',
        'logoUrl': null,
        'accentColor': '#E65100',
        'startsOn': '2026-10-01',
        'endsOn': '2026-10-31',
        'status': 'active',
        'hasPassword': false,
        'trusted': true,
        'owner': _owner,
        'totalChallenges': 5,
        'totalParticipants': 12,
        'joined': true,
      },
      'challenges': ['Um terror italiano', 'Um filme dos anos 70'],
    },
  ],
  'cineclubes': [
    {
      'id': 3,
      'slug': 'giallo',
      'title': 'Clube do giallo',
      'accentColor': null,
      'status': 'upcoming',
      'hasPassword': false,
      'isCycle': false,
      'owner': _owner,
      'movie': {'id': 7, 'title': 'Suspiria'},
      'startsOn': '2026-11-02',
      'endsOn': '2026-11-09',
      'debateOn': '2026-11-09',
      'totalSessions': 1,
      'totalParticipants': 4,
      'joined': false,
    },
  ],
};

void main() {
  late FakeHttpClient http;
  late MovieCommunityRemoteDataSource dataSource;

  setUp(() {
    http = FakeHttpClient();
    dataSource = MovieCommunityRemoteDataSource(http);
  });

  test(
    'reads the community block and skips unknown labels and emotions',
    () async {
      http.response = const Success({
        'ratings': {'favorite': 1, 'liked': 2, 'meh': 4},
        'watched': 3,
        'wantToWatch': 1,
        'shelves': 2,
        'emotions': [
          {'emotion': 'joy', 'count': 3},
          {'emotion': 'boredom_v2', 'count': 1},
        ],
      });

      final result = await dataSource.getCommunity(7);

      final community = (result as Success<MovieCommunity>).data;
      expect(http.calls.single.path, '/api/v1/movies/7/community');
      expect(community.ratings, {Rating.favorite: 1, Rating.liked: 2});
      expect(community.totalRatings, 3);
      expect(community.watched, 3);
      expect(community.shelves, 2);
      expect(community.emotions.single.emotion, Emotion.joy);
      expect(community.emotions.single.count, 3);
      expect(community.isEmpty, isFalse);
    },
  );

  test('a movie nobody touched is empty', () async {
    http.response = const Success({
      'ratings': <String, dynamic>{},
      'watched': 0,
      'wantToWatch': 0,
      'shelves': 0,
      'emotions': <dynamic>[],
    });

    final result = await dataSource.getCommunity(7);

    final community = (result as Success<MovieCommunity>).data;
    expect(community.totalRatings, 0);
    expect(community.isEmpty, isTrue);
  });

  test(
    'reads the maratonas with their challenges and the CineClubes',
    () async {
      http.response = const Success(_events);

      final result = await dataSource.getEvents(7);

      final events = (result as Success<MovieEvents>).data;
      expect(http.calls.single.path, '/api/v1/movies/7/events');
      final maratona = events.maratonas.single;
      expect(maratona.slug, 'halloween');
      expect(maratona.joined, isTrue);
      expect(maratona.participants, 12);
      expect(maratona.challenges, [
        'Um terror italiano',
        'Um filme dos anos 70',
      ]);
      final cineclube = events.cineclubes.single;
      expect(cineclube.slug, 'giallo');
      expect(cineclube.isUpcoming, isTrue);
      expect(cineclube.startsOn, DateTime(2026, 11, 2));
      expect(cineclube.challenges, isEmpty);
    },
  );

  test('reads a page of CineClubes, finished ones included', () async {
    http.response = Success({
      'results': [
        {
          ...(_events['cineclubes']! as List).single as Map<String, dynamic>,
          'status': 'finished',
        },
      ],
      'page': 2,
      'totalPages': 3,
      'totalResults': 41,
      'hasNext': true,
    });

    final result = await dataSource.getCineClubes(7, page: 2);

    final page = (result as Success<MovieEventPage>).data;
    final call = http.calls.single;
    expect(call.path, '/api/v1/movies/7/cineclubes');
    expect(call.query, {'page': 2, 'limit': 20});
    expect(page.items.single.slug, 'giallo');
    expect(page.items.single.isFinished, isTrue);
    expect(page.page, 2);
    expect(page.totalResults, 41);
    expect(page.hasNext, isTrue);
  });

  test('reads the maratonas the movie counted in', () async {
    final maratona =
        ((_events['maratonas']! as List).single as Map)['maratona'];
    http.response = Success({
      'results': [maratona],
      'page': 1,
      'totalPages': 1,
      'totalResults': 1,
      'hasNext': false,
    });

    final result = await dataSource.getMaratonas(7);

    final page = (result as Success<MovieEventPage>).data;
    expect(http.calls.single.path, '/api/v1/movies/7/maratonas');
    expect(page.items.single.title, 'Halloween');
    expect(page.hasNext, isFalse);
  });

  test('reads the timeline month by month', () async {
    http.response = const Success({
      'months': [
        {'month': '2026-09', 'sessions': 0, 'ratings': 0},
        {'month': '2026-10', 'sessions': 4, 'ratings': 2},
      ],
    });

    final result = await dataSource.getTimeline(7);

    final timeline = (result as Success<MovieTimeline>).data;
    final call = http.calls.single;
    expect(call.path, '/api/v1/movies/7/timeline');
    expect(call.query, {'months': 12});
    expect(timeline.months.last.month, DateTime(2026, 10));
    expect(timeline.months.last.sessions, 4);
    expect(timeline.months.last.ratings, 2);
    expect(timeline.isEmpty, isFalse);
  });

  test('a failure is passed on', () async {
    http.response = const Failure(AppError.network);

    expect(await dataSource.getEvents(7), isA<Failure<MovieEvents>>());
  });
}
