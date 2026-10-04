import 'package:core/core.dart';

import 'package:movies_domain/models/movie_list.dart';
import 'package:movies_domain/models/movie_list_listing.dart';
import 'package:movies_domain/models/movie.dart';
import 'package:movies_domain/models/movie_review.dart';
import 'package:movies_domain/models/movie_review_listing.dart';
import 'package:movies_domain/models/recent_search.dart';
import 'package:movies_domain/models/country.dart';
import 'package:movies_domain/models/genre.dart';
import 'package:movies_domain/models/language.dart';
import 'package:movies_domain/models/movie_listing.dart';

abstract interface class MoviesRepository {
  Future<Result<MovieListing>> getTrendingMovieList({required int page});
  Future<Result<Movie>> getMovieDetail({required int movieId});
  Future<Result<MovieReviewListing>> getMovieReviews({required int page, String? userId, int? movieId});
  Future<Result<MovieReview>> getReviewDetails({required String reviewId});
  Future<Result<void>> likeReview({required String reviewId});
  Future<Result<void>> unlikeReview({required String reviewId});
  Future<Result<MovieListListing>> getMovieLists({required int page, String? userId});
  Future<Result<MovieList>> getMovieListDetail({required int listId, required int page});
  Future<Result<MovieListing>> searchMovies({required String query, required int page});
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
  Result<void> addRecentSearch({required String query});
  Stream<List<RecentSearch>> observeRecentSearches();
  Future<Result<MovieListing>> getUserWatchList({required String userId, required int page});
  Future<Result<MovieListListing>> getFeaturedLists({required int page});
}
