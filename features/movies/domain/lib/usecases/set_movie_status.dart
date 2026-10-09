import 'package:core/core.dart';

import 'package:movies_domain/repositories/movies_repository.dart';

class SetMovieStatusParams {
  final int movieId;
  final String status;

  const SetMovieStatusParams({required this.movieId, required this.status});
}

class SetMovieStatus extends UseCase<SetMovieStatusParams, Result<void>> {
  final MoviesRepository _moviesRepository;

  SetMovieStatus(this._moviesRepository);

  @override
  Future<Result<void>> call([SetMovieStatusParams? params]) async =>
      _moviesRepository.setMovieStatus(
        movieId: params?.movieId ?? 0,
        status: params?.status ?? '',
      );
}
