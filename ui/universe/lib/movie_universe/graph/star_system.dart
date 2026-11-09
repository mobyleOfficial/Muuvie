import 'dart:ui';

import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';

/// A planet of a system, on the orbit of its [rank].
class OrbitingPlanet {
  final SimilarMovie similar;
  final int rank;

  const OrbitingPlanet({required this.similar, required this.rank});

  Movie get movie => similar.movie;

  OrbitingPlanet withMovie(Movie movie) =>
      OrbitingPlanet(similar: similar.withMovie(movie), rank: rank);
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

  /// The orbits the system was laid out with, one per rank. Planets that
  /// left to become systems of their own keep their orbit empty, so the
  /// others do not move.
  final List<OrbitSlot> orbits;

  const StarSystem({
    required this.star,
    required this.center,
    required this.planets,
    required this.parentStarId,
    required this.hops,
    required this.orbits,
  });

  double get extent => OrbitLayout.extent(orbits);

  /// The same system with [movie] in place of the star or planet of the
  /// same id: how the viewer's state of a movie reaches the map.
  StarSystem withMovie(Movie movie) => StarSystem(
    star: star.id == movie.id ? movie : star,
    center: center,
    planets: [
      for (final planet in planets)
        planet.movie.id == movie.id ? planet.withMovie(movie) : planet,
    ],
    parentStarId: parentStarId,
    hops: hops,
    orbits: orbits,
  );

  StarSystem withoutPlanet(int movieId) => StarSystem(
    star: star,
    center: center,
    planets: [
      for (final planet in planets)
        if (planet.movie.id != movieId) planet,
    ],
    parentStarId: parentStarId,
    hops: hops,
    orbits: orbits,
  );
}
