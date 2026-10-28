import 'package:core/core.dart';

import 'package:movies_domain/models/movie.dart';
import 'package:movies_domain/models/recent_search.dart';
import 'package:movies_domain/models/country.dart';
import 'package:movies_domain/models/genre.dart';
import 'package:movies_domain/models/language.dart';
import 'package:movies_domain/models/movie_listing.dart';

abstract interface class MoviesRepository {
  Future<Result<Movie>> getMovieDetail({required int movieId});
  Future<Result<MovieListing>> searchMovies({
    required String query,
    required int page,
  });
  Future<Result<MovieListing>> discoverMovies({
    required int page,
    int? primaryReleaseYear,
    String? releaseDateGte,
    String? releaseDateLte,
    String? sortBy,
    String? withGenres,
    String? withOriginalLanguage,
    String? withOriginCountry,
    int? minimumVoteCount,
  });
  Future<Result<List<Genre>>> getGenres();
  Future<Result<List<Country>>> getCountries();
  Future<Result<List<Language>>> getLanguages();

  /// Movies with the most people logging them publicly in the last 7 days.
  Future<Result<MovieListing>> getTrendingOnMuuvie({required int page});

  /// Movies with the most Favoritado and Adorei labels.
  Future<Result<MovieListing>> getMostLovedOnMuuvie({required int page});
  Result<void> addRecentSearch({required String query});
  Stream<List<RecentSearch>> observeRecentSearches();

  /// One search by id, or all of them when [id] is null.
  Result<void> removeRecentSearches({int? id});
}
