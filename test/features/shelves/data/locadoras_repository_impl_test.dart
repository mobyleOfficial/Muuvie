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

const _locadoraJson = {
  'id': 3,
  'ownerId': 'ana',
  'ownerUsername': 'ana',
  'ownerAvatarUrl': null,
  'name': 'Locadora do Terror',
  'description': 'Só terror',
  'visibility': 'mutual',
  'hideShelvesInProfile': true,
  'hideShelvesInFilters': false,
  'position': 0,
  'pinned': true,
  'coverUrl': null,
  'totalShelves': 3,
  'totalMovies': 40,
  'totalWatched': 12,
  'posterPaths': ['/a.jpg', '/b.jpg'],
  'createdAt': '2026-10-26T10:00:00Z',
  'updatedAt': '2026-10-26T10:00:00Z',
  'self': true,
};

const _shelfJson = {
  'id': 7,
  'ownerId': 'ana',
  'name': 'Slashers 80s',
  'visibility': 'public',
  'sortMode': 'manual',
  'pinned': false,
  'totalMovies': 1,
  'totalWatched': 0,
  'posterPaths': ['/h.jpg'],
  'self': false,
};

void main() {
  late _FakeHttpClient http;
  late LocadorasRepositoryImpl repository;

  setUp(() {
    http = _FakeHttpClient();
    repository = LocadorasRepositoryImpl(LocadorasRemoteDataSourceImpl(http));
  });

  test('locadoras of a user come from the v1 page envelope', () async {
    http.response = const Success({
      'results': [_locadoraJson],
      'page': 1,
      'totalPages': 1,
      'totalResults': 1,
      'hasNext': false,
    });

    final result = await GetUserLocadoras(repository)(
      const GetUserLocadorasParams(userId: 'bia'),
    );

    final locadora = (result as Success<Paged<Locadora>>).data.items.single;
    expect(http.calls.single.path, '/api/v1/users/bia/locadoras');
    expect(http.calls.single.query, {'page': 1, 'limit': 20});
    expect(locadora.visibility, ContentVisibility.mutual);
    expect(locadora.hideShelvesInProfile, true);
    expect(locadora.pinned, true);
    expect(locadora.isSelf, true);
    expect(locadora.totalShelves, 3);
    expect(locadora.totalWatched, 12);
    expect(locadora.posterPaths, ['/a.jpg', '/b.jpg']);
  });

  test('saving creates or edits with the draft body', () async {
    http.response = const Success(_locadoraJson);
    const draft = LocadoraDraft(
      name: '  Locadora do Terror ',
      description: '   ',
      visibility: ContentVisibility.secret,
      hideShelvesInFilters: true,
    );

    await SaveLocadora(repository)(const SaveLocadoraParams(draft: draft));
    await SaveLocadora(repository)(
      const SaveLocadoraParams(locadoraId: 3, draft: draft),
    );

    expect(http.calls.map((c) => '${c.method} ${c.path}'), [
      'POST /api/v1/locadoras',
      'PUT /api/v1/locadoras/3',
    ]);
    expect(http.calls.first.body, {
      'name': 'Locadora do Terror',
      'description': null,
      'visibility': 'secret',
      'hideShelvesInProfile': false,
      'hideShelvesInFilters': true,
    });
  });

  test('a name over 150 characters never reaches the backend', () async {
    final result = await SaveLocadora(repository)(
      SaveLocadoraParams(draft: LocadoraDraft(name: 'a' * 151)),
    );

    expect((result as Failure).error, AppError.badRequest);
    expect(http.calls, isEmpty);
  });

  test('shelves of a locadora carry their first movies', () async {
    http.response = const Success({
      'results': [
        {
          'shelf': _shelfJson,
          'movies': [
            {
              'movieId': 10,
              'title': 'Halloween',
              'watched': true,
              'isFavorite': false,
            },
          ],
        },
      ],
      'page': 2,
      'totalPages': 2,
      'totalResults': 21,
      'hasNext': false,
    });

    final result = await GetLocadoraShelves(repository)(
      const GetLocadoraShelvesParams(locadoraId: 3, page: 2),
    );

    final shelf = (result as Success<Paged<LocadoraShelf>>).data.items.single;
    expect(http.calls.single.path, '/api/v1/locadoras/3/shelves');
    expect(http.calls.single.query, {'page': 2, 'limit': 20});
    expect(shelf.shelf.name, 'Slashers 80s');
    expect(shelf.movies.single.movieId, 10);
  });

  test('set, order and profile order send the ids', () async {
    await SetLocadoraShelves(repository)(
      const LocadoraShelvesParams(locadoraId: 3, shelfIds: [7, 8, 7]),
    );
    await ReorderLocadoraShelves(repository)(
      const LocadoraShelvesParams(locadoraId: 3, shelfIds: [8, 7]),
    );
    await ReorderLocadoraShelves(repository)(
      const LocadoraShelvesParams(locadoraId: 3, shelfIds: []),
    );
    await ReorderLocadoras(repository)(
      const ReorderLocadorasParams(locadoraIds: [3, 4], pinnedIds: [4]),
    );
    await DeleteLocadora(repository)(3);

    expect(http.calls.map((c) => '${c.method} ${c.path}'), [
      'PUT /api/v1/locadoras/3/shelves',
      'PUT /api/v1/locadoras/3/shelves/order',
      'PUT /api/v1/users/me/locadoras/order',
      'DELETE /api/v1/locadoras/3',
    ]);
    expect(http.calls[0].body, {
      'shelfIds': [7, 8],
    });
    expect(http.calls[1].body, {
      'shelfIds': [8, 7],
    });
    expect(http.calls[2].body, {
      'locadoraIds': [3, 4],
      'pinnedIds': [4],
    });
  });

  test('errors pass through', () async {
    http.response = const Failure(AppError.forbidden);

    final result = await GetLocadora(repository)(3);

    expect((result as Failure).error, AppError.forbidden);
  });
}
