import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/movies.dart';

import 'package:profile_ui/tabs/lists/create_list/create_list_state.dart';

class CreateListCubit extends Cubit<CreateListState> {
  final CreateMovieList _createMovieList;
  final SearchMovies _searchMovies;

  Timer? _debounceTimer;

  static const _debounceDuration = Duration(milliseconds: 300);
  static const _minQueryLength = 3;

  CreateListCubit(
    this._createMovieList,
    this._searchMovies,
  ) : super(const CreateListIdle());

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.length < _minQueryLength) {
      final current = state;
      if (current is CreateListIdle) {
        emit(current.copyWith(searchResults: [], isSearching: false));
      }
      return;
    }

    final current = state;
    if (current is CreateListIdle) {
      emit(current.copyWith(isSearching: true));
    }

    _debounceTimer = Timer(_debounceDuration, () => _search(query));
  }

  Future<void> _search(String query) async {
    final result = await _searchMovies(SearchMoviesParams(query: query));
    if (isClosed) return;

    final current = state;
    final selected =
        current is CreateListIdle ? current.selectedMovies : <Movie>[];

    switch (result) {
      case Success(:final data):
        emit(CreateListIdle(
          selectedMovies: selected,
          searchResults: data.movies,
          isSearching: false,
        ));
      case Failure():
        emit(CreateListIdle(
          selectedMovies: selected,
          searchResults: [],
          isSearching: false,
        ));
    }
  }

  void addMovie(Movie movie) {
    final current = state;
    if (current is! CreateListIdle) return;
    if (current.selectedMovies.any((m) => m.id == movie.id)) return;

    emit(current.copyWith(
      selectedMovies: [...current.selectedMovies, movie],
      searchResults: [],
    ));
  }

  void removeMovie(int movieId) {
    final current = state;
    if (current is! CreateListIdle) return;

    emit(current.copyWith(
      selectedMovies:
          current.selectedMovies.where((m) => m.id != movieId).toList(),
    ));
  }

  void setSelectedMovies(List<Movie> movies) {
    final current = state;
    if (current is CreateListIdle) {
      emit(current.copyWith(selectedMovies: movies));
    } else {
      emit(CreateListIdle(selectedMovies: movies));
    }
  }

  Future<void> createList(String name, String description) async {
    if (name.trim().isEmpty) {
      final selected = state is CreateListIdle
          ? (state as CreateListIdle).selectedMovies
          : <Movie>[];
      emit(CreateListError('List name cannot be empty',
          selectedMovies: selected));
      return;
    }

    final selected = state is CreateListIdle
        ? (state as CreateListIdle).selectedMovies
        : <Movie>[];
    emit(CreateListSaving(selectedMovies: selected));

    final result = await _createMovieList(
      CreateMovieListParams(
        name: name.trim(),
        description: description.trim(),
        movieIds: selected.map((m) => m.id).toList(),
      ),
    );

    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(CreateListSuccess(data));
      case Failure(:final error):
        emit(CreateListError(error.message, selectedMovies: selected));
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
