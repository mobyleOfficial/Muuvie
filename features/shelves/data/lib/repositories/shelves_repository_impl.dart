import 'package:core/core.dart';
import 'package:shelves_data/datasources/shelves_remote_data_source.dart';
import 'package:shelves_data/models/models.dart';
import 'package:shelves_domain/models/models.dart';
import 'package:shelves_domain/repositories/shelves_repository.dart';

class ShelvesRepositoryImpl implements ShelvesRepository {
  final ShelvesRemoteDataSource _remoteDataSource;

  ShelvesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<Paged<Shelf>>> getUserShelves({
    required String userId,
    required int page,
    bool profile = false,
  }) async => _shelfPage(
    await _remoteDataSource.getUserShelves(
      userId: userId,
      page: page,
      profile: profile,
    ),
  );

  @override
  Future<Result<Paged<Shelf>>> searchShelves({
    required String query,
    required int page,
  }) async => _shelfPage(
    await _remoteDataSource.searchShelves(query: query, page: page),
  );

  @override
  Future<Result<Paged<Shelf>>> discoverShelves({
    String? query,
    required int page,
  }) async => _shelfPage(
    await _remoteDataSource.discoverShelves(query: query, page: page),
  );

  @override
  Future<Result<Shelf>> getShelf(int shelfId) async =>
      _shelf(await _remoteDataSource.getShelf(shelfId));

  @override
  Future<Result<Paged<Shelf>>> getSavedShelves({required int page}) async =>
      _shelfPage(await _remoteDataSource.getSavedShelves(page: page));

  @override
  Future<Result<void>> setShelfSaved({
    required int shelfId,
    required bool saved,
  }) => _remoteDataSource.setShelfSaved(shelfId: shelfId, saved: saved);

  @override
  Future<Result<Shelf>> createShelf(ShelfDraft draft) async =>
      _shelf(await _remoteDataSource.createShelf(draft));

  @override
  Future<Result<Shelf>> updateShelf(int shelfId, ShelfDraft draft) async =>
      _shelf(await _remoteDataSource.updateShelf(shelfId, draft));

  @override
  Future<Result<void>> deleteShelf(int shelfId) =>
      _remoteDataSource.deleteShelf(shelfId);

  @override
  Future<Result<Paged<ShelfMovie>>> getShelfMovies({
    required int shelfId,
    required ShelfMovieFilter filter,
    required int page,
  }) async => switch (await _remoteDataSource.getShelfMovies(
    shelfId: shelfId,
    filter: filter,
    page: page,
  )) {
    Success(:final data) => Success(data.toDomain((movie) => movie.toDomain())),
    Failure(:final error) => Failure(error),
  };

  @override
  Future<Result<void>> addMovieToShelf({
    required int shelfId,
    required int movieId,
  }) => _remoteDataSource.addMovieToShelf(shelfId: shelfId, movieId: movieId);

  @override
  Future<Result<void>> removeMovieFromShelf({
    required int shelfId,
    required int movieId,
  }) => _remoteDataSource.removeMovieFromShelf(
    shelfId: shelfId,
    movieId: movieId,
  );

  @override
  Future<Result<void>> transferShelfMovies({
    required int shelfId,
    required int targetShelfId,
    required ShelfTransferMode mode,
    required List<int> movieIds,
  }) => _remoteDataSource.transferShelfMovies(
    shelfId: shelfId,
    targetShelfId: targetShelfId,
    mode: mode,
    movieIds: movieIds,
  );

  @override
  Future<Result<void>> sortShelf({
    required int shelfId,
    required ShelfSort sortMode,
    required bool applyOnce,
  }) => _remoteDataSource.sortShelf(
    shelfId: shelfId,
    sortMode: sortMode,
    applyOnce: applyOnce,
  );

  @override
  Future<Result<void>> reorderShelfMovies({
    required int shelfId,
    required List<int> movieIds,
  }) => _remoteDataSource.reorderShelfMovies(
    shelfId: shelfId,
    movieIds: movieIds,
  );

  @override
  Future<Result<void>> reorderShelves({
    required List<int> shelfIds,
    List<int>? pinnedIds,
  }) => _remoteDataSource.reorderShelves(
    shelfIds: shelfIds,
    pinnedIds: pinnedIds,
  );

  @override
  Future<Result<MovieShelves>> getMovieShelves(int movieId) async =>
      _movieShelves(await _remoteDataSource.getMovieShelves(movieId));

  @override
  Future<Result<Paged<PublicShelf>>> getPublicShelvesWithMovie({
    required int movieId,
    required int page,
  }) async => switch (await _remoteDataSource.getPublicShelvesWithMovie(
    movieId: movieId,
    page: page,
  )) {
    Success(:final data) => Success(data.toDomain((item) => item.toDomain())),
    Failure(:final error) => Failure(error),
  };

  @override
  Future<Result<MovieShelves>> addMovieToShelves({
    required int movieId,
    required List<int> shelfIds,
  }) async => _movieShelves(
    await _remoteDataSource.addMovieToShelves(
      movieId: movieId,
      shelfIds: shelfIds,
    ),
  );

  Result<Paged<Shelf>> _shelfPage(Result<RemotePage<RemoteShelf>> result) =>
      switch (result) {
        Success(:final data) => Success(
          data.toDomain((shelf) => shelf.toDomain()),
        ),
        Failure(:final error) => Failure(error),
      };

  Result<Shelf> _shelf(Result<RemoteShelf> result) => switch (result) {
    Success(:final data) => Success(data.toDomain()),
    Failure(:final error) => Failure(error),
  };

  Result<MovieShelves> _movieShelves(Result<RemoteMovieShelves> result) =>
      switch (result) {
        Success(:final data) => Success(data.toDomain()),
        Failure(:final error) => Failure(error),
      };
}
