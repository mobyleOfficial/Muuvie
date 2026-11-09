import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/graph/universe_graph.dart';
import 'package:universe_ui/movie_universe/movie_universe_state.dart';

/// Universo de Filmes (research/features/movie-universe/roadmap.md): the
/// similar movies of [origin] in orbit (phase 1), and any planet can become
/// a star system of its own (phase 2). Systems already visited stay in the
/// graph, so going back to one never loads it again.
///
/// Phase 3: the similar movies of the [prefetchedPlanets] closest planets of
/// the system in focus, and of the planet whose card is open, are loaded
/// ahead, so most jumps happen without waiting.
class MovieUniverseCubit extends Cubit<MovieUniverseState> {
  final GetSimilarMovies _getSimilarMovies;
  final Movie origin;
  final int prefetchedPlanets;

  /// Loads started ahead of a jump, by planet id. A failed one is dropped,
  /// so the jump itself asks again.
  final Map<int, Future<Result<List<SimilarMovie>>>> _prefetches = {};

  MovieUniverseCubit({
    required GetSimilarMovies getSimilarMovies,
    required this.origin,
    this.prefetchedPlanets = 3,
  }) : _getSimilarMovies = getSimilarMovies,
       super(const MovieUniverseLoading());

  /// [startAsList] opens the list rather than the map, for screen reader
  /// users. A reload keeps the view the user picked.
  Future<void> load({bool startAsList = false}) async {
    final current = state;
    final showAsList = current is MovieUniverseExploring
        ? current.showAsList
        : startAsList;
    emit(const MovieUniverseLoading());
    final result = await _getSimilarMovies(origin.id);
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) when data.isEmpty => const MovieUniverseEmpty(),
      Success(:final data) => MovieUniverseExploring(
        graph: UniverseGraph.origin(origin, data),
        currentStarId: origin.id,
        showAsList: showAsList,
      ),
      Failure() => const MovieUniverseFailure(),
    });
    _prefetchAroundFocus();
  }

  /// Opens the card of [planet]; null closes it. Selecting the open planet
  /// again closes it too.
  void select(Movie? planet) {
    final current = state;
    if (current is! MovieUniverseExploring) return;
    final next = planet?.id == current.selected?.id ? null : planet;
    emit(current.copyWith(selected: () => next));
    if (next != null && current.graph.systemOf(next.id) == null) {
      _prefetch(next.id);
    }
  }

  /// Turns [planet] into a star system with its own similar movies, and
  /// moves there. A planet that already is a system is only focused.
  Future<void> travelTo(Movie planet) async {
    final current = state;
    if (current is! MovieUniverseExploring || current.travelingTo != null) {
      return;
    }
    if (current.graph.systemOf(planet.id) != null) {
      focusSystem(planet.id);
      return;
    }
    if (current.graph.orbitedBy(planet.id) == null) return;
    final pending =
        _prefetches.remove(planet.id) ?? _getSimilarMovies(planet.id);
    emit(current.copyWith(travelingTo: () => planet));
    final result = await pending;
    if (isClosed) return;
    final latest = state;
    if (latest is! MovieUniverseExploring) return;
    emit(switch (result) {
      Success(:final data) => latest.copyWith(
        graph: latest.graph.addSystem(planet, data),
        currentStarId: planet.id,
        selected: () => null,
        travelingTo: () => null,
      ),
      Failure() => latest.copyWith(
        travelingTo: () => null,
        failedTravel: () => planet,
      ),
    });
    // After a failure the focus has not moved: asking again now would only
    // repeat it.
    if (result is Success) _prefetchAroundFocus();
  }

  /// Moves the focus to a system already in the universe.
  void focusSystem(int starId) {
    final current = state;
    if (current is! MovieUniverseExploring) return;
    if (current.graph.systemOf(starId) == null) return;
    emit(current.copyWith(currentStarId: starId, selected: () => null));
    _prefetchAroundFocus();
  }

  void backToOrigin() {
    final current = state;
    if (current is! MovieUniverseExploring) return;
    focusSystem(current.graph.originId);
  }

  void toggleView() {
    final current = state;
    if (current is! MovieUniverseExploring) return;
    emit(
      current.copyWith(showAsList: !current.showAsList, selected: () => null),
    );
  }

  /// Starts loading the closest planets of the system in focus.
  void _prefetchAroundFocus() {
    final current = state;
    if (current is! MovieUniverseExploring) return;
    for (final planet in current.currentSystem.planets.take(
      prefetchedPlanets,
    )) {
      _prefetch(planet.movie.id);
    }
  }

  void _prefetch(int planetId) {
    if (prefetchedPlanets <= 0 || _prefetches.containsKey(planetId)) return;
    final pending = _getSimilarMovies(planetId);
    _prefetches[planetId] = pending;
    pending.then((result) {
      if (result is Failure && identical(_prefetches[planetId], pending)) {
        _prefetches.remove(planetId);
      }
    });
  }
}
