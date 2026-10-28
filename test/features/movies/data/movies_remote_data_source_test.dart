import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/movies.dart';

import '../../../helpers/fake_http_client.dart';

void main() {
  late FakeHttpClient http;
  late MoviesRemoteDataSourceImpl dataSource;

  setUp(() {
    http = FakeHttpClient();
    dataSource = MoviesRemoteDataSourceImpl(http);
  });

  test('the Muuvie rankings read a page with the viewer state', () async {
    http.response = const Success({
      'results': [
        {
          'id': 7,
          'title': 'Suspiria',
          'overview': '',
          'posterPath': '/s.jpg',
          'releaseDate': '1977-02-01',
          'me': {'status': 'watched', 'rating': 'loved'},
        },
        {'id': 8, 'title': 'Inferno', 'overview': '', 'me': null},
      ],
      'page': 1,
      'totalPages': 3,
      'totalResults': 41,
      'hasNext': true,
    });

    final result = await dataSource.getTrendingOnMuuvie(page: 2);

    expect(http.calls.single.path, '/api/v1/discover/movies/trending');
    expect(http.calls.single.query, {'page': 2, 'limit': 20});
    final listing = (result as Success<RemoteMovieListing>).data.toDomain();
    expect(listing.totalPages, 3);
    expect(listing.movies.first.me?.status, WatchStatus.watched);
    expect(listing.movies.first.me?.rating, Rating.loved);
    expect(listing.movies.first.year, '1977');
    expect(listing.movies.last.me, isNull);

    await dataSource.getMostLovedOnMuuvie(page: 1);
    expect(http.calls.last.path, '/api/v1/discover/movies/loved');
  });

  test(
    'countries come by their localized name, accents sorted in place',
    () async {
      http.response = const Success([
        {'iso': 'ZM', 'englishName': 'Zambia', 'name': 'Zâmbia'},
        {'iso': 'AT', 'englishName': 'Austria', 'name': 'Áustria'},
        {'iso': 'AU', 'englishName': 'Australia', 'name': 'Austrália'},
        {'iso': 'XK', 'englishName': 'Kosovo'},
      ]);

      final result = await dataSource.getCountries();

      final countries = (result as Success<List<RemoteCountry>>).data
          .map((country) => country.toDomain())
          .toList();
      expect(countries.map((country) => country.name), [
        'Austrália',
        'Áustria',
        'Kosovo',
        'Zâmbia',
      ]);
    },
  );
}
