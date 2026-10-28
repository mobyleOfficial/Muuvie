import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelves/shelves.dart';

import '../../helpers/fake_http_client.dart';

Map<String, dynamic> _shelf(int id, {String? systemType}) => {
  'id': id,
  'ownerId': 'ana',
  'name': 'Shelf $id',
  'visibility': 'public',
  'systemType': systemType,
  'sortMode': 'manual',
  'pinned': false,
  'totalMovies': 2,
  'totalWatched': 1,
  'posterPaths': ['/p.jpg'],
  'self': false,
};

Map<String, dynamic> _page(List<Object> results, {bool hasNext = false}) => {
  'results': results,
  'page': 1,
  'totalPages': 1,
  'totalResults': results.length,
  'hasNext': hasNext,
};

void main() {
  late FakeHttpClient http;

  setUp(() => http = FakeHttpClient());

  test('discovering shelves sends the trimmed name filter', () async {
    http.response = Success(_page([_shelf(7)]));
    final repository = ShelvesRepositoryImpl(ShelvesRemoteDataSourceImpl(http));

    final result = await DiscoverShelves(repository)(
      const DiscoverParams(query: '  terror ', page: 2),
    );

    expect(http.calls.single.path, '/api/v1/discover/shelves');
    expect(http.calls.single.query, {'q': 'terror', 'page': 2, 'limit': 20});
    expect((result as Success<Paged<Shelf>>).data.items.single.id, 7);
  });

  test('discovering locadoras without a filter only pages', () async {
    http.response = Success(_page([]));
    final repository = LocadorasRepositoryImpl(
      LocadorasRemoteDataSourceImpl(http),
    );

    await DiscoverLocadoras(repository)();

    expect(http.calls.single.path, '/api/v1/discover/locadoras');
    expect(http.calls.single.query, {'page': 1, 'limit': 20});
  });

  test(
    'Quero ver in one tap finds the system shelf and adds the movie to it',
    () async {
      http.responses['/api/v1/users/me/shelves'] = Success(
        _page([
          _shelf(1, systemType: 'watched'),
          _shelf(2, systemType: 'watchlist'),
          _shelf(3),
        ]),
      );
      http.responses['/api/v1/movies/10/shelves'] = const Success({
        'movieId': 10,
        'shelfIds': [2],
      });
      final repository = ShelvesRepositoryImpl(
        ShelvesRemoteDataSourceImpl(http),
      );

      final result = await AddMovieToWatchlist(repository)(10);

      expect(result, isA<Success<MovieShelves>>());
      expect(http.calls.last.method, 'POST');
      expect(http.calls.last.path, '/api/v1/movies/10/shelves');
      expect((http.calls.last.body! as Map)['shelfIds'], [2]);
    },
  );

  test('without a Quero ver shelf nothing is added', () async {
    http.responses['/api/v1/users/me/shelves'] = Success(_page([_shelf(3)]));
    final repository = ShelvesRepositoryImpl(ShelvesRemoteDataSourceImpl(http));

    final result = await AddMovieToWatchlist(repository)(10);

    expect((result as Failure).error, AppError.notFound);
    expect(http.calls.where((c) => c.method == 'POST'), isEmpty);
  });
}
