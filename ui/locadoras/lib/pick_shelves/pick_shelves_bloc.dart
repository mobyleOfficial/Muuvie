import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelves/shelves.dart';

import 'package:locadoras_ui/pick_shelves/pick_shelves_state.dart';

/// Picks the set of my shelves a locadora holds (F4.2). Only my shelves are offered.
class PickShelvesCubit extends Cubit<PickShelvesState> {
  static const _maxPages = 10;

  final List<int> initialIds;
  final GetUserShelves _getUserShelves;

  PickShelvesCubit({
    required this.initialIds,
    required GetUserShelves getUserShelves,
  }) : _getUserShelves = getUserShelves,
       super(const PickShelvesLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const PickShelvesLoading());
    final shelves = <Shelf>[];
    var hasNext = true;
    for (var page = 1; hasNext && page <= _maxPages; page++) {
      final result = await _getUserShelves(GetUserShelvesParams(page: page));
      if (isClosed) return;
      switch (result) {
        case Success(:final data):
          shelves.addAll(data.items);
          hasNext = data.hasNext;
        case Failure(:final error):
          emit(PickShelvesError(error.message));
          return;
      }
    }
    emit(PickShelvesSuccess(shelves: shelves, selectedIds: [...initialIds]));
  }

  /// New picks go to the end, which is where the locadora puts them.
  void toggle(int shelfId) {
    final current = state;
    if (current is! PickShelvesSuccess) return;
    final selected = [...current.selectedIds];
    selected.contains(shelfId)
        ? selected.remove(shelfId)
        : selected.add(shelfId);
    emit(PickShelvesSuccess(shelves: current.shelves, selectedIds: selected));
  }
}
