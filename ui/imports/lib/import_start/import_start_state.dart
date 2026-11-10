import 'package:imports/imports.dart';

sealed class ImportStartState {
  const ImportStartState();
}

class ImportStartLoading extends ImportStartState {
  const ImportStartLoading();
}

class ImportStartError extends ImportStartState {
  final String message;

  const ImportStartError(this.message);
}

/// Why starting failed, for the snackbar.
enum ImportStartFailure {
  inProgress,

  /// The server could not read an uploaded file (wrong file or wrong origin).
  unreadableFile,

  /// A loose Letterboxd CSV that could be watched or watchlist.
  ambiguousFile,

  /// The files have no movies.
  emptyFile,

  /// The uploaded files are over the server's limits.
  tooLarge,
  other,
}

class ImportStartSuccess extends ImportStartState {
  /// Earlier imports, newest first (F3.6).
  final List<ImportJob> history;
  final bool starting;
  final ImportStartFailure? failure;

  /// Set once the job is created; the page opens it.
  final ImportJob? started;

  /// 0 to 1 while files upload; null otherwise.
  final double? uploadProgress;

  const ImportStartSuccess({
    this.uploadProgress,
    this.history = const [],
    this.starting = false,
    this.failure,
    this.started,
  });

  /// An import still running or waiting on its preview, to resume instead of
  /// starting a second one.
  ImportJob? get activeJob => history
      .where(
        (job) => job.status.isRunning || job.status == ImportStatus.preview,
      )
      .firstOrNull;
}
