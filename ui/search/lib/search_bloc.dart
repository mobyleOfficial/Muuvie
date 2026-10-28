import 'dart:async';

import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/movies.dart';

import 'package:search/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchMovies _searchMovies;

  final StreamController<String> _queryController = StreamController<String>();
  late final StreamSubscription<String> _querySubscription;

  bool _isSearching = false;

  static const _debounceDuration = Duration(milliseconds: 300);
  static const _minimumQueryLength = 3;

  SearchCubit(this._searchMovies) : super(const SearchIdle()) {
    _querySubscription = _queryController.stream
        .distinct()
        .debounce(_debounceDuration)
        .listen(_onQueryChanged);
  }

  void onSearchChanged(String query) {
    if (query.length < _minimumQueryLength) {
      _isSearching = false;
      emit(const SearchIdle());
      // Lets the same query run again after going below the minimum.
      _queryController.add(query);
      return;
    }

    // Leaves "type 3 letters" at once, without waiting for the debounce.
    if (state is SearchIdle) emit(const SearchSearching());
    _queryController.add(query);
  }

  void _onQueryChanged(String query) {
    if (query.length < _minimumQueryLength) return;

    _isSearching = true;
    emit(const SearchSearching());
    _search(query);
  }

  Future<void> _search(String query) async {
    final result = await _searchMovies(SearchMoviesParams(query: query));

    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(SearchResults(data.movies));
      case Failure(:final error):
        emit(SearchError(error.message));
    }
  }

  bool get isSearchActive => _isSearching;

  @override
  Future<void> close() {
    _querySubscription.cancel();
    _queryController.close();
    return super.close();
  }
}
