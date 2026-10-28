import 'package:core/core.dart';
import 'package:shelves_domain/models/movie_shelves.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class AddMovieToShelvesParams {
  final int movieId;
  final List<int> shelfIds;

  const AddMovieToShelvesParams({
    required this.movieId,
    required this.shelfIds,
  });
}

/// Adds one movie to several shelves in a single step (F1.4).
class AddMovieToShelves
    extends UseCase<AddMovieToShelvesParams, Result<MovieShelves>> {
  final ShelvesRepository _repository;

  AddMovieToShelves(this._repository);

  @override
  Future<Result<MovieShelves>> call([AddMovieToShelvesParams? params]) async {
    final value = params!;
    if (value.shelfIds.isEmpty) return const Failure(AppError.badRequest);
    return _repository.addMovieToShelves(
      movieId: value.movieId,
      shelfIds: value.shelfIds.toSet().toList(),
    );
  }
}
