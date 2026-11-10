import 'package:core/core.dart';

import 'package:movies_domain/models/similar_movie.dart';
import 'package:movies_domain/repositories/movies_repository.dart';

/// The similar movies of one movie, by its database id, without the rest of
/// its detail, most similar first: what the Universo de Filmes loads for
/// each star system.
class GetSimilarMovies extends UseCase<int, Result<List<SimilarMovie>>> {
  final MoviesRepository _moviesRepository;

  GetSimilarMovies(this._moviesRepository);

  @override
  Future<Result<List<SimilarMovie>>> call([int? movieId]) =>
      _moviesRepository.getSimilarMovies(movieId: movieId ?? 0);
}
