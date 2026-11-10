import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/movies.dart';
import 'package:shelves/shelves.dart' show AddMovieToWatchlist;
import 'package:watch_logs/watch_logs.dart' show GetMovieWatchState;
import 'package:universe_ui/movie_universe/filter/universe_filter.dart';
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
///
/// Phase 4: planets carry the viewer's state, can go to "Quero ver" from
/// the card, and a [UniverseFilter] makes some of them stand out.
class MovieUniverseCubit extends Cubit<MovieUniverseState> {
  final GetSimilarMovies _getSimilarMovies;
  final AddMovieToWatchlist _addMovieToWatchlist;
  final GetMovieWatchState _getMovieWatchState;

  /// Systems whose similar movies are asked again at a time when the
  /// viewer's states are refreshed.
  static const _refreshBatch = 4;
  final Movie origin;
  final int prefetchedPlanets;

  /// Loads started ahead of a jump, by planet id. A failed one is dropped,
  /// so the jump itself asks again.
  final Map<int, Future<Result<List<SimilarMovie>>>> _prefetches = {};

  /// Movies whose state changed here while [refreshStates] was asking: the
  /// change made here is newer than what the refresh brings.
  final Set<int> _changedDuringRefresh = {};

  /// A screen reader is on: the universe starts on the list.
  bool _screenReader = false;

  /// The user picked map or list: nothing switches it for them any more.
  bool _viewPicked = false;

  MovieUniverseCubit({
    required GetSimilarMovies getSimilarMovies,
    required AddMovieToWatchlist addMovieToWatchlist,
    required GetMovieWatchState getMovieWatchState,
    required this.origin,
    this.prefetchedPlanets = 3,
  }) : _getSimilarMovies = getSimilarMovies,
       _addMovieToWatchlist = addMovieToWatchlist,
       _getMovieWatchState = getMovieWatchState,
       super(const MovieUniverseLoading());

  /// [startAsList] opens the list rather than the map, for screen reader
  /// users. A reload keeps the view and the filter the user picked.
  Future<void> load({bool startAsList = false}) async {
    final current = state;
    if (startAsList) _screenReader = true;
    final keptView = current is MovieUniverseExploring
        ? current.showAsList
        : null;
    final filter = current is MovieUniverseExploring
        ? current.filter
        : UniverseFilter.none;
    emit(const MovieUniverseLoading());
    final result = await _getSimilarMovies(origin.id);
    if (isClosed) return;
    emit(switch (result) {
      Success(:final data) when data.isEmpty => const MovieUniverseEmpty(),
      Success(:final data) => MovieUniverseExploring(
        graph: UniverseGraph.origin(origin, data),
        currentStarId: origin.id,
        // Read now: a screen reader may have been found during the load.
        showAsList: keptView ?? _screenReader,
        filter: filter,
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

  /// Shows only the planets that match [filter]. The open card closes when
  /// its planet no longer matches.
  void setFilter(UniverseFilter filter) {
    final current = state;
    if (current is! MovieUniverseExploring || current.filter == filter) return;
    final selected = current.selected;
    final selectedPlanet = selected == null
        ? null
        : current.graph.planetOf(selected.id);
    final keepSelected =
        selectedPlanet != null && filter.matches(selectedPlanet.similar);
    emit(
      current.copyWith(
        filter: filter,
        selected: keepSelected ? null : () => null,
      ),
    );
  }

  /// "Quero ver" in one tap: the planet shows it right away and goes back
  /// if the request fails. Answers whether it worked.
  Future<bool> addToWatchlist(Movie movie) async {
    final current = state;
    if (current is! MovieUniverseExploring) return false;
    final previous = _movieIn(current.graph, movie.id)?.me;
    if (previous?.status == WatchStatus.wantToWatch) return true;
    _setMovieState(
      movie.id,
      MovieListState(status: WatchStatus.wantToWatch, rating: previous?.rating),
    );
    final result = await _addMovieToWatchlist(movie.id);
    if (isClosed) return false;
    if (result is Failure) {
      _setMovieState(movie.id, previous);
      return false;
    }
    return true;
  }

  /// Asks the viewer's state of one movie again, after something outside
  /// the universe changed it (say, a shelf). A failure keeps the old one.
  Future<void> refreshMovieState(int movieId) async {
    final result = await _getMovieWatchState(movieId);
    if (isClosed) return;
    if (result case Success(:final data)) {
      final rating = data.rating?.rating;
      _setMovieState(
        movieId,
        data.status == null && rating == null
            ? null
            : MovieListState(status: data.status, rating: rating),
      );
    }
  }

  /// The viewer just logged in: every planet was loaded without their
  /// states. The similar movies of every system are asked again, a few at a
  /// time, and only the states are taken from them, so nothing moves. Loads
  /// started ahead are dropped, since they came without states too.
  Future<void> refreshStates() async {
    final current = state;
    if (current is! MovieUniverseExploring) return;
    _prefetches.clear();
    _changedDuringRefresh.clear();
    final starIds = [
      for (final system in current.graph.systems) system.star.id,
    ];
    final states = <int, MovieListState?>{};
    for (var start = 0; start < starIds.length; start += _refreshBatch) {
      final results = await Future.wait([
        for (final starId in starIds.skip(start).take(_refreshBatch))
          _getSimilarMovies(starId),
      ]);
      if (isClosed) return;
      for (final result in results) {
        if (result case Success(:final data)) {
          for (final similar in data) {
            states[similar.movie.id] = similar.movie.me;
          }
        }
      }
    }
    states.removeWhere((movieId, _) => _changedDuringRefresh.contains(movieId));
    final latest = state;
    if (latest is! MovieUniverseExploring) return;
    emit(latest.copyWith(graph: latest.graph.withMovieStates(states)));
    _prefetchAroundFocus();
  }

  void _setMovieState(int movieId, MovieListState? me) {
    _changedDuringRefresh.add(movieId);
    final current = state;
    if (current is! MovieUniverseExploring) return;
    emit(current.copyWith(graph: current.graph.withMovieState(movieId, me)));
  }

  static Movie? _movieIn(UniverseGraph graph, int movieId) =>
      graph.systemOf(movieId)?.star ?? graph.planetOf(movieId)?.movie;

  /// A screen reader turned out to be on after the load started: Android
  /// only reports it a frame or two after the app starts. Switches to the
  /// list unless the user already picked a view.
  void useScreenReader() {
    _screenReader = true;
    final current = state;
    if (_viewPicked || current is! MovieUniverseExploring) return;
    if (current.showAsList) return;
    emit(current.copyWith(showAsList: true, selected: () => null));
  }

  void toggleView() {
    final current = state;
    if (current is! MovieUniverseExploring) return;
    _viewPicked = true;
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
