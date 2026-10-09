import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import 'package:movies_data/datasources/remote/movies_remote_data_source.dart';
import 'package:movies_data/models/remote/remote_movie_list.dart';
import 'package:movies_data/models/remote/remote_movie_list_detail.dart';
import 'package:movies_data/models/remote/remote_movie_list_listing.dart';
import 'package:movies_data/models/remote/remote_movie_detail.dart';
import 'package:movies_data/models/remote/remote_movie_review.dart';
import 'package:movies_data/models/remote/remote_movie_review_listing.dart';
import 'package:movies_data/models/remote/remote_country.dart';
import 'package:movies_data/models/remote/remote_genre.dart';
import 'package:movies_data/models/remote/remote_language.dart';
import 'package:movies_data/models/remote/remote_movie_listing.dart';

@injectable
class MoviesRemoteDataSourceImpl implements MoviesRemoteDataSource {
  final HttpClient _httpClient;

  MoviesRemoteDataSourceImpl(@Named('backend') this._httpClient);

  @override
  Future<Result<RemoteMovieListing>> getTrendingMovieList({
    required int page,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '/movies/trending',
      queryParams: {'page': page},
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) =>
        Success(RemoteMovieListing.fromJson(data)),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteMovieDetail>> getMovieDetail({
    required int movieId,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '/movies',
      queryParams: {'id': movieId},
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) =>
        Success(RemoteMovieDetail.fromJson(data)),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteMovieReviewListing>> getMovieReviews({
    required int page,
    String? userId,
    int? movieId,
  }) async {
    if (movieId != null) {
      final result = await _httpClient.get<Map<String, dynamic>>(
        '/movies/$movieId/reviews',
        queryParams: {'page': page},
      );

      return switch (result) {
        Success<Map<String, dynamic>>(:final data) =>
          Success(RemoteMovieReviewListing.fromJson(data)),
        Failure<Map<String, dynamic>>(:final error) => Failure(error),
      };
    }

    final queryParams = <String, dynamic>{'page': page};
    if (userId != null) queryParams['userId'] = userId;

    final result = await _httpClient.get<Map<String, dynamic>>(
      '/movies/reviews',
      queryParams: queryParams,
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) =>
        Success(RemoteMovieReviewListing.fromJson(data)),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteMovieReview>> getReviewDetails({
    required String reviewId,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '/reviews/$reviewId',
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) =>
        Success(RemoteMovieReview.fromJson(data)),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> likeReview({required String reviewId}) async {
    final result = await _httpClient.post<Map<String, dynamic>>(
      '/reviews/$reviewId/like',
    );

    return switch (result) {
      Success<Map<String, dynamic>>() => const Success(null),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> unlikeReview({required String reviewId}) async {
    final result = await _httpClient.post<Map<String, dynamic>>(
      '/reviews/$reviewId/unlike',
    );

    return switch (result) {
      Success<Map<String, dynamic>>() => const Success(null),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> likeMovie({required int movieId}) async {
    final result = await _httpClient.post<dynamic>(
      '/movies/$movieId/like',
    );

    return switch (result) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> unlikeMovie({required int movieId}) async {
    final result = await _httpClient.post<dynamic>(
      '/movies/$movieId/unlike',
    );

    return switch (result) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteMovieListListing>> getMovieLists({
    required int page,
    String? userId,
  }) async {
    final queryParams = <String, dynamic>{'page': page};
    if (userId != null) queryParams['userId'] = userId;

    final result = await _httpClient.get<Map<String, dynamic>>(
      '/movies/lists',
      queryParams: queryParams,
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) =>
        Success(RemoteMovieListListing.fromJson(data)),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteMovieListDetail>> getMovieListDetail({
    required int listId,
    required int page,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '/movies/lists/$listId',
      queryParams: {'page': page},
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) =>
        Success(RemoteMovieListDetail.fromJson(data)),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteMovieListing>> searchMovies({
    required String query,
    required int page,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '/movies/search',
      queryParams: {'query': query, 'page': page},
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) =>
        Success(RemoteMovieListing.fromJson(data)),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteMovieListing>> discoverMovies({
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
    final queryParams = <String, dynamic>{'page': page};
    if (primaryReleaseYear != null) queryParams['year'] = primaryReleaseYear;
    if (releaseDateGte != null) queryParams['release_date_gte'] = releaseDateGte;
    if (releaseDateLte != null) queryParams['release_date_lte'] = releaseDateLte;
    if (sortBy != null) queryParams['sort_by'] = sortBy;
    if (withGenres != null) queryParams['with_genres'] = withGenres;
    if (withOriginalLanguage != null) {
      queryParams['with_original_language'] = withOriginalLanguage;
    }
    if (withOriginCountry != null) {
      queryParams['with_origin_country'] = withOriginCountry;
    }
    if (minimumVoteCount != null) {
      queryParams['vote_count_gte'] = minimumVoteCount;
    }

    final result = await _httpClient.get<Map<String, dynamic>>(
      '/movies/discover',
      queryParams: queryParams,
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) =>
        Success(RemoteMovieListing.fromJson(data)),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<RemoteGenre>>> getGenres() async {
    final result = await _httpClient.get<List<dynamic>>(
      '/movies/genres',
    );

    return switch (result) {
      Success<List<dynamic>>(:final data) => Success(
          data
              .map((genre) =>
                  RemoteGenre.fromJson(genre as Map<String, dynamic>))
              .toList(),
        ),
      Failure<List<dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<RemoteCountry>>> getCountries() async {
    final result = await _httpClient.get<List<dynamic>>(
      '/movies/countries',
    );

    return switch (result) {
      Success<List<dynamic>>(:final data) => Success(
          data
              .map((country) =>
                  RemoteCountry.fromJson(country as Map<String, dynamic>))
              .toList()
            ..sort((first, second) =>
                first.englishName.compareTo(second.englishName)),
        ),
      Failure<List<dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<RemoteLanguage>>> getLanguages() async {
    final result = await _httpClient.get<List<dynamic>>(
      '/movies/languages',
    );

    return switch (result) {
      Success<List<dynamic>>(:final data) => Success(
          data
              .map((language) =>
                  RemoteLanguage.fromJson(language as Map<String, dynamic>))
              .toList(),
        ),
      Failure<List<dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteMovieListing>> getUserFavoriteMovies({
    required String userId,
    required int page,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '/movies/favorites/$userId',
      queryParams: {'page': page},
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) =>
        Success(RemoteMovieListing.fromJson(data)),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteMovieListing>> getUserWatchList({
    required String userId,
    required int page,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '/movies/watchlist/$userId',
      queryParams: {'page': page},
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) =>
        Success(RemoteMovieListing.fromJson(data)),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteMovieListListing>> getFeaturedLists({
    required int page,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '/movies/lists/featured',
      queryParams: {'page': page},
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) =>
        Success(RemoteMovieListListing.fromJson(data)),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteMovieList>> createMovieList({
    required String name,
    String? description,
    List<int> movieIds = const [],
  }) async {
    final result = await _httpClient.post<Map<String, dynamic>>(
      '/movies/lists',
      body: {
        'name': name,
        if (description != null) 'description': description,
        if (movieIds.isNotEmpty) 'movieIds': movieIds,
      },
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) =>
        Success(RemoteMovieList.fromJson(data)),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> deleteMovieList({required int listId}) async {
    final result = await _httpClient.delete<dynamic>(
      '/movies/lists/$listId',
    );

    return switch (result) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> addMovieToList({
    required int listId,
    required int movieId,
  }) async {
    final result = await _httpClient.post<dynamic>(
      '/movies/lists/$listId/movies',
      body: {'movieId': movieId},
    );

    return switch (result) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> removeMovieFromList({
    required int listId,
    required int movieId,
  }) async {
    final result = await _httpClient.delete<dynamic>(
      '/movies/lists/$listId/movies/$movieId',
    );

    return switch (result) {
      Success() => const Success(null),
      Failure(:final error) => Failure(error),
    };
  }
}
