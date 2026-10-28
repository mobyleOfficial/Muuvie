import 'package:core/core.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class ReorderShelfMoviesParams {
  final int shelfId;

  /// New manual order; movies left out keep their relative order after these.
  final List<int> movieIds;

  const ReorderShelfMoviesParams({
    required this.shelfId,
    required this.movieIds,
  });
}

class ReorderShelfMovies
    extends UseCase<ReorderShelfMoviesParams, Result<void>> {
  final ShelvesRepository _repository;

  ReorderShelfMovies(this._repository);

  @override
  Future<Result<void>> call([ReorderShelfMoviesParams? params]) => _repository
      .reorderShelfMovies(shelfId: params!.shelfId, movieIds: params.movieIds);
}
