import 'package:cineclubes/cineclubes.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_http_client.dart';

const _owner = {'id': 'ana-id', 'username': 'ana', 'displayName': 'Ana'};

const _rashomon = {
  'id': 10,
  'tmdbId': 100,
  'title': 'Rashomon',
  'posterPath': '/r.jpg',
  'year': 1950,
  'runtime': 88,
};

/// GET /cineclubes/{slug} with a token (backend README, "CineClubes").
const _detail = {
  'id': 3,
  'slug': 'ciclo-kurosawa',
  'title': 'Ciclo Kurosawa',
  'description': 'Um filme por semana',
  'accentColor': '#E65100',
  'status': 'active',
  'hasPassword': true,
  'debateLink': 'https://meet.example/kurosawa',
  'socialLink': null,
  'isCycle': true,
  'startsOn': '2026-10-05',
  'endsOn': '2026-10-18',
  'owner': _owner,
  'sessions': [
    {
      'id': 1,
      'position': 0,
      'movie': _rashomon,
      'startsOn': '2026-10-05',
      'endsOn': '2026-10-11',
      'debateOn': '2026-10-11',
    },
    {
      'id': 2,
      'position': 1,
      'movie': {'id': 11, 'tmdbId': 101, 'title': 'Ran'},
      'startsOn': '2026-10-12',
      'endsOn': '2026-10-18',
      'debateOn': '2026-10-18',
    },
  ],
  'currentSessionId': 1,
  'totalParticipants': 4,
  'createdAt': '2026-09-20T12:00:00Z',
  'watchProviders': [
    {'name': 'Mubi', 'logoPath': '/mubi.png'},
  ],
  'me': {
    'joinedAt': '2026-10-02T10:00:00Z',
    'progress': 'watching',
    'completedSessions': 0,
  },
  'canEdit': false,
};

void main() {
  late FakeHttpClient http;
  late CineClubesRemoteDataSourceImpl dataSource;

  setUp(() {
    http = FakeHttpClient();
    dataSource = CineClubesRemoteDataSourceImpl(http);
  });

  test('the list sends the filters and reads the current movie', () async {
    http.response = const Success({
      'results': [
        {
          'id': 3,
          'slug': 'ciclo-kurosawa',
          'title': 'Ciclo Kurosawa',
          'status': 'upcoming',
          'isCycle': true,
          'owner': _owner,
          'movie': _rashomon,
          'startsOn': '2026-10-05',
          'endsOn': '2026-10-18',
          'debateOn': '2026-10-11',
          'totalSessions': 2,
          'totalParticipants': 4,
          'joined': true,
        },
      ],
      'page': 1,
      'totalPages': 2,
      'totalResults': 21,
      'hasNext': true,
    });

    final result = await dataSource.getCineClubes(
      const CineClubeFilter(query: ' kuro ', open: true, participant: 'me'),
      1,
    );

    final call = http.calls.single;
    expect(call.path, '/api/v1/cineclubes');
    expect(call.query, {
      'q': 'kuro',
      'open': true,
      'participant': 'me',
      'page': 1,
      'limit': 20,
    });
    final page = (result as Success<CineClubePage>).data;
    expect(page.hasNext, isTrue);
    final row = page.cineclubes.single;
    expect(row.status, CineClubeStatus.upcoming);
    expect(row.movie?.title, 'Rashomon');
    expect(row.debateOn, DateTime(2026, 10, 11));
    expect(row.totalSessions, 2);
    expect(row.joined, isTrue);
  });

  test(
    'the detail reads the sessions, the providers and my progress',
    () async {
      http.response = const Success(_detail);

      final result = await dataSource.getCineClube('ciclo-kurosawa');

      expect(http.calls.single.path, '/api/v1/cineclubes/ciclo-kurosawa');
      final cineclube = (result as Success<CineClube>).data;
      expect(cineclube.isCycle, isTrue);
      expect(cineclube.sessions.map((s) => s.movie.title), ['Rashomon', 'Ran']);
      expect(cineclube.currentSession?.movie.year, 1950);
      expect(cineclube.sessions.first.debateOn, DateTime(2026, 10, 11));
      expect(cineclube.watchProviders.single.name, 'Mubi');
      expect(cineclube.me?.progress, SessionProgress.watching);
      expect(cineclube.joined, isTrue);
      expect(cineclube.debateLink, 'https://meet.example/kurosawa');
    },
  );

  test('the form goes out with the movie id or the TMDB id', () async {
    http.response = const Success(_detail);
    final form = CineClubeForm(
      slug: 'ciclo-kurosawa',
      title: 'Ciclo Kurosawa',
      password: 'pipoca',
      sessions: [
        SessionForm(
          id: 1,
          movie: const CineClubeMovie(id: 10, title: 'Rashomon'),
          startsOn: DateTime(2026, 10, 5),
          endsOn: DateTime(2026, 10, 11),
          debateOn: DateTime(2026, 10, 12),
        ),
        SessionForm(
          movie: const CineClubeMovie(id: 0, tmdbId: 101, title: 'Ran'),
          startsOn: DateTime(2026, 10, 13),
          endsOn: DateTime(2026, 10, 19),
          debateOn: DateTime(2026, 10, 19),
        ),
      ],
    );

    await dataSource.create(form);

    final call = http.calls.single;
    expect(call.method, 'POST');
    expect(call.path, '/api/v1/cineclubes');
    final body = call.body as Map<String, dynamic>;
    expect(body['password'], 'pipoca');
    expect(body['sessions'], [
      {
        'id': 1,
        'movieId': 10,
        'startsOn': '2026-10-05',
        'endsOn': '2026-10-11',
        'debateOn': '2026-10-12',
      },
      {
        'tmdbId': 101,
        'title': 'Ran',
        'startsOn': '2026-10-13',
        'endsOn': '2026-10-19',
        'debateOn': '2026-10-19',
      },
    ]);
  });

  test(
    'joining sends the password and leaving deletes the participation',
    () async {
      http.response = const Success(_detail);

      await dataSource.join('ciclo-kurosawa', 'pipoca');
      http.response = const Success(null);
      final left = await dataSource.leave('ciclo-kurosawa');

      expect(
        http.calls.first.path,
        '/api/v1/cineclubes/ciclo-kurosawa/participation',
      );
      expect(http.calls.first.body, {'password': 'pipoca'});
      expect(http.calls.last.method, 'DELETE');
      expect(left, isA<Success<void>>());
    },
  );

  test('progress reads hidden logs and participants send the filter', () async {
    http.responses['/api/v1/cineclubes/ciclo-kurosawa/progress'] =
        const Success({
          'results': [
            {
              'id': 50,
              'user': {'id': 'bia-id', 'username': 'bia'},
              'sessionId': 2,
              'watchedOn': '2026-10-13',
              'mode': 'watched',
              'completed': true,
              'emotions': ['moved', 'unknown'],
              'gifUrl': null,
              'comment': null,
              'hasSpoiler': true,
              'hidden': true,
              'hiddenReason': 'spoiler',
              'createdAt': '2026-10-13T20:00:00Z',
            },
          ],
          'page': 1,
          'hasNext': false,
        });
    http.responses['/api/v1/cineclubes/ciclo-kurosawa/participants'] =
        const Success({
          'results': [
            {
              'user': {'id': 'bia-id', 'username': 'bia'},
              'progress': 'completed',
              'completedSessions': 1,
              'lastWatchedOn': '2026-10-13',
              'joinedAt': '2026-10-02T10:00:00Z',
            },
          ],
          'page': 1,
          'hasNext': false,
        });

    final progress = await dataSource.getProgress('ciclo-kurosawa', 2, 1);
    final participants = await dataSource.getParticipants(
      'ciclo-kurosawa',
      2,
      SessionProgress.completed,
      1,
    );

    final log = (progress as Success<CineClubeLogPage>).data.logs.single;
    expect(log.hidden, isTrue);
    expect(log.emotions, [Emotion.moved]);
    expect(http.calls.first.query, {'session': 2, 'page': 1, 'limit': 20});
    expect(http.calls.last.query?['status'], 'completed');
    final participant =
        (participants as Success<ParticipantPage>).data.participants.single;
    expect(participant.progress, SessionProgress.completed);
    expect(participant.lastWatchedOn, DateTime(2026, 10, 13));
  });

  test('a failure comes back as is', () async {
    http.response = const Failure(AppError.forbidden);

    final result = await dataSource.join('ciclo-kurosawa', 'errada');

    expect((result as Failure).error, AppError.forbidden);
  });
}
