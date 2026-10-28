import 'package:movies_domain/models/movie.dart';

class MovieListing {
  final int totalPages;
  final int totalResults;
  final List<Movie> movies;

  const MovieListing({
    required this.totalPages,
    required this.totalResults,
    required this.movies,
  });
}
