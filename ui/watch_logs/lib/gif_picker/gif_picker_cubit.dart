import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watch_logs/watch_logs.dart';

class GifPickerState {
  final String query;
  final List<Gif> recent;
  final List<Gif> results;
  final String? nextCursor;
  final bool isLoading;

  /// The search failed, e.g. the server has no provider key (503).
  final bool unavailable;

  const GifPickerState({
    this.query = '',
    this.recent = const [],
    this.results = const [],
    this.nextCursor,
    this.isLoading = false,
    this.unavailable = false,
  });

  /// Recent picks while nothing is typed, search results otherwise.
  List<Gif> get visible => query.trim().isEmpty ? recent : results;
}

/// GIF search with recent picks (F2.2). Typing is debounced.
class GifPickerCubit extends Cubit<GifPickerState> {
  static const _debounce = Duration(milliseconds: 400);

  final SearchGifs _searchGifs;
  final GetRecentGifs _getRecentGifs;
  Timer? _timer;

  GifPickerCubit({
    required SearchGifs searchGifs,
    required GetRecentGifs getRecentGifs,
  }) : _searchGifs = searchGifs,
       _getRecentGifs = getRecentGifs,
       super(const GifPickerState()) {
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final result = await _getRecentGifs();
    if (isClosed) return;
    if (result case Success(:final data)) {
      emit(_copy(recent: data));
    }
  }

  void setQuery(String query) {
    emit(_copy(query: query));
    _timer?.cancel();
    if (query.trim().isEmpty) return;
    _timer = Timer(_debounce, () => _search(query));
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.isLoading) return;
    await _search(state.query, cursor: cursor);
  }

  Future<void> _search(String query, {String? cursor}) async {
    emit(_copy(isLoading: true));
    final result = await _searchGifs(
      SearchGifsParams(query: query, cursor: cursor),
    );
    // A newer query was typed while this one was loading.
    if (isClosed || query != state.query) return;
    switch (result) {
      case Success(:final data):
        emit(
          GifPickerState(
            query: query,
            recent: state.recent,
            results: cursor == null
                ? data.gifs
                : [...state.results, ...data.gifs],
            nextCursor: data.nextCursor,
          ),
        );
      case Failure():
        emit(_copy(isLoading: false, unavailable: true));
    }
  }

  GifPickerState _copy({
    String? query,
    List<Gif>? recent,
    bool? isLoading,
    bool? unavailable,
  }) => GifPickerState(
    query: query ?? state.query,
    recent: recent ?? state.recent,
    results: state.results,
    nextCursor: state.nextCursor,
    isLoading: isLoading ?? state.isLoading,
    unavailable: unavailable ?? state.unavailable,
  );

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
