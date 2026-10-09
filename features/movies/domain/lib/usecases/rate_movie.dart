import 'package:core/core.dart';

import 'package:movies_domain/repositories/movies_repository.dart';

class RateMovieParams {
  final int movieId;
  final double rating;

  const RateMovieParams({required this.movieId, required this.rating});
}

class RateMovie extends UseCase<RateMovieParams, Result<void>> {
  final MoviesRepository _moviesRepository;

  RateMovie(this._moviesRepository);

  @override
  Future<Result<void>> call([RateMovieParams? params]) async =>
      _moviesRepository.rateMovie(
        movieId: params?.movieId ?? 0,
        rating: params?.rating ?? 0,
      );
}
