import 'package:common/common.dart';
import 'package:flame/components.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/graph/star_system.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';
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

  SystemComponent({
    required StarSystem system,
    required this.palette,
    required this.animate,
  }) : star = system.star,
       super(position: Vector2(system.center.dx, system.center.dy)) {
    final slots = OrbitLayout.slots(system.orbitCount);
    add(OrbitRings(slots: slots, color: palette.orbit));
    add(
      StarBody(
        posterUrl: posterUrl(system.star, large: true),
        palette: palette,
        animate: animate,
      ),
    );
    for (final planet in system.planets) {
      final body = PlanetBody(
        movie: planet.movie,
        slot: slots[planet.rank],
        posterUrl: posterUrl(planet.movie),
        palette: palette,
        animate: animate,
      );
      _planets[planet.movie.id] = body;
      add(body);
    }
  }

  Iterable<PlanetBody> get planets => _planets.values;

  /// Removes the planets that left the orbit to become systems.
  void keepOnly(StarSystem system) {
    final remaining = {for (final planet in system.planets) planet.movie.id};
    final departed = _planets.keys
        .where((movieId) => !remaining.contains(movieId))
        .toList();
    for (final movieId in departed) {
      _planets.remove(movieId)?.removeFromParent();
    }
  }

  static String? posterUrl(Movie movie, {bool large = false}) {
    if (movie.posterPath.isEmpty) return null;
    return large
        ? TmdbImageUrl.buildPosterMedium(movie.posterPath)
        : TmdbImageUrl.buildPosterSmall(movie.posterPath);
  }
}
