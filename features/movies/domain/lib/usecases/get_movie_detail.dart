import 'package:core/core.dart';
import 'package:movies_domain/models/movie.dart';
import 'package:movies_domain/repositories/movies_repository.dart';

class GetMovieDetailParams {
  final int movieId;

  const GetMovieDetailParams({required this.movieId});
}

class GetMovieDetail extends UseCase<GetMovieDetailParams, Result<Movie>> {
  final MoviesRepository _moviesRepository;

  GetMovieDetail(this._moviesRepository);

  @override
  Future<Result<Movie>> call([GetMovieDetailParams? params]) async {
    return _moviesRepository.getMovieDetail(
      movieId: params?.movieId ?? 0,
    );
  }
}
