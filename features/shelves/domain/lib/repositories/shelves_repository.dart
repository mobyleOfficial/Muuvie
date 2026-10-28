import 'package:core/core.dart';
import 'package:shelves_domain/models/models.dart';

abstract interface class ShelvesRepository {
  /// Shelves of [userId] the caller can see; `me` is the current user.
  /// With [profile], also leaves out, for the owner too, the shelves a
  /// locadora hides from the profile.
  Future<Result<Paged<Shelf>>> getUserShelves({
    required String userId,
    required int page,
    bool profile = false,
  });

  Future<Result<Paged<Shelf>>> searchShelves({
    required String query,
    required int page,
  });

  /// Public shelves of other users for the Catálogo (F5.6).
  Future<Result<Paged<Shelf>>> discoverShelves({
    String? query,
    required int page,
  });

  Future<Result<Shelf>> getShelf(int shelfId);

  /// Shelves of other people the current user saved, the latest first (B14.4).
  Future<Result<Paged<Shelf>>> getSavedShelves({required int page});

  /// Saves or unsaves a shelf of someone else (B14.4).
  Future<Result<void>> setShelfSaved({
    required int shelfId,
    required bool saved,
  });

  Future<Result<Shelf>> createShelf(ShelfDraft draft);

  Future<Result<Shelf>> updateShelf(int shelfId, ShelfDraft draft);

  Future<Result<void>> deleteShelf(int shelfId);

  Future<Result<Paged<ShelfMovie>>> getShelfMovies({
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

  Future<Result<MovieShelves>> getMovieShelves(int movieId);

  /// Public custom shelves of anyone holding the movie (B13.2).
  Future<Result<Paged<PublicShelf>>> getPublicShelvesWithMovie({
    required int movieId,
    required int page,
  });

  /// Adds the movie to every shelf in [shelfIds] in one step.
  Future<Result<MovieShelves>> addMovieToShelves({
    required int movieId,
    required List<int> shelfIds,
  });
}
