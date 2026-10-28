import 'package:core/core.dart';
import 'package:imports_domain/models/models.dart';

/// Import jobs on the v1 API (B3). The server reads the source in the
/// background, stops at the preview, and writes only after [confirmImport].
abstract interface class ImportsRepository {
  /// [cookies] is the source session from the in-app login; the server never stores it.
  Future<Result<ImportJob>> startImport({
    required ImportSource source,
    required String username,
    required String cookies,
  });

  Future<Result<ImportJob>> getImport(int jobId);

  Future<Result<ImportJobPage>> getImports({required int page});

  /// [listsToImport] null imports every list of the preview.
  Future<Result<ImportJob>> confirmImport(
    int jobId, {
    List<String>? listsToImport,
    required ContentVisibility visibility,
  });

  Future<Result<ImportJob>> cancelImport(int jobId);

  Future<Result<UnmatchedPage>> getUnmatched(int jobId, {required int page});

  Future<Result<UnmatchedItem>> matchUnmatched(
    int jobId,
    int itemId,
    MovieCandidate candidate,
  );

  Future<Result<UnmatchedItem>> skipUnmatched(int jobId, int itemId);

  /// Progress pushed on the WebSocket. Callers reload the job on each event.
  Stream<ImportProgress> watchProgress();
}
