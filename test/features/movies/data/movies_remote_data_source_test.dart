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
    'the similar movies are read by database id with the viewer state',
    () async {
      http.response = const Success({
        'movieId': 7,
        'results': [
          {
            'id': 8,
            'tmdbId': 11906,
            'title': 'Inferno',
            'overview': '',
            'posterPath': '/i.jpg',
            'releaseDate': '1980-02-07',
            'me': {'status': 'watched'},
          },
          {'id': 9, 'title': 'Tenebre', 'overview': '', 'me': null},
        ],
        'affinities': [
          {
            'movieId': 8,
            'score': 0.82,
            'sharedGenres': ['Terror'],
            'sharedKeywords': ['witch'],
            'genres': ['Mistério', 'Terror'],
          },
          {'movieId': 9, 'score': 0.4},
        ],
      });

      final result = await dataSource.getSimilarMovies(movieId: 7);

      expect(http.calls.single.path, '/api/v1/movies/7/similar');
      final remoteMovies = (result as Success<List<RemoteSimilarMovie>>).data;
      final similarMovies = [
        for (var rank = 0; rank < remoteMovies.length; rank++)
          remoteMovies[rank].toDomain(rank: rank, count: remoteMovies.length),
      ];
      expect(similarMovies.map((similar) => similar.movie.id), [8, 9]);
      expect(similarMovies.map((similar) => similar.score), [0.82, 0.4]);
      expect(similarMovies.first.sharedGenres, ['Terror']);
      expect(similarMovies.first.sharedKeywords, ['witch']);
      expect(similarMovies.last.sharedKeywords, isEmpty);
      expect(similarMovies.first.genres, ['Mistério', 'Terror']);
      expect(similarMovies.last.genres, isEmpty);
      expect(similarMovies.first.movie.me?.status, WatchStatus.watched);
      expect(similarMovies.first.movie.year, '1980');
      expect(similarMovies.last.movie.me, isNull);
    },
  );

  test('without affinities the order stands in for the score', () async {
    http.response = const Success({
      'movieId': 7,
      'results': [
        {'id': 8, 'title': 'Inferno', 'overview': ''},
        {'id': 9, 'title': 'Tenebre', 'overview': ''},
        {'id': 10, 'title': 'Phenomena', 'overview': ''},
      ],
    });

    final result = await dataSource.getSimilarMovies(movieId: 7);

    final remoteMovies = (result as Success<List<RemoteSimilarMovie>>).data;
    expect(remoteMovies.map((similar) => similar.score), [null, null, null]);
    expect([
      for (var rank = 0; rank < 3; rank++)
        remoteMovies[rank].toDomain(rank: rank, count: 3).score,
    ], [closeTo(0.7, 1e-9), closeTo(0.5, 1e-9), closeTo(0.3, 1e-9)]);
  });

  test('a movie without similar movies reads an empty list', () async {
    http.response = const Success({'movieId': 7, 'results': []});

    final result = await dataSource.getSimilarMovies(movieId: 7);

    expect((result as Success<List<RemoteSimilarMovie>>).data, isEmpty);
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
