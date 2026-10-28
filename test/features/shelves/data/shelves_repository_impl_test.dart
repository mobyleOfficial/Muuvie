import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelves/shelves.dart';

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

const _shelfJson = {
  'id': 7,
  'ownerId': 'ana',
  'name': 'Já assisti',
  'description': null,
  'color': '#112233',
  'visibility': 'mutual',
  'systemType': 'watched',
  'sortMode': 'added_newest',
  'position': 0,
  'pinned': true,
  'coverUrl': null,
  'totalMovies': 12,
  'totalWatched': 12,
  'posterPaths': ['/a.jpg'],
  'createdAt': '2026-10-26T10:00:00Z',
  'updatedAt': '2026-10-26T10:00:00Z',
  'self': true,
};

/// A shelf of the current user, which the save use case refuses.
const _mine = Shelf(
  id: 3,
  ownerId: 'ana',
  name: 'Terror',
  visibility: ContentVisibility.public,
  sortMode: ShelfSort.manual,
  pinned: false,
  totalMovies: 0,
  totalWatched: 0,
  posterPaths: [],
  isSelf: true,
);

void main() {
  late _FakeHttpClient http;
  late ShelvesRepositoryImpl repository;

  setUp(() {
    http = _FakeHttpClient();
    repository = ShelvesRepositoryImpl(ShelvesRemoteDataSourceImpl(http));
  });

  test(
    'the profile tab asks the API to leave out the shelves a locadora hides',
    () async {
      http.response = const Success({
        'results': [],
        'page': 1,
        'totalPages': 1,
        'totalResults': 0,
        'hasNext': false,
      });

      await GetUserShelves(repository)(
        const GetUserShelvesParams(profile: true),
      );

      expect(http.calls.single.query, {
        'page': 1,
        'limit': 20,
        'profile': true,
      });
    },
  );

  test('my shelves come from the v1 page envelope', () async {
    http.response = const Success({
      'results': [_shelfJson],
      'page': 1,
      'totalPages': 2,
      'totalResults': 21,
      'hasNext': true,
    });

    final result = await GetUserShelves(repository)();

    final page = (result as Success<Paged<Shelf>>).data;
    expect(http.calls.single.path, '/api/v1/users/me/shelves');
    expect(http.calls.single.query, {'page': 1, 'limit': 20});
    expect(page.hasNext, true);
    expect(page.totalResults, 21);
    final shelf = page.items.single;
    expect(shelf.systemType, SystemShelfType.watched);
    expect(shelf.isSystem, true);
    expect(shelf.visibility, ContentVisibility.mutual);
    expect(shelf.sortMode, ShelfSort.addedNewest);
    expect(shelf.pinned, true);
    expect(shelf.isSelf, true);
    expect(shelf.totalWatched, 12);
  });

  test('movie filters become query parameters', () async {
    http.response = const Success({
      'results': [
        {
          'movieId': 10,
          'title': 'Alien',
          'year': 1979,
          'watched': true,
          'isFavorite': false,
        },
      ],
      'page': 1,
      'totalPages': 1,
      'totalResults': 1,
      'hasNext': false,
    });

    final result = await GetShelfMovies(repository)(
      const GetShelfMoviesParams(
        shelfId: 7,
        filter: ShelfMovieFilter(watched: false, genreId: 878, decade: 1970),
        page: 2,
      ),
    );

    expect(http.calls.single.path, '/api/v1/shelves/7/movies');
    expect(http.calls.single.query, {
      'page': 2,
      'limit': 20,
      'watched': false,
      'genre': 878,
      'decade': 1970,
    });
    final movie = (result as Success<Paged<ShelfMovie>>).data.items.single;
    expect(movie.movieId, 10);
    expect(movie.watched, true);
  });

  test('writes go to the documented endpoints with their bodies', () async {
    http.response = const Success(_shelfJson);
    await repository.updateShelf(
      7,
      const ShelfDraft(
        name: 'Já assisti',
        color: '#112233',
        visibility: ContentVisibility.secret,
      ),
    );

    http.response = const Success(null);
    await repository.transferShelfMovies(
      shelfId: 7,
      targetShelfId: 8,
      mode: ShelfTransferMode.copy,
      movieIds: const [1, 2],
    );
    await repository.sortShelf(
      shelfId: 7,
      sortMode: ShelfSort.title,
      applyOnce: true,
    );
    await repository.reorderShelfMovies(shelfId: 7, movieIds: const [3, 1]);
    await repository.reorderShelves(
      shelfIds: const [8, 7],
      pinnedIds: const [8],
    );
    await repository.removeMovieFromShelf(shelfId: 7, movieId: 3);

    expect(http.calls.map((c) => '${c.method} ${c.path}'), [
      'PUT /api/v1/shelves/7',
      'POST /api/v1/shelves/7/movies/transfer',
      'PUT /api/v1/shelves/7/order',
      'PUT /api/v1/shelves/7/order',
      'PUT /api/v1/users/me/shelves/order',
      'DELETE /api/v1/shelves/7/movies/3',
    ]);
    expect(http.calls[0].body, {
      'name': 'Já assisti',
      'description': null,
      'color': '#112233',
      'visibility': 'secret',
    });
    expect(http.calls[1].body, {
      'targetShelfId': 8,
      'mode': 'copy',
      'movieIds': [1, 2],
    });
    expect(http.calls[2].body, {'sortMode': 'title', 'applyOnce': true});
    expect(http.calls[3].body, {
      'movieIds': [3, 1],
    });
    expect(http.calls[4].body, {
      'shelfIds': [8, 7],
      'pinnedIds': [8],
    });
  });

  test('adding to several shelves returns where the movie is now', () async {
    http.response = const Success({
      'movieId': 10,
      'shelfIds': [7, 9],
    });

    final result = await AddMovieToShelves(repository)(
      const AddMovieToShelvesParams(movieId: 10, shelfIds: [9, 9]),
    );

    expect(http.calls.single.path, '/api/v1/movies/10/shelves');
    expect(http.calls.single.body, {
      'shelfIds': [9],
    });
    expect((result as Success<MovieShelves>).data.shelfIds, {7, 9});
  });

  test('errors pass through unchanged', () async {
    http.response = const Failure(AppError.forbidden);

    final result = await repository.deleteShelf(7);

    expect((result as Failure<void>).error, AppError.forbidden);
  });

  test('saved shelves bring their owner and saved state (F14.5)', () async {
    http.response = Success({
      'results': [
        Map<String, dynamic>.of(_shelfJson)..addAll({
          'id': 9,
          'ownerId': 'bia',
          'name': 'Noir',
          'systemType': null,
          'visibility': 'public',
          'self': false,
          'owner': {
            'id': 'bia',
            'username': 'bia',
            'handle': 'bia',
            'displayName': 'Bia Lima',
            'avatarUrl': 'https://img/bia.png',
            'accentColor': '#FF0000',
          },
          'saved': true,
          'saves': 4,
        }),
      ],
      'page': 1,
      'totalPages': 1,
      'totalResults': 1,
      'hasNext': false,
    });

    final result = await GetSavedShelves(repository)();

    expect(http.calls.single.path, '/api/v1/users/me/shelves/saved');
    expect(http.calls.single.query, {'page': 1, 'limit': 20});
    final shelf = (result as Success<Paged<Shelf>>).data.items.single;
    expect(shelf.ownerName, 'Bia Lima');
    expect(shelf.ownerAvatarUrl, 'https://img/bia.png');
    expect(shelf.ownerAccentColor, '#FF0000');
    expect(shelf.isSaved, true);
    expect(shelf.saves, 4);
    expect(shelf.canBeSaved, true);
  });

  test('a shelf without owner, saved or saves keeps the defaults', () async {
    http.response = const Success(_shelfJson);

    final shelf = ((await repository.getShelf(7)) as Success<Shelf>).data;

    expect(shelf.ownerName, isNull);
    expect(shelf.isSaved, false);
    expect(shelf.saves, 0);
    expect(shelf.canBeSaved, false);
  });

  test('saving posts and unsaving deletes /shelves/{id}/save', () async {
    const shelf = Shelf(
      id: 9,
      ownerId: 'bia',
      name: 'Noir',
      visibility: ContentVisibility.public,
      sortMode: ShelfSort.manual,
      pinned: false,
      totalMovies: 1,
      totalWatched: 0,
      posterPaths: [],
      isSelf: false,
    );
    final setSaved = SetShelfSaved(repository);

    await setSaved(const SetShelfSavedParams(shelf: shelf, saved: true));
    await setSaved(const SetShelfSavedParams(shelf: shelf, saved: false));

    expect(http.calls.map((call) => '${call.method} ${call.path}'), [
      'POST /api/v1/shelves/9/save',
      'DELETE /api/v1/shelves/9/save',
    ]);
  });

  test('my own shelves cannot be saved', () async {
    final result = await SetShelfSaved(repository)(
      const SetShelfSavedParams(shelf: _mine, saved: true),
    );

    expect((result as Failure<void>).error, AppError.forbidden);
    expect(http.calls, isEmpty);
  });
}
