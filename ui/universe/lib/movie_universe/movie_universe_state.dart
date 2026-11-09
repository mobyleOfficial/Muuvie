import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/filter/universe_filter.dart';
import 'package:universe_ui/movie_universe/graph/star_system.dart';
import 'package:universe_ui/movie_universe/graph/universe_graph.dart';

/// The universe of one movie: the movie is the star, its similar movies are
/// the planets around it, and every planet can become a system of its own.
sealed class MovieUniverseState {
  const MovieUniverseState();
}

final class MovieUniverseLoading extends MovieUniverseState {
  const MovieUniverseLoading();
}

/// Systems are open. [currentStarId] is the system in focus; [selected] is
/// the planet whose card is open; [travelingTo] is the planet whose system
/// is loading; [failedTravel] is the last planet a jump to failed, so the
/// page can say so once. [showAsList] swaps the star map for the accessible
/// list of the system in focus. [filter] picks the planets that stand out
/// (phase 4).
final class MovieUniverseExploring extends MovieUniverseState {
  final UniverseGraph graph;
  final int currentStarId;
  final Movie? selected;
  final Movie? travelingTo;
  final Movie? failedTravel;
  final bool showAsList;
  final UniverseFilter filter;

  const MovieUniverseExploring({
    required this.graph,
    required this.currentStarId,
    this.selected,
    this.travelingTo,
    this.failedTravel,
    this.showAsList = false,
    this.filter = UniverseFilter.none,
  });

  StarSystem get currentSystem => graph.systemOf(currentStarId)!;

  /// The planets of the system in focus that match [filter], in orbit order.
  List<OrbitingPlanet> get matchingPlanets => [
    for (final planet in currentSystem.planets)
      if (filter.matches(planet.similar)) planet,
  ];

  MovieUniverseExploring copyWith({
    UniverseGraph? graph,
    int? currentStarId,
    Movie? Function()? selected,
    Movie? Function()? travelingTo,
    Movie? Function()? failedTravel,
    bool? showAsList,
    UniverseFilter? filter,
  }) => MovieUniverseExploring(
    graph: graph ?? this.graph,
    currentStarId: currentStarId ?? this.currentStarId,
    selected: selected != null ? selected() : this.selected,
    travelingTo: travelingTo != null ? travelingTo() : this.travelingTo,
    // A failure is reported once: any other change clears it.
    failedTravel: failedTravel?.call(),
    showAsList: showAsList ?? this.showAsList,
    filter: filter ?? this.filter,
  );
}

/// The movie has no similar movies: a star alone, nowhere to go.
final class MovieUniverseEmpty extends MovieUniverseState {
  const MovieUniverseEmpty();
}

final class MovieUniverseFailure extends MovieUniverseState {
  const MovieUniverseFailure();
}
