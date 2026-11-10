import 'package:flame/components.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/filter/universe_filter.dart';
import 'package:universe_ui/movie_universe/graph/star_system.dart';
import 'package:universe_ui/movie_universe/map/orbit_rings.dart';
import 'package:universe_ui/movie_universe/map/planet_body.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';
import 'package:universe_ui/movie_universe/map/star_body.dart';
import 'package:universe_ui/movie_universe/map/travel_flight.dart';
import 'package:universe_ui/movie_universe/map/universe_palette.dart';

/// One star system in the world: its orbits, its star and its planets, all
/// positioned relative to the system [center](StarSystem.center).
///
/// A system reached by travel arrives: its star sets off from where the
/// planet was ([arrivingFrom], relative to the center) at the planet's size,
/// grows on the way, and its orbits and planets open around it as it
/// settles.
class SystemComponent extends PositionComponent {
  /// How long the arrival takes until [arriveIn] says otherwise.
  static const _defaultArrival = 1.4;

  /// Share of the arrival after which the orbits start to show, and after
  /// which the planets start to come out.
  static const _ringsFrom = 0.55;
  static const _planetsFrom = 0.8;

  /// Between two planets coming out, in rank order.
  static const _planetStagger = 0.07;

  final Movie star;
  final UniversePalette palette;
  final bool animate;
  final Map<int, PlanetBody> _planets = {};
  final OrbitRings _rings;
  final StarBody _star;
  StarSystem _system;
  Vector2? _arrivingFrom;
  final double _arrivingScale;
  double _arrivalDuration = _defaultArrival;
  double _arrivalElapsed = 0;
  bool _planetsOut = true;

  SystemComponent({
    required StarSystem system,
    required this.palette,
    required this.animate,
    Vector2? arrivingFrom,
    double? arrivingRadius,
  }) : star = system.star,
       _system = system,
       _rings = OrbitRings(slots: system.orbits, color: palette.orbit),
       _star = StarBody(
         posterPath: system.star.posterPath,
         palette: palette,
         animate: animate,
       ),
       _arrivingFrom = animate ? arrivingFrom : null,
       _arrivingScale =
           (arrivingRadius ?? OrbitLayout.starRadius) / OrbitLayout.starRadius,
       super(position: Vector2(system.center.dx, system.center.dy)) {
    final slots = system.orbits;
    add(_rings);
    add(_star);
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
    if (_arrivingFrom != null) {
      _planetsOut = false;
      _rings.reveal = 0;
      for (final body in _planets.values) {
        body.hide();
      }
      _showArrival(0);
    }
  }

  /// Times the arrival to end with the camera, [seconds] from now; 0 lands
  /// at once.
  void arriveIn(double seconds) {
    if (_arrivingFrom == null) return;
    _arrivalDuration = seconds;
    _arrivalElapsed = 0;
    if (seconds <= 0) _showArrival(1);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_arrivingFrom == null) return;
    _arrivalElapsed += dt;
    _showArrival(
      _arrivalDuration <= 0 ? 1 : _arrivalElapsed / _arrivalDuration,
    );
  }

  void _showArrival(double progress) {
    final from = _arrivingFrom;
    if (from == null) return;
    final done = progress.clamp(0.0, 1.0);
    final eased = TravelFlight.easeInOutCubic(done);
    _star
      ..position = from * (1 - eased)
      ..scale.setAll(_arrivingScale + (1 - _arrivingScale) * eased);
    _rings.reveal = ((done - _ringsFrom) / (1 - _ringsFrom)).clamp(0.0, 1.0);
    if (!_planetsOut && done >= _planetsFrom) {
      _planetsOut = true;
      for (final planet in _system.planets) {
        _planets[planet.movie.id]?.comeOut(
          delay: planet.rank * _planetStagger,
          instantly: done >= 1 && _arrivalDuration <= 0,
        );
      }
    }
    if (done >= 1) _arrivingFrom = null;
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
