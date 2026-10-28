import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelves/shelves.dart';

import 'package:profile_ui/tabs/shelves/shelves_state.dart';

class ShelvesCubit extends Cubit<ShelvesState> {
  // Shelves per account are few; the whole list is loaded so it can be reordered.
  static const _maxPages = 10;

  /// The owner, or `me` for the current user.
  final String userId;
  final GetUserShelves _getUserShelves;
  final SaveShelf _saveShelf;
  final DeleteShelf _deleteShelf;
  final ReorderShelves _reorderShelves;
  final AddMoviesToShelf _addMoviesToShelf;

  ShelvesCubit({
    this.userId = 'me',
    required GetUserShelves getUserShelves,
    required SaveShelf saveShelf,
    required DeleteShelf deleteShelf,
    required ReorderShelves reorderShelves,
    required AddMoviesToShelf addMoviesToShelf,
  }) : _getUserShelves = getUserShelves,
       _saveShelf = saveShelf,
       _deleteShelf = deleteShelf,
       _reorderShelves = reorderShelves,
       _addMoviesToShelf = addMoviesToShelf,
       super(const ShelvesLoading()) {
    load();
  }

  Future<void> load() async {
    if (state is! ShelvesSuccess) emit(const ShelvesLoading());

    final shelves = <Shelf>[];
    for (var page = 1; page <= _maxPages; page++) {
      final result = await _getUserShelves(
        GetUserShelvesParams(userId: userId, page: page, profile: true),
      );
      if (isClosed) return;
      switch (result) {
        case Success(:final data):
          shelves.addAll(data.items);
          if (!data.hasNext) {
            emit(ShelvesSuccess(shelves));
            return;
          }
        case Failure(:final error):
          emit(ShelvesError(error.message));
          return;
      }
    }
    emit(ShelvesSuccess(shelves));
  }

  /// Creates the shelf when [shelfId] is null, edits it otherwise.
  Future<bool> saveShelf({int? shelfId, required ShelfDraft draft}) async {
    final result = await _saveShelf(
      SaveShelfParams(shelfId: shelfId, draft: draft),
    );
    if (result is Success<Shelf>) await load();
    return result is Success<Shelf>;
  }

  Future<bool> deleteShelf(Shelf shelf) async {
    final result = await _deleteShelf(shelf);
    if (result is Success<void>) await load();
    return result is Success<void>;
  }

  Future<bool> togglePin(Shelf shelf) async {
    final current = state;
    if (current is! ShelvesSuccess) return false;
    final pinnedIds = {
      for (final s in current.shelves)
        if (s.pinned) s.id,
    };
    shelf.pinned ? pinnedIds.remove(shelf.id) : pinnedIds.add(shelf.id);
    final result = await _reorderShelves(
      ReorderShelvesParams(
        shelfIds: current.shelves.map((s) => s.id).toList(),
        pinnedIds: pinnedIds.toList(),
      ),
    );
    if (result is Success<void>) await load();
    return result is Success<void>;
  }

  void startReordering() {
    final current = state;
    if (current is ShelvesSuccess) emit(current.copyWith(isReordering: true));
  }

  void moveShelf(int oldIndex, int newIndex) {
    final current = state;
    if (current is! ShelvesSuccess) return;
    final shelves = [...current.shelves];
    final shelf = shelves.removeAt(oldIndex);
    shelves.insert(newIndex, shelf);
    emit(current.copyWith(shelves: shelves));
  }

  /// Saves the dragged order. Pinned shelves stay on top.
  Future<bool> finishReordering() async {
    final current = state;
    if (current is! ShelvesSuccess) return false;
    emit(current.copyWith(isReordering: false));
    final result = await _reorderShelves(
      ReorderShelvesParams(shelfIds: current.shelves.map((s) => s.id).toList()),
    );
    await load();
    return result is Success<void>;
  }

  Future<bool> addMovies(Shelf shelf, List<int> movieIds) async {
    final result = await _addMoviesToShelf(
      AddMoviesToShelfParams(shelfId: shelf.id, movieIds: movieIds),
    );
    await load();
    return result is Success<void>;
  }
}
