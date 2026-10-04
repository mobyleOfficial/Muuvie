import 'package:core/core.dart';

import 'package:movies_domain/repositories/movies_repository.dart';

class UnlikeMovie extends UseCase<int, Result<void>> {
  final MoviesRepository _moviesRepository;

  UnlikeMovie(this._moviesRepository);

  @override
  Future<Result<void>> call([int? params]) async =>
      _moviesRepository.unlikeMovie(movieId: params ?? 0);
}
