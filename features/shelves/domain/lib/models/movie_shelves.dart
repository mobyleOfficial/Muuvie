/// Which of the current user's shelves hold a movie.
class MovieShelves {
  final int? movieId;
  final Set<int> shelfIds;

  const MovieShelves({required this.movieId, required this.shelfIds});
}
