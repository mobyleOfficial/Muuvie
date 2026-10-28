import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelves/shelves.dart';

import 'package:locadoras_ui/locadoras_list/locadoras_list_state.dart';

class LocadorasListCubit extends Cubit<LocadorasListState> {
  // Locadoras per account are few; the whole list is loaded so it can be reordered.
  static const _maxPages = 10;

  /// Owner of the list, or `me` for the current user.
  final String userId;
  final GetUserLocadoras _getUserLocadoras;
  final SaveLocadora _saveLocadora;
  final DeleteLocadora _deleteLocadora;
  final ReorderLocadoras _reorderLocadoras;

  LocadorasListCubit({
    this.userId = 'me',
    required GetUserLocadoras getUserLocadoras,
    required SaveLocadora saveLocadora,
    required DeleteLocadora deleteLocadora,
    required ReorderLocadoras reorderLocadoras,
  }) : _getUserLocadoras = getUserLocadoras,
       _saveLocadora = saveLocadora,
       _deleteLocadora = deleteLocadora,
       _reorderLocadoras = reorderLocadoras,
       super(const LocadorasListLoading()) {
    load();
  }

  bool get isOwnList => userId == 'me';

  Future<void> load() async {
    if (state is! LocadorasListSuccess) emit(const LocadorasListLoading());

    final locadoras = <Locadora>[];
    for (var page = 1; page <= _maxPages; page++) {
      final result = await _getUserLocadoras(
        GetUserLocadorasParams(userId: userId, page: page),
      );
      if (isClosed) return;
      switch (result) {
        case Success(:final data):
          locadoras.addAll(data.items);
          if (!data.hasNext) {
            emit(LocadorasListSuccess(locadoras));
            return;
          }
        case Failure(:final error):
          emit(LocadorasListError(error.message));
          return;
      }
    }
    emit(LocadorasListSuccess(locadoras));
  }

  /// Creates the locadora when [locadoraId] is null, edits it otherwise.
  /// Returns the saved locadora, or null when saving failed.
  Future<Locadora?> saveLocadora({
    int? locadoraId,
    required LocadoraDraft draft,
  }) async {
    final result = await _saveLocadora(
      SaveLocadoraParams(locadoraId: locadoraId, draft: draft),
    );
    if (result is! Success<Locadora>) return null;
    await load();
    return result.data;
  }

  Future<bool> deleteLocadora(Locadora locadora) async {
    final result = await _deleteLocadora(locadora.id);
    if (result is Success<void>) await load();
    return result is Success<void>;
  }

  Future<bool> togglePin(Locadora locadora) async {
    final current = state;
    if (current is! LocadorasListSuccess) return false;
    final pinnedIds = {
      for (final l in current.locadoras)
        if (l.pinned) l.id,
    };
    locadora.pinned
        ? pinnedIds.remove(locadora.id)
        : pinnedIds.add(locadora.id);
    final result = await _reorderLocadoras(
      ReorderLocadorasParams(
        locadoraIds: current.locadoras.map((l) => l.id).toList(),
        pinnedIds: pinnedIds.toList(),
      ),
    );
    if (result is Success<void>) await load();
    return result is Success<void>;
  }

  void startReordering() {
    final current = state;
    if (current is LocadorasListSuccess) {
      emit(current.copyWith(isReordering: true));
    }
  }

  void moveLocadora(int oldIndex, int newIndex) {
    final current = state;
    if (current is! LocadorasListSuccess) return;
    final locadoras = [...current.locadoras];
    final locadora = locadoras.removeAt(oldIndex);
    locadoras.insert(newIndex, locadora);
    emit(current.copyWith(locadoras: locadoras));
  }

  /// Saves the dragged order. Pinned locadoras stay on top.
  Future<bool> finishReordering() async {
    final current = state;
    if (current is! LocadorasListSuccess) return false;
    emit(current.copyWith(isReordering: false));
    final result = await _reorderLocadoras(
      ReorderLocadorasParams(
        locadoraIds: current.locadoras.map((l) => l.id).toList(),
      ),
    );
    await load();
    return result is Success<void>;
  }
}
