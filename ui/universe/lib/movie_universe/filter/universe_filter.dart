import 'package:core/core.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/filter/universe_constellation.dart';
import 'package:universe_ui/movie_universe/graph/universe_graph.dart';

/// Which planets stand out (phases 4 and 5). Planets that do not match stay
/// where they are, so the map never moves, but they fade on the map and
/// leave the list.
class UniverseFilter {
  static const none = UniverseFilter();

  /// One of the [SimilarMovie.genres]; null for any genre.
  final String? genre;

  /// The first year of a decade, such as 1980; null for any decade.
  final int? decade;

  /// Hides the movies the viewer already watched.
  final bool onlyUnwatched;

  /// A public shelf: only its movies stand out, joined by lines.
  final UniverseConstellation? constellation;

  const UniverseFilter({
    this.genre,
    this.decade,
    this.onlyUnwatched = false,
    this.constellation,
  });

  bool get isActive =>
      genre != null || decade != null || onlyUnwatched || constellation != null;

  /// A movie whose genres or year are unknown does not match a filter on
  /// them: there is nothing to show it belongs.
  bool matches(SimilarMovie similar) {
    if (onlyUnwatched && similar.movie.me?.status == WatchStatus.watched) {
      return false;
    }
    if (decade != null && decadeOf(similar.movie) != decade) return false;
    if (genre != null && !similar.genres.contains(genre)) return false;
    final shelf = constellation;
    if (shelf != null && !shelf.movieIds.contains(similar.movie.id)) {
      return false;
    }
    return true;
  }

  UniverseFilter _copy({
    String? Function()? genre,
    int? Function()? decade,
    bool? onlyUnwatched,
    UniverseConstellation? Function()? constellation,
  }) => UniverseFilter(
    genre: genre != null ? genre() : this.genre,
    decade: decade != null ? decade() : this.decade,
    onlyUnwatched: onlyUnwatched ?? this.onlyUnwatched,
    constellation: constellation != null ? constellation() : this.constellation,
  );

  UniverseFilter withGenre(String? genre) => _copy(genre: () => genre);

  UniverseFilter withDecade(int? decade) => _copy(decade: () => decade);

  UniverseFilter withOnlyUnwatched(bool onlyUnwatched) =>
      _copy(onlyUnwatched: onlyUnwatched);

  UniverseFilter withConstellation(UniverseConstellation? constellation) =>
      _copy(constellation: () => constellation);

  static int? decadeOf(Movie movie) {
    final year = int.tryParse(movie.year ?? '');
    return year == null ? null : year ~/ 10 * 10;
  }

  @override
  bool operator ==(Object other) =>
      other is UniverseFilter &&
      other.genre == genre &&
      other.decade == decade &&
      other.onlyUnwatched == onlyUnwatched &&
      other.constellation?.shelfId == constellation?.shelfId;

  @override
  int get hashCode =>
      Object.hash(genre, decade, onlyUnwatched, constellation?.shelfId);
}

/// The genres and decades the planets of the universe have, to offer only
/// filters that can match something.
class UniverseFilterOptions {
  /// Sorted alphabetically.
  final List<String> genres;

  /// Newest first.
  final List<int> decades;

  const UniverseFilterOptions({required this.genres, required this.decades});

  factory UniverseFilterOptions.of(UniverseGraph graph) {
    final genres = <String>{};
    final decades = <int>{};
    for (final system in graph.systems) {
      for (final planet in system.planets) {
        genres.addAll(planet.similar.genres);
        final decade = UniverseFilter.decadeOf(planet.movie);
        if (decade != null) decades.add(decade);
      }
    }
    return UniverseFilterOptions(
      genres: genres.toList()..sort(),
      decades: decades.toList()..sort((first, second) => second - first),
    );
  }
}
