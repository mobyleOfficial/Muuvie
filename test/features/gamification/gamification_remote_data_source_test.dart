import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamification/gamification.dart';

import '../../helpers/fake_http_client.dart';

void main() {
  late FakeHttpClient http;
  late GamificationRemoteDataSourceImpl dataSource;
  final now = DateTime.utc(2026, 10, 27, 20);

  setUp(() {
    http = FakeHttpClient();
    dataSource = GamificationRemoteDataSourceImpl(http, now: () => now);
  });

  test('the shelter reads locked and pinned bichinhos', () async {
    http.response = const Success({
      'starterChosen': true,
      'pets': [
        {
          'slug': 'pipoca-doce',
          'rarity': 'starter',
          'rule': {'type': 'starter', 'target': 0},
          'unlocked': true,
          'level': 2,
          'xp': 150,
          'levelXp': 100,
          'nextLevelXp': 300,
          'pinned': true,
        },
        {
          'slug': 'fantasminha',
          'rarity': 'common',
          'rule': {'type': 'genre_movies', 'target': 5, 'genreId': 27},
          'unlocked': false,
          'progress': 2,
        },
      ],
      'pinned': {
        'slug': 'pipoca-doce',
        'rarity': 'starter',
        'unlocked': true,
        'level': 2,
        'pinned': true,
      },
    });

    final shelter = (await dataSource.getShelter() as Success<PetShelter>).data;

    expect(http.calls.single.path, '/api/v1/users/me/pets');
    expect(shelter.pinned?.slug, 'pipoca-doce');
    expect(shelter.pets.first.levelProgress, closeTo(0.25, 0.001));
    expect(shelter.pets.last.rule.genreId, 27);
    expect(shelter.pets.last.unlockProgress, closeTo(0.4, 0.001));
  });

  test(
    'a diary day goes out with its goals and an empty day without',
    () async {
      http.response = const Success({
        'date': '2026-10-27',
        'mood': 'good',
        'tasks': [],
        'saved': true,
      });

      await dataSource.saveDiaryDay(
        DiaryDay(
          date: DateTime(2026, 10, 27),
          mood: DiaryMood.good,
          note: 'Dia bom',
          tasks: const [
            DiaryTask(
              category: DiaryCategory.movie,
              description: 'Ver Ran',
              movie: DiaryMovie(movieId: 11, title: 'Ran'),
            ),
          ],
        ),
      );

      final call = http.calls.single;
      expect(call.method, 'PUT');
      expect(call.path, '/api/v1/users/me/diary/2026-10-27');
      expect(call.body, {
        'mood': 'good',
        'note': 'Dia bom',
        'tasks': [
          {
            'category': 'movie',
            'description': 'Ver Ran',
            'done': false,
            'movieId': 11,
          },
        ],
      });
    },
  );

  test('a party keeps the offset between the server and the device', () async {
    http.response = const Success({
      'code': 'ABC234',
      'host': {'id': 'ana', 'username': 'ana'},
      'title': 'Ran',
      'startAt': '2026-10-27T20:01:00Z',
      'serverTime': '2026-10-27T20:00:05Z',
      'members': [
        {'id': 'ana', 'username': 'ana'},
      ],
      'messages': [
        {
          'id': 1,
          'user': {'id': 'ana', 'username': 'ana'},
          'body': 'Oi',
          'sentAt': '2026-10-27T19:59:00Z',
        },
      ],
      'self': true,
    });

    final party =
        (await dataSource.joinParty(' abc234 ') as Success<WatchParty>).data;

    expect(http.calls.single.path, '/api/v1/watch-parties/ABC234/members');
    expect(party.clockOffset, const Duration(seconds: 5));
    expect(party.remaining(now), const Duration(seconds: 55));
    expect(party.isHost, isTrue);
    expect(party.messages.single.body, 'Oi');
  });

  test(
    'the diary month sends YYYY-MM and the poster round has its options',
    () async {
      http.responses['/api/v1/users/me/diary'] = const Success([
        {
          'date': '2026-10-05',
          'mood': 'bad',
          'tasks': 2,
          'done': 1,
          'hasNote': true,
        },
      ]);
      http.responses['/api/v1/games/poster/round'] = const Success({
        'movie': {'movieId': 1, 'title': 'Ran'},
        'options': [
          {'movieId': 2, 'title': 'Ikiru'},
          {'movieId': 1, 'title': 'Ran'},
        ],
      });

      final month =
          (await dataSource.getDiaryMonth(2026, 10)
                  as Success<List<DiaryDaySummary>>)
              .data;
      final round =
          (await dataSource.getPosterRound() as Success<PosterRound>).data;

      expect(http.calls.first.query, {'month': '2026-10'});
      expect(month.single.mood, DiaryMood.bad);
      expect(round.options.map((o) => o.movieId), [2, 1]);
    },
  );
}
