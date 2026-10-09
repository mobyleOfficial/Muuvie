import 'package:movies/movies.dart';

sealed class CreateListState {
  const CreateListState();
}

class CreateListIdle extends CreateListState {
  final List<Movie> selectedMovies;
  final List<Movie> searchResults;
  final bool isSearching;

  const CreateListIdle({
    this.selectedMovies = const [],
    this.searchResults = const [],
    this.isSearching = false,
  });

  CreateListIdle copyWith({
    List<Movie>? selectedMovies,
    List<Movie>? searchResults,
    bool? isSearching,
  }) =>
      CreateListIdle(
        selectedMovies: selectedMovies ?? this.selectedMovies,
        searchResults: searchResults ?? this.searchResults,
        isSearching: isSearching ?? this.isSearching,
      );
}

class CreateListSaving extends CreateListState {
  final List<Movie> selectedMovies;

  const CreateListSaving({this.selectedMovies = const []});
}

class CreateListSuccess extends CreateListState {
  final MovieList list;

  const CreateListSuccess(this.list);
}

class CreateListError extends CreateListState {
  final String message;
  final List<Movie> selectedMovies;

  const CreateListError(this.message, {this.selectedMovies = const []});
}
