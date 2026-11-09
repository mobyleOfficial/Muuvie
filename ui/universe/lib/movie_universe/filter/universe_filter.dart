import 'package:core/core.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/graph/universe_graph.dart';

/// The constellations of the universe (phase 4): which planets stand out.
/// Planets that do not match stay where they are, so the map never moves,
/// but they fade on the map and leave the list.
class UniverseFilter {
  static const none = UniverseFilter();

  /// One of the [SimilarMovie.genres]; null for any genre.
  final String? genre;

  /// The first year of a decade, such as 1980; null for any decade.
  final int? decade;

  /// Hides the movies the viewer already watched.
  final bool onlyUnwatched;

  const UniverseFilter({this.genre, this.decade, this.onlyUnwatched = false});

  bool get isActive => genre != null || decade != null || onlyUnwatched;

  /// A movie whose genres or year are unknown does not match a filter on
  /// them: there is nothing to show it belongs.
  bool matches(SimilarMovie similar) {
    if (onlyUnwatched && similar.movie.me?.status == WatchStatus.watched) {
      return false;
    }
    if (decade != null && decadeOf(similar.movie) != decade) return false;
    if (genre != null && !similar.genres.contains(genre)) return false;
    return true;
  }

  UniverseFilter withGenre(String? genre) => UniverseFilter(
    genre: genre,
    decade: decade,
    onlyUnwatched: onlyUnwatched,
  );

  UniverseFilter withDecade(int? decade) => UniverseFilter(
    genre: genre,
    decade: decade,
    onlyUnwatched: onlyUnwatched,
  );

  UniverseFilter withOnlyUnwatched(bool onlyUnwatched) => UniverseFilter(
    genre: genre,
    decade: decade,
    onlyUnwatched: onlyUnwatched,
  );

  static int? decadeOf(Movie movie) {
    final year = int.tryParse(movie.year ?? '');
    return year == null ? null : year ~/ 10 * 10;
  }

  @override
  bool operator ==(Object other) =>
      other is UniverseFilter &&
      other.genre == genre &&
      other.decade == decade &&
      other.onlyUnwatched == onlyUnwatched;

  @override
  int get hashCode => Object.hash(genre, decade, onlyUnwatched);
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
