import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cineclubes/cineclubes.dart';

class CineClubeListState {
  final CineClubeFilter filter;
  final List<CineClubeSummary> cineclubes;
  final bool loading;
  final bool loadingMore;
  final AppError? error;
  final int page;
  final bool hasNext;

  const CineClubeListState({
    this.filter = const CineClubeFilter(),
    this.cineclubes = const [],
    this.loading = true,
    this.loadingMore = false,
    this.error,
    this.page = 1,
    this.hasNext = false,
  });

  CineClubeListState copyWith({
    CineClubeFilter? filter,
    List<CineClubeSummary>? cineclubes,
    bool? loading,
    bool? loadingMore,
    AppError? error,
    bool clearError = false,
    int? page,
    bool? hasNext,
  }) => CineClubeListState(
    filter: filter ?? this.filter,
    cineclubes: cineclubes ?? this.cineclubes,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: clearError ? null : error ?? this.error,
    page: page ?? this.page,
    hasNext: hasNext ?? this.hasNext,
  );
}

/// The CineClube list of Programação (F8.2): search, filters and pages.
class CineClubeListCubit extends Cubit<CineClubeListState> {
  final GetCineClubes _getCineClubes;
  var _request = 0;

  CineClubeListCubit({required GetCineClubes getCineClubes})
    : _getCineClubes = getCineClubes,
      super(const CineClubeListState());

  Future<void> setFilter(CineClubeFilter filter) {
    emit(state.copyWith(filter: filter));
    return load();
  }

  Future<void> load() async {
    final request = ++_request;
    emit(state.copyWith(loading: true, clearError: true));
    final result = await _getCineClubes(
      GetCineClubesParams(filter: state.filter),
    );
    if (isClosed || request != _request) return;
    emit(switch (result) {
      Success(:final data) => state.copyWith(
        loading: false,
        cineclubes: data.cineclubes,
        page: data.page,
        hasNext: data.hasNext,
      ),
      Failure(:final error) => state.copyWith(
        loading: false,
        cineclubes: const [],
        error: error,
      ),
    });
  }

  Future<void> loadMore() async {
    if (!state.hasNext || state.loadingMore || state.loading) return;
    final request = _request;
    emit(state.copyWith(loadingMore: true));
    final result = await _getCineClubes(
      GetCineClubesParams(filter: state.filter, page: state.page + 1),
    );
    if (isClosed || request != _request) return;
    emit(switch (result) {
      Success(:final data) => state.copyWith(
        loadingMore: false,
        cineclubes: [...state.cineclubes, ...data.cineclubes],
        page: data.page,
        hasNext: data.hasNext,
      ),
      Failure() => state.copyWith(loadingMore: false),
    });
  }
}
