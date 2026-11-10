import 'package:movies_domain/models/movie.dart';

/// A movie similar to another one, with how similar it is: [score] from 0 to
/// 1, and the genres and keywords both movies share. [genres] are all the
/// genres of [movie] itself, empty while the backend does not know them.
class SimilarMovie {
  final Movie movie;
  final double score;
  final List<String> sharedGenres;
  final List<String> sharedKeywords;
  final List<String> genres;

  const SimilarMovie({
    required this.movie,
    required this.score,
    this.sharedGenres = const [],
    this.sharedKeywords = const [],
    this.genres = const [],
  });

  SimilarMovie withMovie(Movie movie) => SimilarMovie(
    movie: movie,
    score: score,
    sharedGenres: sharedGenres,
    sharedKeywords: sharedKeywords,
    genres: genres,
  );

  /// The score the backend gives a movie it knows nothing else about: from
  /// 0.7 for the first of [count] down to 0.3 for the last, by [rank].
  static double neutralScore(int rank, int count) =>
      count <= 1 ? 0.7 : 0.7 - 0.4 * rank / (count - 1);
}
