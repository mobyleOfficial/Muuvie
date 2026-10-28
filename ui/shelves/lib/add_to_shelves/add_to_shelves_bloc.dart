import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelves/shelves.dart';

import 'package:shelves_ui/add_to_shelves/add_to_shelves_state.dart';

/// Adds one movie to several of the user's shelves in one step (F1.4).
class AddToShelvesCubit extends Cubit<AddToShelvesState> {
  static const _maxPages = 10;

  final int movieId;
  final GetUserShelves _getUserShelves;
  final GetMovieShelves _getMovieShelves;
  final AddMovieToShelves _addMovieToShelves;

  AddToShelvesCubit({
    required this.movieId,
    required GetUserShelves getUserShelves,
    required GetMovieShelves getMovieShelves,
    required AddMovieToShelves addMovieToShelves,
  }) : _getUserShelves = getUserShelves,
       _getMovieShelves = getMovieShelves,
       _addMovieToShelves = addMovieToShelves,
       super(const AddToShelvesLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const AddToShelvesLoading());

    final current = await _getMovieShelves(movieId);
    if (isClosed) return;
    if (current case Failure(:final error)) {
      emit(AddToShelvesError(error.message));
      return;
    }
    final currentIds = (current as Success<MovieShelves>).data.shelfIds;

    final shelves = <Shelf>[];
    for (var page = 1; page <= _maxPages; page++) {
      final result = await _getUserShelves(GetUserShelvesParams(page: page));
      if (isClosed) return;
      if (result case Failure(:final error)) {
        emit(AddToShelvesError(error.message));
        return;
      }
      final data = (result as Success<Paged<Shelf>>).data;
      shelves.addAll(data.items);
      if (!data.hasNext) break;
    }

    emit(
      AddToShelvesSuccess(
        shelves: shelves,
        currentShelfIds: currentIds,
        selectedShelfIds: {},
      ),
    );
  }

  void toggle(int shelfId) {
    final current = state;
    if (current is! AddToShelvesSuccess ||
        current.currentShelfIds.contains(shelfId)) {
      return;
    }
    final selected = {...current.selectedShelfIds};
    selected.contains(shelfId)
        ? selected.remove(shelfId)
        : selected.add(shelfId);
    emit(current.copyWith(selectedShelfIds: selected));
  }

  /// Returns how many shelves received the movie, or null when it failed.
  Future<int?> save() async {
    final current = state;
    if (current is! AddToShelvesSuccess || current.selectedShelfIds.isEmpty) {
      return null;
    }
    emit(current.copyWith(isSaving: true));

    final result = await _addMovieToShelves(
      AddMovieToShelvesParams(
        movieId: movieId,
        shelfIds: current.selectedShelfIds.toList(),
      ),
    );
    if (isClosed) return null;
    emit(current.copyWith(isSaving: false));
    return result is Success<MovieShelves>
        ? current.selectedShelfIds.length
        : null;
  }
}
