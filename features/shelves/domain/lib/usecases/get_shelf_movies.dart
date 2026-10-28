import 'package:core/core.dart';
import 'package:shelves_domain/models/models.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class GetShelfMoviesParams {
  final int shelfId;
  final ShelfMovieFilter filter;
  final int page;

  const GetShelfMoviesParams({
    required this.shelfId,
    this.filter = ShelfMovieFilter.none,
    this.page = 1,
  });
}

class GetShelfMovies
    extends UseCase<GetShelfMoviesParams, Result<Paged<ShelfMovie>>> {
  final ShelvesRepository _repository;

  GetShelfMovies(this._repository);

  @override
  Future<Result<Paged<ShelfMovie>>> call([GetShelfMoviesParams? params]) =>
      _repository.getShelfMovies(
        shelfId: params!.shelfId,
        filter: params.filter,
        page: params.page,
      );
}
