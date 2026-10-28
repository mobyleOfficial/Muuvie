import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stats/stats.dart';

import '../../helpers/fake_http_client.dart';

void main() {
  late FakeHttpClient http;
  late StatsRemoteDataSourceImpl dataSource;

  setUp(() {
    http = FakeHttpClient();
    dataSource = StatsRemoteDataSourceImpl(http);
  });

  test('a year reads the totals, the months and the breakdowns', () async {
    http.response = const Success({
      'year': 2026,
      'movies': 3,
      'sessions': 5,
      'minutes': 442,
      'rewatches': 1,
      'months': [
        {'month': 1, 'movies': 1, 'minutes': 88, 'sessions': 2},
      ],
      'genres': [
        {'key': '18', 'label': 'Drama', 'movies': 2, 'minutes': 250},
      ],
      'decades': [
        {'key': '1950', 'movies': 1},
      ],
      'stars': [
        {'key': '5.0', 'movies': 1},
      ],
    });

    final result = await dataSource.getYear('me', 2026);

    expect(http.calls.single.path, '/api/v1/users/me/stats/2026');
    final stats = (result as Success<YearStats>).data;
    expect(stats.movies, 3);
    expect(stats.months.single.sessions, 2);
    expect(stats.genres.single.label, 'Drama');
    expect(stats.decades.single.key, '1950');
    expect(stats.countries, isEmpty);
    expect(stats.isEmpty, isFalse);
  });

  test('years, calendar and the retrospective', () async {
    http.responses['/api/v1/users/ana/stats/years'] = const Success({
      'years': [2026, 2025],
    });
    http.responses['/api/v1/users/ana/stats/2026/calendar'] = const Success([
      {'date': '2026-01-10', 'sessions': 2, 'minutes': 100},
    ]);
    http.responses['/api/v1/users/me/retrospectives/2026'] = const Success({
      'year': 2026,
      'movies': 3,
      'minutes': 380,
      'topGenres': [
        {'key': '18', 'label': 'Drama', 'movies': 2},
      ],
      'topDirectors': [
        {'tmdbId': 5026, 'name': 'Akira Kurosawa', 'movies': 2},
      ],
      'emotion': 'moved',
      'favorite': {'movieId': 10, 'title': 'Rashomon', 'year': 1950},
      'favoriteStars': 5.0,
      'bestMonth': {'month': 3, 'movies': 2},
      'goal': {'year': 2026, 'targetMovies': 10, 'watched': 3},
    });

    final years = await dataSource.getYears('ana');
    final calendar = await dataSource.getCalendar('ana', 2026);
    final story = await dataSource.getRetrospective(2026);

    expect((years as Success<List<int>>).data, [2026, 2025]);
    expect(
      (calendar as Success<List<CalendarDay>>).data.single.date,
      DateTime(2026, 1, 10),
    );
    final retrospective = (story as Success<Retrospective>).data;
    expect(retrospective.favorite?.title, 'Rashomon');
    expect(retrospective.topDirectors.single.name, 'Akira Kurosawa');
    expect(retrospective.bestMonth?.month, 3);
    expect(retrospective.goal?.progress, closeTo(0.3, 0.001));
  });

  test('setting a goal sends the target and removing deletes it', () async {
    http.response = const Success({
      'year': 2026,
      'targetMovies': 100,
      'watched': 12,
    });

    final goal = await dataSource.setGoal(2026, 100);
    http.response = const Success(null);
    await dataSource.removeGoal(2026);

    expect(http.calls.first.method, 'PUT');
    expect(http.calls.first.path, '/api/v1/users/me/goals/2026');
    expect(http.calls.first.body, {'targetMovies': 100});
    expect((goal as Success<YearlyGoal>).data.reached, isFalse);
    expect(http.calls.last.method, 'DELETE');
  });
}
