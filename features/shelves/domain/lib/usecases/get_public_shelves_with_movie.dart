import 'package:core/core.dart';
import 'package:shelves_domain/models/models.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class PublicShelvesParams {
  /// Database id of the movie.
  final int movieId;
  final int page;

  const PublicShelvesParams({required this.movieId, this.page = 1});
}

/// "Está em N estantes" of the movie detail: public custom shelves of anyone
/// that hold the movie, last updated first (B13.2).
class GetPublicShelvesWithMovie
    extends UseCase<PublicShelvesParams, Result<Paged<PublicShelf>>> {
  final ShelvesRepository _repository;

  GetPublicShelvesWithMovie(this._repository);

  @override
  Future<Result<Paged<PublicShelf>>> call([PublicShelvesParams? params]) =>
      _repository.getPublicShelvesWithMovie(
        movieId: params!.movieId,
        page: params.page,
      );
}
