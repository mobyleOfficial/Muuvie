import 'package:flame/components.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/filter/universe_filter.dart';
import 'package:universe_ui/movie_universe/graph/star_system.dart';
import 'package:universe_ui/movie_universe/map/orbit_rings.dart';
import 'package:universe_ui/movie_universe/map/planet_body.dart';
import 'package:universe_ui/movie_universe/map/star_body.dart';
import 'package:universe_ui/movie_universe/map/universe_palette.dart';

/// One star system in the world: its orbits, its star and its planets, all
/// positioned relative to the system [center](StarSystem.center).
class SystemComponent extends PositionComponent {
  final Movie star;
  final UniversePalette palette;
  final bool animate;
  final Map<int, PlanetBody> _planets = {};
  StarSystem _system;

  SystemComponent({
    required StarSystem system,
    required this.palette,
    required this.animate,
  }) : star = system.star,
       _system = system,
       super(position: Vector2(system.center.dx, system.center.dy)) {
    final slots = system.orbits;
    add(OrbitRings(slots: slots, color: palette.orbit));
    add(
      StarBody(
        posterPath: system.star.posterPath,
        palette: palette,
        animate: animate,
      ),
    );
    for (final planet in system.planets) {
      final body = PlanetBody(
        movie: planet.movie,
        slot: slots[planet.rank],
        palette: palette,
        animate: animate,
      );
      _planets[planet.movie.id] = body;
      add(body);
    }
  }

  Iterable<PlanetBody> get planets => _planets.values;

  /// Brings the planets in line with [system]: drops the ones that left
  /// the orbit to become systems and shows the viewer's latest state.
  void sync(StarSystem system) {
    _system = system;
    _keepOnly(system);
    for (final planet in system.planets) {
      _planets[planet.movie.id]?.status = planet.movie.me?.status;
    }
  }

  /// Fades the planets [filter] leaves out.
  void applyFilter(UniverseFilter filter) {
    for (final planet in _system.planets) {
      _planets[planet.movie.id]?.dimmed = !filter.matches(planet.similar);
    }
  }

  void _keepOnly(StarSystem system) {
    final remaining = {for (final planet in system.planets) planet.movie.id};
    final departed = _planets.keys
        .where((movieId) => !remaining.contains(movieId))
        .toList();
    for (final movieId in departed) {
      _planets.remove(movieId)?.removeFromParent();
    }
  }
}
