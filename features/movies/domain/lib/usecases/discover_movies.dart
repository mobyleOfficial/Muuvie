import 'package:core/core.dart';

import 'package:movies_domain/models/movie_listing.dart';
import 'package:movies_domain/repositories/movies_repository.dart';

class DiscoverMoviesParams {
  final int page;
  final int? primaryReleaseYear;
  final String? releaseDateGte;
  final String? releaseDateLte;
  final String? sortBy;
  final String? withGenres;
  final String? withOriginalLanguage;
  final String? withOriginCountry;
  final int? minimumVoteCount;

  const DiscoverMoviesParams({
    this.page = 1,
    this.primaryReleaseYear,
    this.releaseDateGte,
    this.releaseDateLte,
    this.sortBy,
    this.withGenres,
    this.withOriginalLanguage,
    this.withOriginCountry,
    this.minimumVoteCount,
  });
}

class DiscoverMovies
    extends UseCase<DiscoverMoviesParams, Result<MovieListing>> {
  final MoviesRepository _moviesRepository;

  DiscoverMovies(this._moviesRepository);

  @override
  Future<Result<MovieListing>> call([DiscoverMoviesParams? params]) async =>
      _moviesRepository.discoverMovies(
        page: params?.page ?? 1,
        primaryReleaseYear: params?.primaryReleaseYear,
        releaseDateGte: params?.releaseDateGte,
        releaseDateLte: params?.releaseDateLte,
        sortBy: params?.sortBy,
        withGenres: params?.withGenres,
        withOriginalLanguage: params?.withOriginalLanguage,
        withOriginCountry: params?.withOriginCountry,
        minimumVoteCount: params?.minimumVoteCount,
      );
}
