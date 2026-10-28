import 'package:core/core.dart';
import 'package:movies_domain/repositories/movies_repository.dart';

/// Removes one recent search by id, or clears them all when there is no id.
class RemoveRecentSearches extends UseCase<int, Result<void>> {
  final MoviesRepository _moviesRepository;

  RemoveRecentSearches(this._moviesRepository);

  @override
  Future<Result<void>> call([int? params]) async =>
      _moviesRepository.removeRecentSearches(id: params);
}
