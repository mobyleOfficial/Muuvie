import 'package:core/core.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class RemoveMovieFromShelfParams {
  final int shelfId;
  final int movieId;

  const RemoveMovieFromShelfParams({
    required this.shelfId,
    required this.movieId,
  });
}

/// Removes a movie from a shelf. From "Já assisti" it also unmarks it as watched.
class RemoveMovieFromShelf
    extends UseCase<RemoveMovieFromShelfParams, Result<void>> {
  final ShelvesRepository _repository;

  RemoveMovieFromShelf(this._repository);

  @override
  Future<Result<void>> call([RemoveMovieFromShelfParams? params]) => _repository
      .removeMovieFromShelf(shelfId: params!.shelfId, movieId: params.movieId);
}
