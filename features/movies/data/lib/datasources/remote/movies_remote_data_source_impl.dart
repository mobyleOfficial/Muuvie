import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import 'package:movies_data/datasources/remote/movies_remote_data_source.dart';
import 'package:movies_data/models/remote/remote_movie_detail.dart';
import 'package:movies_data/models/remote/remote_country.dart';
import 'package:movies_data/models/remote/remote_genre.dart';
import 'package:movies_data/models/remote/remote_language.dart';
import 'package:movies_data/models/remote/remote_movie_listing.dart';

@injectable
class MoviesRemoteDataSourceImpl implements MoviesRemoteDataSource {
  static const _base = '/api/v1/movies';
  static const _discover = '/api/v1/discover/movies';
  static const _pageSize = 20;

  final HttpClient _httpClient;

  MoviesRemoteDataSourceImpl(@Named('backend') this._httpClient);

  @override
  Future<Result<RemoteMovieDetail>> getMovieDetail({
    required int movieId,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      _base,
      queryParams: {'id': movieId},
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) => Success(
        RemoteMovieDetail.fromJson(data),
      ),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteMovieListing>> searchMovies({
    required String query,
    required int page,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '$_base/search',
      queryParams: {'query': query, 'page': page},
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) => Success(
        RemoteMovieListing.fromJson(data),
      ),
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
    if (releaseDateGte != null) {
      queryParams['release_date_gte'] = releaseDateGte;
    }
    if (releaseDateLte != null) {
      queryParams['release_date_lte'] = releaseDateLte;
    }
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
      '$_base/discover',
      queryParams: queryParams,
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) => Success(
        RemoteMovieListing.fromJson(data),
      ),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<RemoteGenre>>> getGenres() async {
    final result = await _httpClient.get<List<dynamic>>('$_base/genres');

    return switch (result) {
      Success<List<dynamic>>(:final data) => Success(
        data
            .map((genre) => RemoteGenre.fromJson(genre as Map<String, dynamic>))
            .toList(),
      ),
      Failure<List<dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<RemoteCountry>>> getCountries() async {
    final result = await _httpClient.get<List<dynamic>>('$_base/countries');

    return switch (result) {
      Success<List<dynamic>>(:final data) => Success(
        data
            .map(
              (country) =>
                  RemoteCountry.fromJson(country as Map<String, dynamic>),
            )
            .toList()
          ..sort(
            (first, second) => _sortKey(
              first.name ?? first.englishName,
            ).compareTo(_sortKey(second.name ?? second.englishName)),
          ),
      ),
      Failure<List<dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<RemoteLanguage>>> getLanguages() async {
    final result = await _httpClient.get<List<dynamic>>('$_base/languages');

    return switch (result) {
      Success<List<dynamic>>(:final data) => Success(
        data
            .map(
              (language) =>
                  RemoteLanguage.fromJson(language as Map<String, dynamic>),
            )
            .toList()
          ..sort(
            (first, second) => _sortKey(
              first.name ?? first.englishName,
            ).compareTo(_sortKey(second.name ?? second.englishName)),
          ),
      ),
      Failure<List<dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteMovieListing>> getTrendingOnMuuvie({required int page}) =>
      _getPage('$_discover/trending', page);

  @override
  Future<Result<RemoteMovieListing>> getMostLovedOnMuuvie({
    required int page,
  }) => _getPage('$_discover/loved', page);

  Future<Result<RemoteMovieListing>> _getPage(String path, int page) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      path,
      queryParams: {'page': page, 'limit': _pageSize},
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) => Success(
        RemoteMovieListing.fromJson(data),
      ),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  /// Sorts "Áustria" next to "Austrália", not after "Zâmbia".
  static String _sortKey(String name) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
    const to = 'aaaaaeeeeiiiiooooouuuucn';
    final lower = name.toLowerCase();
    final buffer = StringBuffer();
    for (final char in lower.split('')) {
      final index = from.indexOf(char);
      buffer.write(index < 0 ? char : to[index]);
    }
    return buffer.toString();
  }
}
