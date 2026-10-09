import 'package:core/core.dart';

import 'package:movies_domain/repositories/movies_repository.dart';

class DeleteMovieList extends UseCase<int, Result<void>> {
  final MoviesRepository _moviesRepository;

  DeleteMovieList(this._moviesRepository);

  @override
  Future<Result<void>> call([int? params]) async =>
      _moviesRepository.deleteMovieList(listId: params!);
}
