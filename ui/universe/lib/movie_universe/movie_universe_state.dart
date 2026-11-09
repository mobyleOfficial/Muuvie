import 'package:movies/movies.dart';
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
/// list of the system in focus.
final class MovieUniverseExploring extends MovieUniverseState {
  final UniverseGraph graph;
  final int currentStarId;
  final Movie? selected;
  final Movie? travelingTo;
  final Movie? failedTravel;
  final bool showAsList;

  const MovieUniverseExploring({
    required this.graph,
    required this.currentStarId,
    this.selected,
    this.travelingTo,
    this.failedTravel,
    this.showAsList = false,
  });

  StarSystem get currentSystem => graph.systemOf(currentStarId)!;

  MovieUniverseExploring copyWith({
    UniverseGraph? graph,
    int? currentStarId,
    Movie? Function()? selected,
    Movie? Function()? travelingTo,
    Movie? Function()? failedTravel,
    bool? showAsList,
  }) => MovieUniverseExploring(
    graph: graph ?? this.graph,
    currentStarId: currentStarId ?? this.currentStarId,
    selected: selected != null ? selected() : this.selected,
    travelingTo: travelingTo != null ? travelingTo() : this.travelingTo,
    // A failure is reported once: any other change clears it.
    failedTravel: failedTravel?.call(),
    showAsList: showAsList ?? this.showAsList,
  );
}

/// The movie has no similar movies: a star alone, nowhere to go.
final class MovieUniverseEmpty extends MovieUniverseState {
  const MovieUniverseEmpty();
}

final class MovieUniverseFailure extends MovieUniverseState {
  const MovieUniverseFailure();
}
