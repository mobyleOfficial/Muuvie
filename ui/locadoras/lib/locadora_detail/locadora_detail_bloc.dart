import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shelves/shelves.dart';

import 'package:locadoras_ui/locadora_detail/locadora_detail_state.dart';

class LocadoraDetailCubit extends Cubit<LocadoraDetailState> {
  // A locadora holds at most 200 shelves (10 pages of 20).
  static const _maxPages = 10;

  final int locadoraId;
  final GetLocadora _getLocadora;
  final GetLocadoraShelves _getLocadoraShelves;
  final SaveLocadora _saveLocadora;
  final DeleteLocadora _deleteLocadora;
  final SetLocadoraShelves _setLocadoraShelves;
  final ReorderLocadoraShelves _reorderLocadoraShelves;

  LocadoraDetailCubit({
    required this.locadoraId,
    required GetLocadora getLocadora,
    required GetLocadoraShelves getLocadoraShelves,
    required SaveLocadora saveLocadora,
    required DeleteLocadora deleteLocadora,
    required SetLocadoraShelves setLocadoraShelves,
    required ReorderLocadoraShelves reorderLocadoraShelves,
  }) : _getLocadora = getLocadora,
       _getLocadoraShelves = getLocadoraShelves,
       _saveLocadora = saveLocadora,
       _deleteLocadora = deleteLocadora,
       _setLocadoraShelves = setLocadoraShelves,
       _reorderLocadoraShelves = reorderLocadoraShelves,
       super(const LocadoraDetailLoading()) {
    load();
  }

  Future<void> load() async {
    if (state is! LocadoraDetailSuccess) emit(const LocadoraDetailLoading());

    final Locadora locadora;
    switch (await _getLocadora(locadoraId)) {
      case Success(:final data):
        locadora = data;
      case Failure(:final error):
        if (!isClosed) emit(LocadoraDetailError(error.message));
        return;
    }

    final shelves = <LocadoraShelf>[];
    var hasNext = true;
    for (var page = 1; hasNext && page <= _maxPages; page++) {
      final result = await _getLocadoraShelves(
        GetLocadoraShelvesParams(locadoraId: locadoraId, page: page),
      );
      if (isClosed) return;
      switch (result) {
        case Success(:final data):
          shelves.addAll(data.items);
          hasNext = data.hasNext;
        case Failure(:final error):
          emit(LocadoraDetailError(error.message));
          return;
      }
    }
    emit(LocadoraDetailSuccess(locadora: locadora, shelves: shelves));
  }

  /// Returns the saved locadora, or null when saving failed.
  Future<Locadora?> saveLocadora(LocadoraDraft draft) async {
    final result = await _saveLocadora(
      SaveLocadoraParams(locadoraId: locadoraId, draft: draft),
    );
    if (result is! Success<Locadora>) return null;
    await load();
    return result.data;
  }

  Future<bool> deleteLocadora() async =>
      await _deleteLocadora(locadoraId) is Success<void>;

  List<int> get shelfIds => switch (state) {
    LocadoraDetailSuccess(:final shelves) =>
      shelves.map((s) => s.shelf.id).toList(),
    _ => const [],
  };

  /// Replaces the shelves (F4.2).
  Future<bool> setShelves(List<int> shelfIds) async {
    final result = await _setLocadoraShelves(
      LocadoraShelvesParams(locadoraId: locadoraId, shelfIds: shelfIds),
    );
    await load();
    return result is Success<void>;
  }

  void startReordering() {
    final current = state;
    if (current is LocadoraDetailSuccess) {
      emit(current.copyWith(isReordering: true));
    }
  }

  void moveShelf(int oldIndex, int newIndex) {
    final current = state;
    if (current is! LocadoraDetailSuccess) return;
    final shelves = [...current.shelves];
    final shelf = shelves.removeAt(oldIndex);
    shelves.insert(newIndex, shelf);
    emit(current.copyWith(shelves: shelves));
  }

  /// Saves the dragged order (F4.3).
  Future<bool> finishReordering() async {
    final current = state;
    if (current is! LocadoraDetailSuccess) return false;
    emit(current.copyWith(isReordering: false));
    final result = await _reorderLocadoraShelves(
      LocadoraShelvesParams(
        locadoraId: locadoraId,
        shelfIds: current.shelves.map((s) => s.shelf.id).toList(),
      ),
    );
    if (result is! Success<void>) await load();
    return result is Success<void>;
  }
}
