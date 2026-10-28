import 'package:core/core.dart';
import 'package:shelves_data/datasources/shelves_remote_data_source.dart';
import 'package:shelves_data/models/models.dart';
import 'package:shelves_domain/models/models.dart';

/// Shelves on the v1 API (`/api/v1`). See the backend README, "Shelves".
class ShelvesRemoteDataSourceImpl implements ShelvesRemoteDataSource {
  static const _base = '/api/v1';
  static const _pageSize = 20;

  final HttpClient _httpClient;

  ShelvesRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Result<RemotePage<RemoteShelf>>> getUserShelves({
    required String userId,
    required int page,
    bool profile = false,
  }) => _getShelfPage('$_base/users/$userId/shelves', {
    'page': page,
    'limit': _pageSize,
    if (profile) 'profile': true,
  });

  @override
  Future<Result<RemotePage<RemoteShelf>>> searchShelves({
    required String query,
    required int page,
  }) => _getShelfPage('$_base/shelves/search', {
    'q': query,
    'page': page,
    'limit': _pageSize,
  });

  @override
  Future<Result<RemotePage<RemoteShelf>>> discoverShelves({
    String? query,
    required int page,
  }) => _getShelfPage('$_base/discover/shelves', {
    if (query != null && query.isNotEmpty) 'q': query,
    'page': page,
    'limit': _pageSize,
  });

  @override
  Future<Result<RemoteShelf>> getShelf(int shelfId) async => _map(
    await _httpClient.get<Map<String, dynamic>>('$_base/shelves/$shelfId'),
    RemoteShelf.fromJson,
  );

  @override
  Future<Result<RemotePage<RemoteShelf>>> getSavedShelves({
    required int page,
  }) => _getShelfPage('$_base/users/me/shelves/saved', {
    'page': page,
    'limit': _pageSize,
  });

  @override
  Future<Result<void>> setShelfSaved({
    required int shelfId,
    required bool saved,
  }) async {
    final path = '$_base/shelves/$shelfId/save';
    return _ignoreBody(
      saved
          ? await _httpClient.post<dynamic>(path)
          : await _httpClient.delete<dynamic>(path),
    );
  }

  @override
  Future<Result<RemoteShelf>> createShelf(ShelfDraft draft) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      '$_base/shelves',
      body: _draftBody(draft),
    ),
    RemoteShelf.fromJson,
  );

  @override
  Future<Result<RemoteShelf>> updateShelf(
    int shelfId,
    ShelfDraft draft,
  ) async => _map(
    await _httpClient.put<Map<String, dynamic>>(
      '$_base/shelves/$shelfId',
      body: _draftBody(draft),
    ),
    RemoteShelf.fromJson,
  );

  @override
  Future<Result<void>> deleteShelf(int shelfId) async =>
      _ignoreBody(await _httpClient.delete<dynamic>('$_base/shelves/$shelfId'));

  @override
  Future<Result<RemotePage<RemoteShelfMovie>>> getShelfMovies({
    required int shelfId,
    required ShelfMovieFilter filter,
    required int page,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '$_base/shelves/$shelfId/movies',
      queryParams: {
        'page': page,
        'limit': _pageSize,
        if (filter.watched != null) 'watched': filter.watched,
        if (filter.genreId != null) 'genre': filter.genreId,
        if (filter.decade != null) 'decade': filter.decade,
      },
    );
    return _map(
      result,
      (json) => RemotePage.fromJson(json, RemoteShelfMovie.fromJson),
    );
  }

  @override
  Future<Result<void>> addMovieToShelf({
    required int shelfId,
    required int movieId,
  }) async => _ignoreBody(
    await _httpClient.post<dynamic>(
      '$_base/shelves/$shelfId/movies',
      body: {'movieId': movieId},
    ),
  );

  @override
  Future<Result<void>> removeMovieFromShelf({
    required int shelfId,
    required int movieId,
  }) async => _ignoreBody(
    await _httpClient.delete<dynamic>(
      '$_base/shelves/$shelfId/movies/$movieId',
    ),
  );

  @override
  Future<Result<void>> transferShelfMovies({
    required int shelfId,
    required int targetShelfId,
    required ShelfTransferMode mode,
    required List<int> movieIds,
  }) async => _ignoreBody(
    await _httpClient.post<dynamic>(
      '$_base/shelves/$shelfId/movies/transfer',
      body: {
        'targetShelfId': targetShelfId,
        'mode': mode.wireValue,
        'movieIds': movieIds,
      },
    ),
  );

  @override
  Future<Result<void>> sortShelf({
    required int shelfId,
    required ShelfSort sortMode,
    required bool applyOnce,
  }) async => _ignoreBody(
    await _httpClient.put<dynamic>(
      '$_base/shelves/$shelfId/order',
      body: {'sortMode': sortMode.wireValue, 'applyOnce': applyOnce},
    ),
  );

  @override
  Future<Result<void>> reorderShelfMovies({
    required int shelfId,
    required List<int> movieIds,
  }) async => _ignoreBody(
    await _httpClient.put<dynamic>(
      '$_base/shelves/$shelfId/order',
      body: {'movieIds': movieIds},
    ),
  );

  @override
  Future<Result<void>> reorderShelves({
    required List<int> shelfIds,
    List<int>? pinnedIds,
  }) async => _ignoreBody(
    await _httpClient.put<dynamic>(
      '$_base/users/me/shelves/order',
      body: {'shelfIds': shelfIds, 'pinnedIds': ?pinnedIds},
    ),
  );

  @override
  Future<Result<RemotePage<RemotePublicShelf>>> getPublicShelvesWithMovie({
    required int movieId,
    required int page,
  }) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/movies/$movieId/shelves/public',
      queryParams: {'page': page, 'limit': _pageSize},
    ),
    (json) => RemotePage.fromJson(json, RemotePublicShelf.fromJson),
  );

  @override
  Future<Result<RemoteMovieShelves>> getMovieShelves(int movieId) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/movies/$movieId/shelves',
    ),
    RemoteMovieShelves.fromJson,
  );

  @override
  Future<Result<RemoteMovieShelves>> addMovieToShelves({
    required int movieId,
    required List<int> shelfIds,
  }) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      '$_base/movies/$movieId/shelves',
      body: {'shelfIds': shelfIds},
    ),
    RemoteMovieShelves.fromJson,
  );

  Future<Result<RemotePage<RemoteShelf>>> _getShelfPage(
    String path,
    Map<String, dynamic> queryParams,
  ) async => _map(
    await _httpClient.get<Map<String, dynamic>>(path, queryParams: queryParams),
    (json) => RemotePage.fromJson(json, RemoteShelf.fromJson),
  );

  Map<String, dynamic> _draftBody(ShelfDraft draft) => {
    'name': draft.name,
    'description': draft.description,
    'color': draft.color,
    'visibility': draft.visibility.wireValue,
  };

  Result<T> _map<T>(
    Result<Map<String, dynamic>> result,
    T Function(Map<String, dynamic>) fromJson,
  ) => switch (result) {
    Success(:final data) => Success(fromJson(data)),
    Failure(:final error) => Failure(error),
  };

  Result<void> _ignoreBody(Result<dynamic> result) => switch (result) {
    Success() => const Success(null),
    Failure(:final error) => Failure(error),
  };
}
