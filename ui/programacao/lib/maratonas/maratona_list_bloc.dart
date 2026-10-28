import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maratonas/maratonas.dart';

class MaratonaListState {
  final MaratonaFilter filter;
  final List<MaratonaSummary> maratonas;
  final bool loading;
  final bool loadingMore;
  final AppError? error;
  final int page;
  final bool hasNext;

  const MaratonaListState({
    this.filter = const MaratonaFilter(),
    this.maratonas = const [],
    this.loading = true,
    this.loadingMore = false,
    this.error,
    this.page = 1,
    this.hasNext = false,
  });

  MaratonaListState copyWith({
    MaratonaFilter? filter,
    List<MaratonaSummary>? maratonas,
    bool? loading,
    bool? loadingMore,
    AppError? error,
    bool clearError = false,
    int? page,
    bool? hasNext,
  }) => MaratonaListState(
    filter: filter ?? this.filter,
    maratonas: maratonas ?? this.maratonas,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: clearError ? null : error ?? this.error,
    page: page ?? this.page,
    hasNext: hasNext ?? this.hasNext,
  );
}

/// The maratona list of Programação (F7.2): search, filters and pages.
class MaratonaListCubit extends Cubit<MaratonaListState> {
  final GetMaratonas _getMaratonas;
  var _request = 0;

  MaratonaListCubit({required GetMaratonas getMaratonas})
    : _getMaratonas = getMaratonas,
      super(const MaratonaListState());

  Future<void> setFilter(MaratonaFilter filter) {
    emit(state.copyWith(filter: filter));
    return load();
  }

  Future<void> load() async {
    final request = ++_request;
    emit(state.copyWith(loading: true, clearError: true));
    final result = await _getMaratonas(
      GetMaratonasParams(filter: state.filter),
    );
    if (isClosed || request != _request) return;
    emit(switch (result) {
      Success(:final data) => state.copyWith(
        loading: false,
        maratonas: data.maratonas,
        page: data.page,
        hasNext: data.hasNext,
      ),
      Failure(:final error) => state.copyWith(
        loading: false,
        maratonas: const [],
        error: error,
      ),
    });
  }

  Future<void> loadMore() async {
    if (!state.hasNext || state.loadingMore || state.loading) return;
    final request = _request;
    emit(state.copyWith(loadingMore: true));
    final result = await _getMaratonas(
      GetMaratonasParams(filter: state.filter, page: state.page + 1),
    );
    if (isClosed || request != _request) return;
    emit(switch (result) {
      Success(:final data) => state.copyWith(
        loadingMore: false,
        maratonas: [...state.maratonas, ...data.maratonas],
        page: data.page,
        hasNext: data.hasNext,
      ),
      Failure() => state.copyWith(loadingMore: false),
    });
  }
}
