/// Where an import reads from. Letterboxd is on hold until its input format is
/// decided (roadmap A1), so the app only offers Filmow.
enum ImportSource {
  filmow('filmow'),
  letterboxd('letterboxd');

  final String wireValue;

  const ImportSource(this.wireValue);

  static ImportSource? fromWireValue(String? value) =>
      values.where((source) => source.wireValue == value).firstOrNull;
}

/// pending → reading → preview → importing → done; failed or cancelled end it early.
enum ImportStatus {
  pending('pending'),

  /// Reading the source profile.
  reading('reading'),

  /// Read; waiting for the user to confirm. Nothing was written yet.
  preview('preview'),
  importing('importing'),
  done('done'),
  failed('failed'),
  cancelled('cancelled');

  final String wireValue;

  const ImportStatus(this.wireValue);

  static ImportStatus? fromWireValue(String? value) =>
      values.where((status) => status.wireValue == value).firstOrNull;

  /// The server is working on it: worth following the progress.
  bool get isRunning => this == pending || this == reading || this == importing;

  /// Cancelling is only allowed before anything is written.
  bool get isCancellable =>
      this == pending || this == reading || this == preview;
}

/// A list found on the source, offered on the preview (F3.5).
class ImportPreviewList {
  final String externalId;
  final String title;
  final int movieCount;
  final String? coverUrl;

  const ImportPreviewList({
    required this.externalId,
    required this.title,
    required this.movieCount,
    this.coverUrl,
  });
}

/// What the import is about to write.
class ImportPreview {
  final int watched;
  final int watchlist;
  final int favorites;
  final int logs;
  final List<ImportPreviewList> lists;

  const ImportPreview({
    required this.watched,
    required this.watchlist,
    required this.favorites,
    required this.logs,
    this.lists = const [],
  });
}

/// Final report (F3.6).
class ImportCounts {
  final int watched;
  final int watchlist;
  final int favorites;
  final int lists;
  final int logs;

  /// Movies waiting for the user to confirm the TMDB match (F3.4).
  final int unmatched;

  /// Movies the user already had in the Muuvie, left as they were.
  final int keptFromMuuvie;

  const ImportCounts({
    this.watched = 0,
    this.watchlist = 0,
    this.favorites = 0,
    this.lists = 0,
    this.logs = 0,
    this.unmatched = 0,
    this.keptFromMuuvie = 0,
  });
}

class ImportJob {
  final int id;
  final ImportSource source;
  final ImportStatus status;

  /// The username on the source.
  final String inputRef;
  final int processed;
  final int total;
  final ImportPreview? preview;
  final ImportCounts? counts;
  final String? error;
  final DateTime createdAt;

  const ImportJob({
    required this.id,
    required this.source,
    required this.status,
    required this.inputRef,
    this.processed = 0,
    this.total = 0,
    this.preview,
    this.counts,
    this.error,
    required this.createdAt,
  });

  /// 0 to 1 while writing; null when the total is not known yet.
  double? get progress => total > 0 ? processed / total : null;
}

/// One page of the import history.
class ImportJobPage {
  final List<ImportJob> jobs;
  final int page;
  final bool hasNext;

  const ImportJobPage({
    required this.jobs,
    required this.page,
    required this.hasNext,
  });
}

/// A change pushed by the server while a job runs.
class ImportProgress {
  final int jobId;
  final ImportStatus status;

  const ImportProgress({required this.jobId, required this.status});
}
