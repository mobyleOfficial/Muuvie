import 'package:core/core.dart';
import 'package:shelves_domain/models/models.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

/// "Quero ver" in one tap (F5.8): finds the system shelf and adds the movie,
/// which also takes it off "Já assisti".
class AddMovieToWatchlist extends UseCase<int, Result<MovieShelves>> {
  // The system shelves sit at the top of the profile order; a few pages are enough.
  static const _maxPages = 3;

  final ShelvesRepository _repository;

  AddMovieToWatchlist(this._repository);

  @override
  Future<Result<MovieShelves>> call([int? movieId]) async {
    for (var page = 1; page <= _maxPages; page++) {
      final result = await _repository.getUserShelves(userId: 'me', page: page);
      switch (result) {
        case Failure(:final error):
          return Failure(error);
        case Success(:final data):
          for (final shelf in data.items) {
            if (shelf.systemType == SystemShelfType.watchlist) {
              return _repository.addMovieToShelves(
                movieId: movieId!,
                shelfIds: [shelf.id],
              );
            }
          }
          if (!data.hasNext) return const Failure(AppError.notFound);
      }
    }
    return const Failure(AppError.notFound);
  }
}
