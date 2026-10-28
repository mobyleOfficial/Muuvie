import 'package:imports_domain/models/models.dart';

/// JSON of the v1 import endpoints (backend README, "Imports") to domain models.
abstract final class RemoteImports {
  static ImportJob job(Map<String, dynamic> json) => ImportJob(
    id: _int(json['id']),
    source:
        ImportSource.fromWireValue(json['source'] as String?) ??
        ImportSource.filmow,
    status:
        ImportStatus.fromWireValue(json['status'] as String?) ??
        ImportStatus.failed,
    inputRef: json['inputRef'] as String? ?? '',
    processed: _int(json['processed']),
    total: _int(json['total']),
    preview: switch (json['preview']) {
      final Map<String, dynamic> preview => _preview(preview),
      _ => null,
    },
    counts: switch (json['counts']) {
      final Map<String, dynamic> counts => _counts(counts),
      _ => null,
    },
    error: json['error'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime(0),
  );

  static ImportJobPage jobPage(Map<String, dynamic> json) => ImportJobPage(
    jobs: _list(json['results']).map(job).toList(),
    page: _int(json['page'], fallback: 1),
    hasNext: json['hasNext'] as bool? ?? false,
  );

  static UnmatchedItem unmatched(Map<String, dynamic> json) {
    final movie = json['movie'] as Map<String, dynamic>? ?? const {};
    return UnmatchedItem(
      id: _int(json['id']),
      title: movie['title'] as String? ?? '',
      originalTitle: movie['originalTitle'] as String?,
      year: (movie['year'] as num?)?.toInt(),
      posterUrl: movie['posterUrl'] as String?,
      candidates: _list(json['candidates'])
          .map(
            (candidate) => MovieCandidate(
              tmdbId: _int(candidate['tmdbId']),
              title: candidate['title'] as String? ?? '',
              originalTitle: candidate['originalTitle'] as String?,
              year: (candidate['year'] as num?)?.toInt(),
              posterPath: candidate['posterPath'] as String?,
            ),
          )
          .toList(),
      resolution: UnmatchedResolution.fromWireValue(
        json['resolution'] as String?,
      ),
    );
  }

  static UnmatchedPage unmatchedPage(Map<String, dynamic> json) =>
      UnmatchedPage(
        items: _list(json['results']).map(unmatched).toList(),
        page: _int(json['page'], fallback: 1),
        totalResults: _int(json['totalResults']),
        hasNext: json['hasNext'] as bool? ?? false,
      );

  /// The `import_progress` WebSocket payload; values come as strings.
  static ImportProgress? progress(Map<String, dynamic>? payload) {
    final jobId = int.tryParse(payload?['jobId']?.toString() ?? '');
    final status = ImportStatus.fromWireValue(payload?['status'] as String?);
    if (jobId == null || status == null) return null;
    return ImportProgress(jobId: jobId, status: status);
  }

  static ImportPreview _preview(Map<String, dynamic> json) => ImportPreview(
    watched: _int(json['watched']),
    watchlist: _int(json['watchlist']),
    favorites: _int(json['favorites']),
    logs: _int(json['logs']),
    lists: _list(json['lists'])
        .map(
          (list) => ImportPreviewList(
            externalId: list['externalId'] as String? ?? '',
            title: list['title'] as String? ?? '',
            movieCount: _int(list['movieCount']),
            coverUrl: list['coverUrl'] as String?,
          ),
        )
        .toList(),
  );

  static ImportCounts _counts(Map<String, dynamic> json) => ImportCounts(
    watched: _int(json['watched']),
    watchlist: _int(json['watchlist']),
    favorites: _int(json['favorites']),
    lists: _int(json['lists']),
    logs: _int(json['logs']),
    unmatched: _int(json['unmatched']),
    keptFromMuuvie: _int(json['keptFromMuuvie']),
  );

  static int _int(Object? value, {int fallback = 0}) =>
      (value as num?)?.toInt() ?? fallback;

  static List<Map<String, dynamic>> _list(Object? value) =>
      (value as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
}
