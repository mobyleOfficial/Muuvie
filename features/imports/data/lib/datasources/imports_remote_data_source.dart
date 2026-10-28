import 'package:core/core.dart';
import 'package:imports_data/models/remote_imports.dart';
import 'package:imports_domain/models/models.dart';

abstract interface class ImportsRemoteDataSource {
  Future<Result<ImportJob>> startImport(
    ImportSource source,
    String username,
    String cookies,
  );

  Future<Result<ImportJob>> getImport(int jobId);

  Future<Result<ImportJobPage>> getImports(int page);

  Future<Result<ImportJob>> confirmImport(
    int jobId,
    List<String>? listsToImport,
    ContentVisibility visibility,
  );

  Future<Result<ImportJob>> cancelImport(int jobId);

  Future<Result<UnmatchedPage>> getUnmatched(int jobId, int page);

  Future<Result<UnmatchedItem>> resolveUnmatched(
    int jobId,
    int itemId,
    Map<String, dynamic> body,
  );
}

/// Import endpoints of the v1 API (`/api/v1/imports`). See the backend README.
class ImportsRemoteDataSourceImpl implements ImportsRemoteDataSource {
  static const _base = '/api/v1/imports';
  static const _pageSize = 20;

  final HttpClient _httpClient;

  ImportsRemoteDataSourceImpl(this._httpClient);

  @override
  Future<Result<ImportJob>> startImport(
    ImportSource source,
    String username,
    String cookies,
  ) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      _base,
      body: {
        'source': source.wireValue,
        'username': username,
        'cookies': cookies,
      },
    ),
    RemoteImports.job,
  );

  @override
  Future<Result<ImportJob>> getImport(int jobId) async => _map(
    await _httpClient.get<Map<String, dynamic>>('$_base/$jobId'),
    RemoteImports.job,
  );

  @override
  Future<Result<ImportJobPage>> getImports(int page) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      _base,
      queryParams: {'page': page, 'limit': _pageSize},
    ),
    RemoteImports.jobPage,
  );

  @override
  Future<Result<ImportJob>> confirmImport(
    int jobId,
    List<String>? listsToImport,
    ContentVisibility visibility,
  ) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      '$_base/$jobId/confirm',
      body: {
        'listsToImport': ?listsToImport,
        'defaultVisibility': visibility.wireValue,
      },
    ),
    RemoteImports.job,
  );

  @override
  Future<Result<ImportJob>> cancelImport(int jobId) async => _map(
    await _httpClient.post<Map<String, dynamic>>('$_base/$jobId/cancel'),
    RemoteImports.job,
  );

  @override
  Future<Result<UnmatchedPage>> getUnmatched(int jobId, int page) async => _map(
    await _httpClient.get<Map<String, dynamic>>(
      '$_base/$jobId/unmatched',
      queryParams: {'page': page, 'limit': _pageSize},
    ),
    RemoteImports.unmatchedPage,
  );

  @override
  Future<Result<UnmatchedItem>> resolveUnmatched(
    int jobId,
    int itemId,
    Map<String, dynamic> body,
  ) async => _map(
    await _httpClient.post<Map<String, dynamic>>(
      '$_base/$jobId/unmatched/$itemId',
      body: body,
    ),
    RemoteImports.unmatched,
  );

  Result<T> _map<T>(
    Result<Map<String, dynamic>> result,
    T Function(Map<String, dynamic>) fromJson,
  ) => switch (result) {
    Success(:final data) => Success(fromJson(data)),
    Failure(:final error) => Failure(error),
  };
}
