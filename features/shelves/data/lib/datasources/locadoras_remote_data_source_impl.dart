import 'package:core/core.dart';
import 'package:shelves_data/datasources/locadoras_remote_data_source.dart';
import 'package:shelves_data/models/models.dart';
import 'package:shelves_domain/models/models.dart';

/// Locadoras on the v1 API (`/api/v1`). See the backend README, "Locadoras".
class LocadorasRemoteDataSourceImpl implements LocadorasRemoteDataSource {
  static const _base = '/api/v1';
  static const _pageSize = 20;

  final HttpClient _httpClient;

  LocadorasRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Result<RemotePage<RemoteLocadora>>> getUserLocadoras({
    required String userId,
    required int page,
  }) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/users/$userId/locadoras',
      queryParams: {'page': page, 'limit': _pageSize},
    ),
    (json) => RemotePage.fromJson(json, RemoteLocadora.fromJson),
  );

  @override
  Future<Result<RemotePage<RemoteLocadora>>> discoverLocadoras({
    String? query,
    required int page,
  }) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/discover/locadoras',
      queryParams: {
        if (query != null && query.isNotEmpty) 'q': query,
        'page': page,
        'limit': _pageSize,
      },
    ),
    (json) => RemotePage.fromJson(json, RemoteLocadora.fromJson),
  );

  @override
  Future<Result<RemoteLocadora>> getLocadora(int locadoraId) async => _map(
    await _httpClient.get<Map<String, dynamic>>('$_base/locadoras/$locadoraId'),
    RemoteLocadora.fromJson,
  );

  @override
  Future<Result<RemoteLocadora>> createLocadora(LocadoraDraft draft) async =>
      _map(
        await _httpClient.post<Map<String, dynamic>>(
          '$_base/locadoras',
          body: _draftBody(draft),
        ),
        RemoteLocadora.fromJson,
      );

  @override
  Future<Result<RemoteLocadora>> updateLocadora(
    int locadoraId,
    LocadoraDraft draft,
  ) async => _map(
    await _httpClient.put<Map<String, dynamic>>(
      '$_base/locadoras/$locadoraId',
      body: _draftBody(draft),
    ),
    RemoteLocadora.fromJson,
  );

  @override
  Future<Result<void>> deleteLocadora(int locadoraId) async => _ignoreBody(
    await _httpClient.delete<dynamic>('$_base/locadoras/$locadoraId'),
  );

  @override
  Future<Result<RemotePage<RemoteLocadoraShelf>>> getLocadoraShelves({
    required int locadoraId,
    required int page,
  }) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/locadoras/$locadoraId/shelves',
      queryParams: {'page': page, 'limit': _pageSize},
    ),
    (json) => RemotePage.fromJson(json, RemoteLocadoraShelf.fromJson),
  );

  @override
  Future<Result<void>> setLocadoraShelves({
    required int locadoraId,
    required List<int> shelfIds,
  }) async => _ignoreBody(
    await _httpClient.put<dynamic>(
      '$_base/locadoras/$locadoraId/shelves',
      body: {'shelfIds': shelfIds},
    ),
  );

  @override
  Future<Result<void>> reorderLocadoraShelves({
    required int locadoraId,
    required List<int> shelfIds,
  }) async => _ignoreBody(
    await _httpClient.put<dynamic>(
      '$_base/locadoras/$locadoraId/shelves/order',
      body: {'shelfIds': shelfIds},
    ),
  );

  @override
  Future<Result<void>> reorderLocadoras({
    required List<int> locadoraIds,
    List<int>? pinnedIds,
  }) async => _ignoreBody(
    await _httpClient.put<dynamic>(
      '$_base/users/me/locadoras/order',
      body: {'locadoraIds': locadoraIds, 'pinnedIds': ?pinnedIds},
    ),
  );

  Map<String, dynamic> _draftBody(LocadoraDraft draft) => {
    'name': draft.name,
    'description': draft.description,
    'visibility': draft.visibility.wireValue,
    'hideShelvesInProfile': draft.hideShelvesInProfile,
    'hideShelvesInFilters': draft.hideShelvesInFilters,
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
