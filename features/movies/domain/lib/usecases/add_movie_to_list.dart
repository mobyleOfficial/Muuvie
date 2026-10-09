import 'package:core/core.dart';

import 'package:movies_domain/repositories/movies_repository.dart';

class AddMovieToListParams {
  final int listId;
  final int movieId;

  const AddMovieToListParams({required this.listId, required this.movieId});
}

class AddMovieToList
    extends UseCase<AddMovieToListParams, Result<void>> {
  final MoviesRepository _moviesRepository;

  AddMovieToList(this._moviesRepository);

  @override
  Future<Result<void>> call([AddMovieToListParams? params]) async =>
      _moviesRepository.addMovieToList(
        listId: params!.listId,
        movieId: params.movieId,
      );
}
