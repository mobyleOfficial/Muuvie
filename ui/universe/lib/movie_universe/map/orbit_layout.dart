import 'dart:math' as math;

/// Where one planet circles the star. Distances are in world units, the
/// star sits at the origin.
class OrbitSlot {
  final double radius;
  final double startAngle;

  /// Radians per second; outer orbits are slower, as in a real system.
  final double angularSpeed;
  final double planetRadius;

  const OrbitSlot({
    required this.radius,
    required this.startAngle,
    required this.angularSpeed,
    required this.planetRadius,
  });
}

/// Places the planets of a star system by rank: the most similar movie on
/// the closest and biggest orbit. Phase 1 has no similarity score yet, so the
/// order of the backend list stands in for it.
abstract final class OrbitLayout {
  static const starRadius = 56.0;
  static const _firstGap = 72.0;
  static const _orbitStep = 36.0;
  static const _largestPlanet = 30.0;
  static const _smallestPlanet = 18.0;

  /// Successive planets are a golden angle apart, so neighbours in rank
  /// never line up on the same side of the star.
  static final _goldenAngle = math.pi * (3 - math.sqrt(5));

  static List<OrbitSlot> slots(int planetCount) => [
    for (var rank = 0; rank < planetCount; rank++) slot(rank),
  ];

  static OrbitSlot slot(int rank) {
    final radius = starRadius + _firstGap + rank * _orbitStep;
    return OrbitSlot(
      radius: radius,
      startAngle: (rank * _goldenAngle) % (2 * math.pi),
      angularSpeed: 0.18 / math.sqrt(radius / 100),
      planetRadius: math.max(_smallestPlanet, _largestPlanet - rank * 1.2),
    );
  }

  /// The radius of the whole system, outermost planet included.
  static double extent(int planetCount) {
    if (planetCount == 0) return starRadius * 2;
    final outermost = slot(planetCount - 1);
    return outermost.radius + outermost.planetRadius;
  }
}
