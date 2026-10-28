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
  Future<Result<Movie>> getMovieDetail({required int movieId}) async {
    final result = await _dataSource.getMovieDetail(movieId: movieId);

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
  Future<Result<MovieListing>> getTrendingOnMuuvie({required int page}) async =>
      switch (await _dataSource.getTrendingOnMuuvie(page: page)) {
        Success(:final data) => Success(data.toDomain()),
        Failure(:final error) => Failure(error),
      };

  @override
  Future<Result<MovieListing>> getMostLovedOnMuuvie({
    required int page,
  }) async => switch (await _dataSource.getMostLovedOnMuuvie(page: page)) {
    Success(:final data) => Success(data.toDomain()),
    Failure(:final error) => Failure(error),
  };

  @override
  Future<Result<List<Genre>>> getGenres() async {
    final result = await _dataSource.getGenres();

    return switch (result) {
      Success(:final data) => Success(
        data.map((genre) => genre.toDomain()).toList(),
      ),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<Country>>> getCountries() async {
    final result = await _dataSource.getCountries();

    return switch (result) {
      Success(:final data) => Success(
        data.map((country) => country.toDomain()).toList(),
      ),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<Language>>> getLanguages() async {
    final result = await _dataSource.getLanguages();

    return switch (result) {
      Success(:final data) => Success(
        data.map((language) => language.toDomain()).toList(),
      ),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Result<void> addRecentSearch({required String query}) =>
      _localDataSource.addRecentSearch(query);

  @override
  Result<void> removeRecentSearches({int? id}) =>
      _localDataSource.removeRecentSearches(id: id);

  @override
  Stream<List<RecentSearch>> observeRecentSearches() =>
      _localDataSource.watchRecentSearches().map(
        (localSearches) =>
            localSearches.map((search) => search.toDomain()).toList(),
      );
}
