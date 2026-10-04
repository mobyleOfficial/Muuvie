import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:movies_domain/domain.dart';

import 'package:movies_data/datasources/local/movies_local_data_source.dart';
import 'package:movies_data/datasources/remote/movies_remote_data_source.dart';
@LazySingleton(as: MoviesRepository)
class MoviesRepositoryImpl implements MoviesRepository {
  final MoviesRemoteDataSource _dataSource;
  final MoviesLocalDataSource _localDataSource;

  MoviesRepositoryImpl(this._dataSource, this._localDataSource);

  @override
  Future<Result<MovieListing>> getTrendingMovieList({
    required int page,
  }) async {
    final result = await _dataSource.getTrendingMovieList(page: page);

    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<Movie>> getMovieDetail({required int movieId}) async {
    final result = await _dataSource.getMovieDetail(movieId: movieId);

    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<MovieReviewListing>> getMovieReviews({
    required int page,
    String? userId,
    int? movieId,
  }) async {
    final result = await _dataSource.getMovieReviews(page: page, userId: userId, movieId: movieId);

    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<MovieReview>> getReviewDetails({
    required String reviewId,
  }) async {
    final result = await _dataSource.getReviewDetails(reviewId: reviewId);

    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> likeReview({required String reviewId}) async {
    final result = await _dataSource.likeReview(reviewId: reviewId);

    return switch (result) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> unlikeReview({required String reviewId}) async {
    final result = await _dataSource.unlikeReview(reviewId: reviewId);

    return switch (result) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<MovieListListing>> getMovieLists({
    required int page,
    String? userId,
  }) async {
    final result = await _dataSource.getMovieLists(page: page, userId: userId);

    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<MovieList>> getMovieListDetail({
    required int listId,
    required int page,
  }) async {
    final result = await _dataSource.getMovieListDetail(listId: listId, page: page);

    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<MovieListing>> searchMovies({
    required String query,
    required int page,
  }) async {
    final result = await _dataSource.searchMovies(query: query, page: page);

    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }

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
  }) async {
    final result = await _dataSource.discoverMovies(
      page: page,
      primaryReleaseYear: primaryReleaseYear,
      releaseDateGte: releaseDateGte,
      releaseDateLte: releaseDateLte,
      sortBy: sortBy,
      withGenres: withGenres,
      withOriginalLanguage: withOriginalLanguage,
      withOriginCountry: withOriginCountry,
      minimumVoteCount: minimumVoteCount,
    );

    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<Genre>>> getGenres() async {
    final result = await _dataSource.getGenres();

    return switch (result) {
      Success(:final data) =>
        Success(data.map((genre) => genre.toDomain()).toList()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<Country>>> getCountries() async {
    final result = await _dataSource.getCountries();

    return switch (result) {
      Success(:final data) =>
        Success(data.map((country) => country.toDomain()).toList()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<Language>>> getLanguages() async {
    final result = await _dataSource.getLanguages();

    return switch (result) {
      Success(:final data) =>
        Success(data.map((language) => language.toDomain()).toList()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Result<void> addRecentSearch({required String query}) =>
      _localDataSource.addRecentSearch(query);

  @override
  Stream<List<RecentSearch>> observeRecentSearches() =>
      _localDataSource.watchRecentSearches().map(
            (localSearches) =>
                localSearches.map((search) => search.toDomain()).toList(),
          );

  @override
  Future<Result<MovieListing>> getUserWatchList({
    required String userId,
    required int page,
  }) async {
    final result = await _dataSource.getUserWatchList(
      userId: userId,
      page: page,
    );

    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<MovieListListing>> getFeaturedLists({
    required int page,
  }) async {
    final result = await _dataSource.getFeaturedLists(page: page);

    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }
}
