import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/movies.dart';
import 'package:watch_logs/watch_logs.dart';

import '../../helpers/fake_http_client.dart';

void main() {
  late FakeHttpClient http;

  setUp(() => http = FakeHttpClient());

  test('the diary of a user maps each session with its movie', () async {
    http.response = const Success({
      'results': [
        {
          'log': {
            'id': 5,
            'userId': 'ana',
            'movieId': 10,
            'watchedOn': '2026-10-03',
            'cycle': 1,
            'mode': 'watched',
            'completed': true,
            'emotions': [],
            'visibility': 'public',
            'createdAt': '2026-10-03T10:00:00Z',
          },
          'movie': {
            'movieId': 10,
            'tmdbId': 100,
            'title': 'Casablanca',
            'posterPath': '/c.jpg',
            'year': 1942,
          },
        },
      ],
      'page': 1,
      'totalPages': 2,
      'totalResults': 21,
      'hasNext': true,
    });
    final repository = WatchLogsRepositoryImpl(
      WatchLogsRemoteDataSourceImpl(http),
    );

    final result = await GetUserDiary(repository)(
      const GetUserDiaryParams(userId: 'ana'),
    );

    final page = (result as Success<DiaryPage>).data;
    expect(http.calls.single.path, '/api/v1/users/ana/logs');
    expect(http.calls.single.query, {'page': 1, 'limit': 20});
    expect(page.hasNext, true);
    expect(page.entries.single.title, 'Casablanca');
    expect(page.entries.single.log.completed, true);
  });

  test('a person splits what they directed from what they acted in', () async {
    http.response = const Success({
      'person': {
        'id': 3,
        'tmdbPersonId': 30,
        'name': 'Agnès Varda',
        'profilePath': '/v.jpg',
      },
      'credits': [
        {
          'movie': {
            'id': 10,
            'tmdbId': 100,
            'title': 'Cléo de 5 à 7',
            'releaseDate': '1962-04-11',
          },
          'role': 'director',
          'character': null,
        },
        {
          'movie': {
            'id': 11,
            'tmdbId': 101,
            'title': 'Visages Villages',
            'releaseDate': '2017-06-28',
          },
          'role': 'cast',
          'character': 'Herself',
        },
      ],
    });
    final repository = PersonsRepositoryImpl(PersonsRemoteDataSource(http));

    final result = await GetPersonDetail(repository)(
      const GetPersonDetailParams(personId: 3),
    );

    final detail = (result as Success<PersonDetail>).data;
    expect(http.calls.single.path, '/api/v1/persons/3');
    expect(detail.person.name, 'Agnès Varda');
    expect(detail.directed.single.year, 1962);
    expect(detail.acted.single.character, 'Herself');
  });

  test(
    'a cast member known only by the TMDB id opens through the TMDB route',
    () async {
      http.response = const Success({
        'person': {'id': 3, 'tmdbPersonId': 30, 'name': 'Agnès Varda'},
        'credits': [],
      });
      final repository = PersonsRepositoryImpl(PersonsRemoteDataSource(http));

      await GetPersonDetail(repository)(
        const GetPersonDetailParams(personId: 0, tmdbPersonId: 30),
      );

      expect(http.calls.single.path, '/api/v1/persons/tmdb/30');
    },
  );
}
