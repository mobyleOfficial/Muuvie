import 'package:core/core.dart';

/// A movie inside a shelf, with the owner's state for it.
class ShelfMovie {
  final int movieId;
  final String title;
  final String? posterPath;
  final int? year;
  final String? director;
  final int? runtime;
  final bool watched;

  /// The owner's rating label (phase 13).
  final Rating? rating;

  const ShelfMovie({
    required this.movieId,
    required this.title,
    this.posterPath,
    this.year,
    this.director,
    this.runtime,
    required this.watched,
    this.rating,
  });
}
