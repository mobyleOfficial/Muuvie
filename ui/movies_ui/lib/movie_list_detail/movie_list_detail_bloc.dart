import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_list_detail/movie_list_detail_state.dart';

class MovieListDetailCubit extends Cubit<MovieListDetailState> {
  final GetMovieListDetail _getMovieListDetail;
  final DeleteMovieList _deleteMovieList;
  final AddMovieToList _addMovieToList;
  final RemoveMovieFromList _removeMovieFromList;
  final SearchMovies _searchMovies;
  final int listId;

  int _totalPages = 1;
  bool _initialLoaded = false;
  Timer? _debounceTimer;

  static const _debounceDuration = Duration(milliseconds: 300);
  static const _minQueryLength = 3;

  late final PagingController<int, Movie> pagingController = PagingController(
    getNextPageKey: (state) {
      final nextKey = state.nextIntPageKey;
      if (nextKey > _totalPages) return null;
      return nextKey;
    },
    fetchPage: _fetchPage,
  );

  MovieListDetailCubit(
    this._getMovieListDetail,
    this._deleteMovieList,
    this._addMovieToList,
    this._removeMovieFromList,
    this._searchMovies,
    this.listId,
  ) : super(const MovieListDetailLoading()) {
    _fetchInitial();
  }

  void reload() {
    emit(const MovieListDetailLoading());
    _fetchInitial();
  }

  Future<void> _fetchInitial() async {
    final result = await _getMovieListDetail(
      GetMovieListDetailParams(listId: listId, page: 1),
    );

    switch (result) {
      case Success(:final data):
        _totalPages = data.info?.totalPages ?? 1;
        _initialLoaded = true;
        emit(MovieListDetailSuccess(
          detail: data,
          isLiked: data.info?.isLiked ?? false,
          likesCount: data.info?.likesCount ?? 0,
        ));
        // Seed the paging controller with the first page
        pagingController.value = PagingState<int, Movie>(
          pages: [data.movies],
          keys: const [1],
        );
      case Failure(:final error):
        emit(MovieListDetailError(error.message));
    }
  }

  Future<List<Movie>> _fetchPage(int page) async {
    // Skip page 1 if already loaded by _fetchInitial
    if (page == 1 && _initialLoaded) return [];

    final result = await _getMovieListDetail(
      GetMovieListDetailParams(listId: listId, page: page),
    );

    switch (result) {
      case Success(:final data):
        _totalPages = data.info?.totalPages ?? 1;
        return data.movies;
      case Failure(:final error):
        throw Exception(error.message);
    }
  }

  void toggleViewMode() {
    final current = state;
    if (current is MovieListDetailSuccess) {
      emit(current.copyWith(isGridView: !current.isGridView));
    }
  }

  void toggleLike() {
    final current = state;
    if (current is MovieListDetailSuccess) {
      final newIsLiked = !current.isLiked;
      emit(current.copyWith(
        isLiked: newIsLiked,
        likesCount: current.likesCount + (newIsLiked ? 1 : -1),
      ));
    }
  }

  void toggleEditMode() {
    final current = state;
    if (current is MovieListDetailSuccess) {
      emit(current.copyWith(
        isEditing: !current.isEditing,
        searchResults: [],
        isSearching: false,
      ));
    }
  }

  Future<void> deleteList() async {
    final result = await _deleteMovieList(listId);

    if (isClosed) return;

    switch (result) {
      case Success():
        emit(const MovieListDetailDeleted());
      case Failure(:final error):
        final current = state;
        if (current is MovieListDetailSuccess) {
          emit(current);
        } else {
          emit(MovieListDetailError(error.message));
        }
    }
  }

  Future<void> removeMovie(int movieId) async {
    final current = state;
    if (current is! MovieListDetailSuccess) return;

    final result = await _removeMovieFromList(
      RemoveMovieFromListParams(listId: listId, movieId: movieId),
    );

    if (isClosed) return;

    switch (result) {
      case Success():
        // Remove movie from the paging controller
        final currentPaging = pagingController.value;
        final updatedPages = currentPaging.pages?.map((page) {
          return page.where((m) => m.id != movieId).toList();
        }).toList();
        pagingController.value = PagingState<int, Movie>(
          pages: updatedPages,
          keys: currentPaging.keys,
          error: currentPaging.error,
        );

        // Update the detail model
        final updatedMovies =
            current.detail.movies.where((m) => m.id != movieId).toList();
        final updatedDetail = MovieList(
          id: current.detail.id,
          name: current.detail.name,
          creator: current.detail.creator,
          description: current.detail.description,
          movies: updatedMovies,
          info: current.detail.info,
        );
        emit(current.copyWith(detail: updatedDetail));
      case Failure():
        // Silently fail — the movie stays in the list
        break;
    }
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.length < _minQueryLength) {
      final current = state;
      if (current is MovieListDetailSuccess) {
        emit(current.copyWith(searchResults: [], isSearching: false));
      }
      return;
    }

    final current = state;
    if (current is MovieListDetailSuccess) {
      emit(current.copyWith(isSearching: true));
    }

    _debounceTimer = Timer(_debounceDuration, () => _search(query));
  }

  Future<void> _search(String query) async {
    final result = await _searchMovies(SearchMoviesParams(query: query));
    if (isClosed) return;

    final current = state;
    if (current is! MovieListDetailSuccess) return;

    switch (result) {
      case Success(:final data):
        emit(current.copyWith(
          searchResults: data.movies,
          isSearching: false,
        ));
      case Failure():
        emit(current.copyWith(
          searchResults: [],
          isSearching: false,
        ));
    }
  }

  Future<void> addMovie(Movie movie) async {
    final current = state;
    if (current is! MovieListDetailSuccess) return;

    // Check if movie is already in the list
    final allMovies = pagingController.value.pages
            ?.expand((page) => page)
            .toList() ??
        [];
    if (allMovies.any((m) => m.id == movie.id)) return;

    final result = await _addMovieToList(
      AddMovieToListParams(listId: listId, movieId: movie.id),
    );

    if (isClosed) return;

    switch (result) {
      case Success():
        // Add movie to the paging controller
        final currentPaging = pagingController.value;
        final pages = currentPaging.pages ?? [];
        final updatedPages = pages.isEmpty
            ? [
                [movie]
              ]
            : [
                [...pages.first, movie],
                ...pages.skip(1),
              ];
        pagingController.value = PagingState<int, Movie>(
          pages: updatedPages,
          keys: currentPaging.keys,
          error: currentPaging.error,
        );

        // Update detail model
        final updatedMovies = [...current.detail.movies, movie];
        final updatedDetail = MovieList(
          id: current.detail.id,
          name: current.detail.name,
          creator: current.detail.creator,
          description: current.detail.description,
          movies: updatedMovies,
          info: current.detail.info,
        );

        final latest = state;
        if (latest is MovieListDetailSuccess) {
          emit(latest.copyWith(detail: updatedDetail));
        }
      case Failure():
        break;
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    pagingController.dispose();
    return super.close();
  }
}