/// A TMDB movie offered for an imported movie the server could not match.
class MovieCandidate {
  final int tmdbId;
  final String title;
  final String? originalTitle;
  final int? year;
  final String? posterPath;

  const MovieCandidate({
    required this.tmdbId,
    required this.title,
    this.originalTitle,
    this.year,
    this.posterPath,
  });
}

enum UnmatchedResolution {
  pending('pending'),
  matched('matched'),
  skipped('skipped');

  final String wireValue;

  const UnmatchedResolution(this.wireValue);

  static UnmatchedResolution fromWireValue(String? value) =>
      values.where((resolution) => resolution.wireValue == value).firstOrNull ??
      pending;
}

/// F3.4: an imported movie waiting for the user to pick its TMDB match. It is
/// already on the shelves as it came from the source; skipping keeps it so.
class UnmatchedItem {
  final int id;
  final String title;
  final String? originalTitle;
  final int? year;
  final String? posterUrl;
  final List<MovieCandidate> candidates;
  final UnmatchedResolution resolution;

  const UnmatchedItem({
    required this.id,
    required this.title,
    this.originalTitle,
    this.year,
    this.posterUrl,
    this.candidates = const [],
    this.resolution = UnmatchedResolution.pending,
  });

  UnmatchedItem copyWith({UnmatchedResolution? resolution}) => UnmatchedItem(
    id: id,
    title: title,
    originalTitle: originalTitle,
    year: year,
    posterUrl: posterUrl,
    candidates: candidates,
    resolution: resolution ?? this.resolution,
  );
}

class UnmatchedPage {
  final List<UnmatchedItem> items;
  final int page;
  final int totalResults;
  final bool hasNext;

  const UnmatchedPage({
    required this.items,
    required this.page,
    required this.totalResults,
    required this.hasNext,
  });
}
