import 'package:core/core.dart';
import 'package:imports_data/datasources/imports_remote_data_source.dart';
import 'package:imports_data/models/remote_imports.dart';
import 'package:imports_domain/models/models.dart';
import 'package:imports_domain/repositories/imports_repository.dart';

class ImportsRepositoryImpl implements ImportsRepository {
  final ImportsRemoteDataSource _remoteDataSource;
  final WebSocketClient _webSocketClient;

  ImportsRepositoryImpl(this._remoteDataSource, this._webSocketClient);

  @override
  Future<Result<ImportJob>> startImport({
    required ImportSource source,
    required String username,
    required String cookies,
  }) => _remoteDataSource.startImport(source, username, cookies);

  @override
  Future<Result<ImportJob>> getImport(int jobId) =>
      _remoteDataSource.getImport(jobId);

  @override
  Future<Result<ImportJobPage>> getImports({required int page}) =>
      _remoteDataSource.getImports(page);

  @override
  Future<Result<ImportJob>> confirmImport(
    int jobId, {
    List<String>? listsToImport,
    required ContentVisibility visibility,
  }) => _remoteDataSource.confirmImport(jobId, listsToImport, visibility);

  @override
  Future<Result<ImportJob>> cancelImport(int jobId) =>
      _remoteDataSource.cancelImport(jobId);

  @override
  Future<Result<UnmatchedPage>> getUnmatched(int jobId, {required int page}) =>
      _remoteDataSource.getUnmatched(jobId, page);

  @override
  Future<Result<UnmatchedItem>> matchUnmatched(
    int jobId,
    int itemId,
    MovieCandidate candidate,
  ) => _remoteDataSource.resolveUnmatched(jobId, itemId, {
    'tmdbId': candidate.tmdbId,
    'title': candidate.title,
  });

  @override
  Future<Result<UnmatchedItem>> skipUnmatched(int jobId, int itemId) =>
      _remoteDataSource.resolveUnmatched(jobId, itemId, {'skip': true});

  @override
  Stream<ImportProgress> watchProgress() => _webSocketClient.messages
      .where((message) => message.type == WsMessageType.importProgress)
      .map((message) => RemoteImports.progress(message.data))
      .where((progress) => progress != null)
      .cast<ImportProgress>();
}
