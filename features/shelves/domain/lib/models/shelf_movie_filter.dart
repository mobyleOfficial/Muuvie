/// Filters of a shelf's movie list. Null means "any".
class ShelfMovieFilter {
  final bool? watched;
  final int? genreId;

  /// First year of the decade, e.g. 1980.
  final int? decade;

  const ShelfMovieFilter({this.watched, this.genreId, this.decade});

  static const none = ShelfMovieFilter();

  bool get isEmpty => watched == null && genreId == null && decade == null;

  ShelfMovieFilter copyWith({
    bool? Function()? watched,
    int? Function()? genreId,
    int? Function()? decade,
  }) => ShelfMovieFilter(
    watched: watched != null ? watched() : this.watched,
    genreId: genreId != null ? genreId() : this.genreId,
    decade: decade != null ? decade() : this.decade,
  );

  @override
  bool operator ==(Object other) =>
      other is ShelfMovieFilter &&
      other.watched == watched &&
      other.genreId == genreId &&
      other.decade == decade;

  @override
  int get hashCode => Object.hash(watched, genreId, decade);
}
