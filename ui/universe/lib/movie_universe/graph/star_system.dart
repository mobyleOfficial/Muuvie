import 'dart:ui';

import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';

/// A planet of a system, on the orbit of its [rank].
class OrbitingPlanet {
  final Movie movie;
  final int rank;

  const OrbitingPlanet({required this.movie, required this.rank});
}

/// One movie as a star, its similar movies in orbit, placed at [center] in
/// the universe. [parentStarId] is the system it was reached from; null for
/// the origin.
class StarSystem {
  final Movie star;
  final Offset center;
  final List<OrbitingPlanet> planets;
  final int? parentStarId;

  /// How many jumps away from the origin.
  final int hops;

  /// How many orbits the system was laid out with. Planets that left to
  /// become systems of their own keep their orbit empty, so the others do
  /// not move.
  final int orbitCount;

  const StarSystem({
    required this.star,
    required this.center,
    required this.planets,
    required this.parentStarId,
    required this.hops,
    required this.orbitCount,
  });

  double get extent => OrbitLayout.extent(orbitCount);

  StarSystem withoutPlanet(int movieId) => StarSystem(
    star: star,
    center: center,
    planets: [
      for (final planet in planets)
        if (planet.movie.id != movieId) planet,
    ],
    parentStarId: parentStarId,
    hops: hops,
    orbitCount: orbitCount,
  );
}
