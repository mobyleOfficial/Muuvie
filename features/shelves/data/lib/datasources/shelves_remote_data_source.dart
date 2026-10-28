import 'package:core/core.dart';
import 'package:shelves_data/models/models.dart';
import 'package:shelves_domain/models/models.dart';

abstract interface class ShelvesRemoteDataSource {
  Future<Result<RemotePage<RemoteShelf>>> getUserShelves({
    required String userId,
    required int page,
    bool profile = false,
  });

  Future<Result<RemotePage<RemoteShelf>>> searchShelves({
    required String query,
    required int page,
  });

  Future<Result<RemotePage<RemoteShelf>>> discoverShelves({
    String? query,
    required int page,
  });

  Future<Result<RemoteShelf>> getShelf(int shelfId);

  Future<Result<RemotePage<RemoteShelf>>> getSavedShelves({required int page});

  Future<Result<void>> setShelfSaved({
    required int shelfId,
    required bool saved,
  });

  Future<Result<RemoteShelf>> createShelf(ShelfDraft draft);

  Future<Result<RemoteShelf>> updateShelf(int shelfId, ShelfDraft draft);

  Future<Result<void>> deleteShelf(int shelfId);

  Future<Result<RemotePage<RemoteShelfMovie>>> getShelfMovies({
    required int shelfId,
    required ShelfMovieFilter filter,
    required int page,
  });

  Future<Result<void>> addMovieToShelf({
    required int shelfId,
    required int movieId,
  });

  Future<Result<void>> removeMovieFromShelf({
    required int shelfId,
    required int movieId,
  });

  Future<Result<void>> transferShelfMovies({
    required int shelfId,
    required int targetShelfId,
    required ShelfTransferMode mode,
    required List<int> movieIds,
  });

  Future<Result<void>> sortShelf({
    required int shelfId,
    required ShelfSort sortMode,
    required bool applyOnce,
  });

  Future<Result<void>> reorderShelfMovies({
    required int shelfId,
    required List<int> movieIds,
  });

  Future<Result<void>> reorderShelves({
    required List<int> shelfIds,
    List<int>? pinnedIds,
  });

  Future<Result<RemoteMovieShelves>> getMovieShelves(int movieId);

  Future<Result<RemotePage<RemotePublicShelf>>> getPublicShelvesWithMovie({
    required int movieId,
    required int page,
  });

  Future<Result<RemoteMovieShelves>> addMovieToShelves({
    required int movieId,
    required List<int> shelfIds,
  });
}
