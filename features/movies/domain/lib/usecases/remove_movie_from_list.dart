import 'package:core/core.dart';

import 'package:movies_domain/repositories/movies_repository.dart';

class RemoveMovieFromListParams {
  final int listId;
  final int movieId;

  const RemoveMovieFromListParams({
    required this.listId,
    required this.movieId,
  });
}

class RemoveMovieFromList
    extends UseCase<RemoveMovieFromListParams, Result<void>> {
  final MoviesRepository _moviesRepository;

  RemoveMovieFromList(this._moviesRepository);

  @override
  Future<Result<void>> call([RemoveMovieFromListParams? params]) async =>
      _moviesRepository.removeMovieFromList(
        listId: params!.listId,
        movieId: params.movieId,
      );
}
