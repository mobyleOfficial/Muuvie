import 'package:core/core.dart';

import 'package:movies_domain/models/movie_listing.dart';
import 'package:movies_domain/repositories/movies_repository.dart';

/// "Em alta no Muuvie" (F14.1): the page of movies, 1 by default.
class GetTrendingOnMuuvie extends UseCase<int, Result<MovieListing>> {
  final MoviesRepository _moviesRepository;

  GetTrendingOnMuuvie(this._moviesRepository);

  @override
  Future<Result<MovieListing>> call([int? page]) =>
      _moviesRepository.getTrendingOnMuuvie(page: page ?? 1);
}

/// "Mais amados no Muuvie" (F14.1): the page of movies, 1 by default.
class GetMostLovedOnMuuvie extends UseCase<int, Result<MovieListing>> {
  final MoviesRepository _moviesRepository;

  GetMostLovedOnMuuvie(this._moviesRepository);

  @override
  Future<Result<MovieListing>> call([int? page]) =>
      _moviesRepository.getMostLovedOnMuuvie(page: page ?? 1);
}
