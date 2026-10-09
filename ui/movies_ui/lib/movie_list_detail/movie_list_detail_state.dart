import 'package:movies/movies.dart';

sealed class MovieListDetailState {
  const MovieListDetailState();
}

class MovieListDetailLoading extends MovieListDetailState {
  const MovieListDetailLoading();
}

class MovieListDetailSuccess extends MovieListDetailState {
  final MovieList detail;
  final bool isLiked;
  final int likesCount;
  final bool isGridView;
  final bool isEditing;
  final bool isSearching;
  final List<Movie> searchResults;

  const MovieListDetailSuccess({
    required this.detail,
    required this.isLiked,
    required this.likesCount,
    this.isGridView = true,
    this.isEditing = false,
    this.isSearching = false,
    this.searchResults = const [],
  });

  MovieListDetailSuccess copyWith({
    MovieList? detail,
    bool? isLiked,
    int? likesCount,
    bool? isGridView,
    bool? isEditing,
    bool? isSearching,
    List<Movie>? searchResults,
  }) =>
      MovieListDetailSuccess(
        detail: detail ?? this.detail,
        isLiked: isLiked ?? this.isLiked,
        likesCount: likesCount ?? this.likesCount,
        isGridView: isGridView ?? this.isGridView,
        isEditing: isEditing ?? this.isEditing,
        isSearching: isSearching ?? this.isSearching,
        searchResults: searchResults ?? this.searchResults,
      );
}

class MovieListDetailError extends MovieListDetailState {
  final String message;

  const MovieListDetailError(this.message);
}

class MovieListDetailDeleted extends MovieListDetailState {
  const MovieListDetailDeleted();
}