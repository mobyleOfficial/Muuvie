import 'package:core/core.dart';

import 'package:movies_domain/models/movie_list.dart';
import 'package:movies_domain/repositories/movies_repository.dart';

class CreateMovieListParams {
  final String name;
  final String description;
  final List<int> movieIds;

  const CreateMovieListParams({
    required this.name,
    this.description = '',
    this.movieIds = const [],
  });
}

class CreateMovieList
    extends UseCase<CreateMovieListParams, Result<MovieList>> {
  final MoviesRepository _moviesRepository;

  CreateMovieList(this._moviesRepository);

  @override
  Future<Result<MovieList>> call([
    CreateMovieListParams? params,
  ]) async =>
      _moviesRepository.createMovieList(
        name: params!.name,
        description: params.description,
        movieIds: params.movieIds,
      );
}
