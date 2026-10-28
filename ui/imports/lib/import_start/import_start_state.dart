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
enum ImportStartFailure { inProgress, other }

class ImportStartSuccess extends ImportStartState {
  /// Earlier imports, newest first (F3.6).
  final List<ImportJob> history;
  final bool starting;
  final ImportStartFailure? failure;

  /// Set once the job is created; the page opens it.
  final ImportJob? started;

  const ImportStartSuccess({
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
