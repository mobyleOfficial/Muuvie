import 'package:core/core.dart';

import 'package:movies_domain/repositories/movies_repository.dart';

class LikeMovie extends UseCase<int, Result<void>> {
  final MoviesRepository _moviesRepository;

  LikeMovie(this._moviesRepository);

  @override
  Future<Result<void>> call([int? params]) async =>
      _moviesRepository.likeMovie(movieId: params ?? 0);
}
