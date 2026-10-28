import 'package:core/core.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class AddMoviesToShelfParams {
  final int shelfId;
  final List<int> movieIds;

  const AddMoviesToShelfParams({required this.shelfId, required this.movieIds});
}

/// Adds movies to a shelf, stopping at the first failure.
class AddMoviesToShelf extends UseCase<AddMoviesToShelfParams, Result<void>> {
  final ShelvesRepository _repository;

  AddMoviesToShelf(this._repository);

  @override
  Future<Result<void>> call([AddMoviesToShelfParams? params]) async {
    for (final movieId in params!.movieIds.toSet()) {
      final result = await _repository.addMovieToShelf(
        shelfId: params.shelfId,
        movieId: movieId,
      );
      if (result is Failure<void>) return result;
    }
    return const Success(null);
  }
}
