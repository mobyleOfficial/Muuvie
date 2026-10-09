import 'package:core/core.dart';
import 'package:movies_domain/domain.dart';

/// Hand-rolled fake of [MoviesRepository] for use in unit and widget tests.
/// Avoids introducing a new mocking library; tests configure the expected
/// `*Result` field before invoking the use case under test.
class FakeMoviesRepository implements MoviesRepository {
  Result<MovieReview> reviewDetailsResult =
      const Failure(AppError.unknown);
  Result<void> likeReviewResult = const Success(null);
  Result<void> unlikeReviewResult = const Success(null);
  Result<MovieReviewListing> movieReviewsResult =
      const Failure(AppError.unknown);

  String? lastGetReviewDetailsId;
  String? lastLikeReviewId;
  String? lastUnlikeReviewId;

  @override
  Future<Result<MovieReview>> getReviewDetails({required String reviewId}) async {
    lastGetReviewDetailsId = reviewId;
    return reviewDetailsResult;
  }

  @override
  Future<Result<void>> likeReview({required String reviewId}) async {
    lastLikeReviewId = reviewId;
    return likeReviewResult;
  }

  @override
  Future<Result<void>> unlikeReview({required String reviewId}) async {
    lastUnlikeReviewId = reviewId;
    return unlikeReviewResult;
  }

  @override
  Future<Result<MovieReviewListing>> getMovieReviews({
    required int page,
    String? userId,
    int? movieId,
  }) async =>
      movieReviewsResult;

  // The remaining methods are unused by tests in this suite.
  @override
  Future<Result<MovieListing>> getTrendingMovieList({required int page}) =>
      throw UnimplementedError();

  @override
  Future<Result<Movie>> getMovieDetail({required int movieId}) =>
      throw UnimplementedError();

  @override
  Future<Result<MovieListListing>> getMovieLists({
    required int page,
    String? userId,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<MovieList>> getMovieListDetail({
    required int listId,
    required int page,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<MovieListing>> searchMovies({
    required String query,
    required int page,
  }) =>
      throw UnimplementedError();

  @override
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
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<List<Genre>>> getGenres() => throw UnimplementedError();

  @override
  Future<Result<List<Country>>> getCountries() => throw UnimplementedError();

  @override
  Future<Result<List<Language>>> getLanguages() => throw UnimplementedError();

  @override
  Result<void> addRecentSearch({required String query}) =>
      throw UnimplementedError();

  @override
  Stream<List<RecentSearch>> observeRecentSearches() =>
      throw UnimplementedError();

  @override
  Future<Result<MovieListing>> getUserWatchList({
    required String userId,
    required int page,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<MovieListListing>> getFeaturedLists({required int page}) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> likeMovie({required int movieId}) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> unlikeMovie({required int movieId}) =>
      throw UnimplementedError();

  @override
  Future<Result<MovieList>> createMovieList({
    required String name,
    String? description,
    List<int> movieIds = const [],
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> deleteMovieList({required int listId}) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> addMovieToList({
    required int listId,
    required int movieId,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> removeMovieFromList({
    required int listId,
    required int movieId,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> rateMovie({
    required int movieId,
    required double rating,
  }) =>
      throw UnimplementedError();

  @override
  Future<Result<void>> setMovieStatus({
    required int movieId,
    required String status,
  }) =>
      throw UnimplementedError();
}
