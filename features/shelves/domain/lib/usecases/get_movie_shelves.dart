import 'package:core/core.dart';
import 'package:shelves_domain/models/movie_shelves.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

/// The current user's shelves that hold the movie.
class GetMovieShelves extends UseCase<int, Result<MovieShelves>> {
  final ShelvesRepository _repository;

  GetMovieShelves(this._repository);

  @override
  Future<Result<MovieShelves>> call([int? movieId]) =>
      _repository.getMovieShelves(movieId!);
}
