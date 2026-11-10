import 'dart:math' as math;
import 'dart:ui';

import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/graph/star_system.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';

/// The universe explored so far: every system visited, where each one sits,
/// and which one it was reached from. Every movie appears once: a star or a
/// planet, never both, never twice.
///
/// Immutable: [addSystem] answers a new graph.
class UniverseGraph {
  /// Empty space kept between two neighbouring systems.
  static const systemGap = 120.0;

  /// Planets of a system spread new systems over this cone, centered on the
  /// direction away from where the system itself came from.
  static const _spreadCone = 2 * math.pi / 3;
  static const _turnStep = math.pi / 9;

  final int originId;
  final Map<int, StarSystem> _systems;

  const UniverseGraph._(this.originId, this._systems);

  /// The origin at the center of the universe, with [similarMovies] in orbit.
  factory UniverseGraph.origin(Movie star, List<SimilarMovie> similarMovies) {
    final planets = _rankPlanets(similarMovies, placed: {star.id});
    return UniverseGraph._(star.id, {
      star.id: StarSystem(
        star: star,
        center: Offset.zero,
        planets: planets,
        parentStarId: null,
        hops: 0,
        orbits: _orbitsOf(planets),
      ),
    });
  }

  Iterable<StarSystem> get systems => _systems.values;

  StarSystem get origin => _systems[originId]!;

  StarSystem? systemOf(int starId) => _systems[starId];

  /// The system [movieId] orbits, when it is a planet.
  StarSystem? orbitedBy(int movieId) {
    for (final system in _systems.values) {
      if (system.planets.any((planet) => planet.movie.id == movieId)) {
        return system;
      }
    }
    return null;
  }

  /// The planet of [movieId], with how similar it is to its star; null when
  /// the movie is a star or not in the universe.
  OrbitingPlanet? planetOf(int movieId) {
    for (final system in _systems.values) {
      for (final planet in system.planets) {
        if (planet.movie.id == movieId) return planet;
      }
    }
    return null;
  }

  /// The movie of [movieId], star or planet, with the viewer's state [me].
  /// Only the system holding it changes.
  UniverseGraph withMovieState(int movieId, MovieListState? me) {
    final holder = _systems.containsKey(movieId)
        ? _systems[movieId]
        : orbitedBy(movieId);
    if (holder == null) return this;
    final movie = holder.star.id == movieId
        ? holder.star
        : holder.planets
              .firstWhere((planet) => planet.movie.id == movieId)
              .movie;
    return UniverseGraph._(originId, {
      ..._systems,
      holder.star.id: holder.withMovie(movie.withMe(me)),
    });
  }

  /// Every planet whose id is in [states] gets that state; the others keep
  /// theirs. How a fresh look at the viewer's shelves (after a login)
  /// reaches the whole universe at once.
  UniverseGraph withMovieStates(Map<int, MovieListState?> states) {
    if (states.isEmpty) return this;
    final systems = <int, StarSystem>{};
    for (final MapEntry(key: starId, value: system) in _systems.entries) {
      var updated = system;
      for (final planet in system.planets) {
        if (!states.containsKey(planet.movie.id)) continue;
        updated = updated.withMovie(
          planet.movie.withMe(states[planet.movie.id]),
        );
      }
      systems[starId] = updated;
    }
    return UniverseGraph._(originId, systems);
  }

  bool contains(int movieId) =>
      _systems.containsKey(movieId) || orbitedBy(movieId) != null;

  /// [planet] leaves the orbit of its system and becomes a new system, with
  /// [similarMovies] in orbit. Movies already somewhere in the universe are
  /// left out: the universe never shows a movie twice.
  UniverseGraph addSystem(Movie planet, List<SimilarMovie> similarMovies) {
    final parent = orbitedBy(planet.id);
    if (parent == null) {
      throw ArgumentError('${planet.id} does not orbit any system');
    }
    final rank = parent.planets
        .firstWhere((orbiting) => orbiting.movie.id == planet.id)
        .rank;
    final placed = {
      for (final system in _systems.values) ...[
        system.star.id,
        for (final orbiting in system.planets) orbiting.movie.id,
      ],
    };
    final planets = _rankPlanets(similarMovies, placed: placed);
    final orbits = _orbitsOf(planets);
    final extent = OrbitLayout.extent(orbits);
    final systems = {
      ..._systems,
      parent.star.id: parent.withoutPlanet(planet.id),
    };
    systems[planet.id] = StarSystem(
      star: planet,
      center: _freeSpot(parent, rank, extent),
      planets: planets,
      parentStarId: parent.star.id,
      hops: parent.hops + 1,
      orbits: orbits,
    );
    return UniverseGraph._(originId, systems);
  }

  /// The smallest rectangle holding every system.
  Rect get bounds => _systems.values
      .map(
        (system) =>
            Rect.fromCircle(center: system.center, radius: system.extent),
      )
      .reduce((union, rect) => union.expandToInclude(rect));

  static List<OrbitingPlanet> _rankPlanets(
    List<SimilarMovie> similarMovies, {
    required Set<int> placed,
  }) {
    final seen = {...placed};
    final planets = <OrbitingPlanet>[];
    for (final similar in similarMovies) {
      if (!seen.add(similar.movie.id)) continue;
      planets.add(OrbitingPlanet(similar: similar, rank: planets.length));
    }
    return planets;
  }

  static List<OrbitSlot> _orbitsOf(List<OrbitingPlanet> planets) =>
      OrbitLayout.slots([for (final planet in planets) planet.similar.score]);

  /// Where a new system of [extent] goes, next to [parent], in the direction
  /// of the orbit [rank] it came from and away from the parent's own parent.
  /// When that spot overlaps another system it turns, both ways, step by
  /// step; if a whole turn fails it moves farther out and tries again.
  Offset _freeSpot(StarSystem parent, int rank, double extent) {
    final grandparent = parent.parentStarId == null
        ? null
        : _systems[parent.parentStarId];
    final slotAngle = OrbitLayout.startAngle(rank);
    final direction = grandparent == null
        ? slotAngle
        : _angleOf(parent.center - grandparent.center) +
              (slotAngle / (2 * math.pi) - 0.5) * _spreadCone;
    var distance = parent.extent + extent + systemGap;
    while (true) {
      for (var turn = 0; turn * _turnStep <= math.pi; turn++) {
        for (final sign in turn == 0 ? const [1] : const [1, -1]) {
          final angle = direction + sign * turn * _turnStep;
          final center =
              parent.center +
              Offset(math.cos(angle), math.sin(angle)) * distance;
          if (_isFree(center, extent)) return center;
        }
      }
      distance *= 1.5;
    }
  }

  bool _isFree(Offset center, double extent) => _systems.values.every(
    (system) =>
        (system.center - center).distance >= system.extent + extent + systemGap,
  );

  static double _angleOf(Offset vector) => math.atan2(vector.dy, vector.dx);
}
