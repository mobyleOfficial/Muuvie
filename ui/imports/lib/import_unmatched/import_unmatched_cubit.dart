import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imports/imports.dart';
import 'package:imports_ui/import_unmatched/import_unmatched_state.dart';

/// The movies of an import that need the user to confirm the match (F3.4).
class ImportUnmatchedCubit extends Cubit<ImportUnmatchedState> {
  final int jobId;
  final GetUnmatchedItems _getUnmatchedItems;
  final ResolveUnmatchedItem _resolveUnmatchedItem;
  bool _loadingMore = false;

  ImportUnmatchedCubit({
    required this.jobId,
    required GetUnmatchedItems getUnmatchedItems,
    required ResolveUnmatchedItem resolveUnmatchedItem,
  }) : _getUnmatchedItems = getUnmatchedItems,
       _resolveUnmatchedItem = resolveUnmatchedItem,
       super(const ImportUnmatchedLoading()) {
    load();
  }

  Future<void> load() async {
    emit(const ImportUnmatchedLoading());
    final result = await _getUnmatchedItems(
      GetUnmatchedItemsParams(jobId: jobId),
    );
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) => ImportUnmatchedSuccess(
        items: data.items,
        page: data.page,
        hasNext: data.hasNext,
      ),
      Failure(:final error) => ImportUnmatchedError(error.message),
    });
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! ImportUnmatchedSuccess ||
        !current.hasNext ||
        _loadingMore) {
      return;
    }
    _loadingMore = true;
    final result = await _getUnmatchedItems(
      GetUnmatchedItemsParams(jobId: jobId, page: current.page + 1),
    );
    _loadingMore = false;
    final latest = state;
    if (isClosed || latest is! ImportUnmatchedSuccess) return;
    if (result case Success(:final data)) {
      emit(
        latest.copyWith(
          items: [...latest.items, ...data.items],
          page: data.page,
          hasNext: data.hasNext,
        ),
      );
    }
  }

  /// [candidate] null skips: the movie stays as it was imported.
  Future<void> resolve(UnmatchedItem item, MovieCandidate? candidate) async {
    final current = state;
    if (current is! ImportUnmatchedSuccess ||
        current.resolving.contains(item.id)) {
      return;
    }
    emit(current.copyWith(resolving: {...current.resolving, item.id}));
    final result = await _resolveUnmatchedItem(
      ResolveUnmatchedItemParams(
        jobId: jobId,
        itemId: item.id,
        candidate: candidate,
      ),
    );
    final latest = state;
    if (isClosed || latest is! ImportUnmatchedSuccess) return;
    final resolving = {...latest.resolving}..remove(item.id);
    emit(switch (result) {
      Success(:final data) => latest.copyWith(
        items: [
          for (final existing in latest.items)
            existing.id == item.id ? data : existing,
        ],
        resolving: resolving,
      ),
      Failure() => latest.copyWith(resolving: resolving, actionFailed: true),
    });
  }
}
