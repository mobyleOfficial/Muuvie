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
  factory UniverseGraph.origin(Movie star, List<Movie> similarMovies) {
    final planets = _rankPlanets(similarMovies, placed: {star.id});
    return UniverseGraph._(star.id, {
      star.id: StarSystem(
        star: star,
        center: Offset.zero,
        planets: planets,
        parentStarId: null,
        hops: 0,
        orbitCount: planets.length,
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

  bool contains(int movieId) =>
      _systems.containsKey(movieId) || orbitedBy(movieId) != null;

  /// [planet] leaves the orbit of its system and becomes a new system, with
  /// [similarMovies] in orbit. Movies already somewhere in the universe are
  /// left out: the universe never shows a movie twice.
  UniverseGraph addSystem(Movie planet, List<Movie> similarMovies) {
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
    final extent = OrbitLayout.extent(planets.length);
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
      orbitCount: planets.length,
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
    List<Movie> movies, {
    required Set<int> placed,
  }) {
    final seen = {...placed};
    final planets = <OrbitingPlanet>[];
    for (final movie in movies) {
      if (!seen.add(movie.id)) continue;
      planets.add(OrbitingPlanet(movie: movie, rank: planets.length));
    }
    return planets;
  }

  /// Where a new system of [extent] goes, next to [parent], in the direction
  /// of the orbit [rank] it came from and away from the parent's own parent.
  /// When that spot overlaps another system it turns, both ways, step by
  /// step; if a whole turn fails it moves farther out and tries again.
  Offset _freeSpot(StarSystem parent, int rank, double extent) {
    final grandparent = parent.parentStarId == null
        ? null
        : _systems[parent.parentStarId];
    final slotAngle = OrbitLayout.slot(rank).startAngle;
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
