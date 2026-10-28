import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelves/shelves.dart';

import 'package:profile_ui/tabs/shelves/shelf_detail/shelf_detail_state.dart';

class ShelfDetailCubit extends Cubit<ShelfDetailState> {
  final int shelfId;
  final GetShelf _getShelf;
  final GetShelfMovies _getShelfMovies;
  final SortShelf _sortShelf;
  final ReorderShelfMovies _reorderShelfMovies;
  final RemoveMovieFromShelf _removeMovieFromShelf;
  final TransferShelfMovies _transferShelfMovies;
  final AddMoviesToShelf _addMoviesToShelf;
  final SetShelfSaved _setShelfSaved;

  ShelfDetailCubit({
    required this.shelfId,
    required GetShelf getShelf,
    required GetShelfMovies getShelfMovies,
    required SortShelf sortShelf,
    required ReorderShelfMovies reorderShelfMovies,
    required RemoveMovieFromShelf removeMovieFromShelf,
    required TransferShelfMovies transferShelfMovies,
    required AddMoviesToShelf addMoviesToShelf,
    required SetShelfSaved setShelfSaved,
  }) : _getShelf = getShelf,
       _getShelfMovies = getShelfMovies,
       _sortShelf = sortShelf,
       _reorderShelfMovies = reorderShelfMovies,
       _removeMovieFromShelf = removeMovieFromShelf,
       _transferShelfMovies = transferShelfMovies,
       _addMoviesToShelf = addMoviesToShelf,
       _setShelfSaved = setShelfSaved,
       super(const ShelfDetailLoading()) {
    load();
  }

  /// Reloads the shelf and the first page, keeping the filter and view mode.
  Future<void> load() async {
    final previous = state;
    final filter = previous is ShelfDetailSuccess
        ? previous.filter
        : ShelfMovieFilter.none;
    if (previous is! ShelfDetailSuccess) emit(const ShelfDetailLoading());

    final results = await Future.wait([
      _getShelf(shelfId),
      _getShelfMovies(GetShelfMoviesParams(shelfId: shelfId, filter: filter)),
    ]);
    if (isClosed) return;

    switch ((
      results[0] as Result<Shelf>,
      results[1] as Result<Paged<ShelfMovie>>,
    )) {
      case (Success(data: final shelf), Success(data: final page)):
        emit(
          ShelfDetailSuccess(
            shelf: shelf,
            movies: page.items,
            filter: filter,
            totalResults: page.totalResults,
            page: page.page,
            hasNext: page.hasNext,
            isGridView: previous is ShelfDetailSuccess
                ? previous.isGridView
                : true,
          ),
        );
      case (Failure(:final error), _) || (_, Failure(:final error)):
        emit(ShelfDetailError(error.message));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! ShelfDetailSuccess ||
        !current.hasNext ||
        current.isLoadingMore) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true));

    final result = await _getShelfMovies(
      GetShelfMoviesParams(
        shelfId: shelfId,
        filter: current.filter,
        page: current.page + 1,
      ),
    );
    if (isClosed) return;
    final latest = state;
    if (latest is! ShelfDetailSuccess) return;
    switch (result) {
      case Success(:final data):
        emit(
          latest.copyWith(
            movies: [...latest.movies, ...data.items],
            page: data.page,
            hasNext: data.hasNext,
            isLoadingMore: false,
          ),
        );
      case Failure():
        emit(latest.copyWith(isLoadingMore: false));
    }
  }

  Future<void> setFilter(ShelfMovieFilter filter) async {
    final current = state;
    if (current is! ShelfDetailSuccess || current.filter == filter) return;
    emit(current.copyWith(filter: filter));
    await load();
  }

  void toggleViewMode() {
    final current = state;
    if (current is ShelfDetailSuccess) {
      emit(current.copyWith(isGridView: !current.isGridView));
    }
  }

  Future<bool> sort(ShelfSort sortMode, {required bool applyOnce}) => _run(
    () => _sortShelf(
      SortShelfParams(
        shelfId: shelfId,
        sortMode: sortMode,
        applyOnce: applyOnce,
      ),
    ),
  );

  /// Manual order works on the whole shelf, so it starts by loading every page without filters.
  Future<void> startReordering() async {
    await setFilter(ShelfMovieFilter.none);
    var current = state;
    while (current is ShelfDetailSuccess && current.hasNext) {
      final loaded = current.movies.length;
      await loadMore();
      if (isClosed) return;
      current = state;
      // Stop if a page failed to load instead of retrying forever.
      if (current is ShelfDetailSuccess && current.movies.length == loaded) {
        break;
      }
    }
    current = state;
    if (current is ShelfDetailSuccess) {
      emit(current.copyWith(isReordering: true));
    }
  }

  void moveMovie(int oldIndex, int newIndex) {
    final current = state;
    if (current is! ShelfDetailSuccess) return;
    final movies = [...current.movies];
    final movie = movies.removeAt(oldIndex);
    movies.insert(newIndex, movie);
    emit(current.copyWith(movies: movies));
  }

  Future<bool> finishReordering() async {
    final current = state;
    if (current is! ShelfDetailSuccess) return false;
    emit(current.copyWith(isReordering: false));
    return _run(
      () => _reorderShelfMovies(
        ReorderShelfMoviesParams(
          shelfId: shelfId,
          movieIds: current.movies.map((m) => m.movieId).toList(),
        ),
      ),
    );
  }

  Future<bool> removeMovie(int movieId) => _run(
    () => _removeMovieFromShelf(
      RemoveMovieFromShelfParams(shelfId: shelfId, movieId: movieId),
    ),
  );

  /// Moves or copies [movieIds] (all when empty) to [targetShelfId].
  Future<bool> transfer(
    int targetShelfId,
    ShelfTransferMode mode, {
    List<int> movieIds = const [],
  }) => _run(
    () => _transferShelfMovies(
      TransferShelfMoviesParams(
        shelfId: shelfId,
        targetShelfId: targetShelfId,
        mode: mode,
        movieIds: movieIds,
      ),
    ),
  );

  Future<bool> addMovies(List<int> movieIds) => _run(
    () => _addMoviesToShelf(
      AddMoviesToShelfParams(shelfId: shelfId, movieIds: movieIds),
    ),
  );

  /// Saves or unsaves a shelf of someone else (F14.5). The button flips
  /// at once and flips back when the call fails.
  Future<bool> toggleSaved() async {
    final current = state;
    if (current is! ShelfDetailSuccess || !current.shelf.canBeSaved) {
      return false;
    }
    final shelf = current.shelf;
    final saved = !shelf.isSaved;
    emit(current.copyWith(shelf: shelf.withSaved(saved)));
    final result = await _setShelfSaved(
      SetShelfSavedParams(shelf: shelf, saved: saved),
    );
    if (isClosed) return false;
    if (result is Success<void>) return true;
    final latest = state;
    if (latest is ShelfDetailSuccess) {
      emit(latest.copyWith(shelf: latest.shelf.withSaved(shelf.isSaved)));
    }
    return false;
  }

  /// Runs a change and reloads, so counters and order come from the server.
  Future<bool> _run(Future<Result<void>> Function() action) async {
    final result = await action();
    if (isClosed) return false;
    await load();
    return result is Success<void>;
  }
}
