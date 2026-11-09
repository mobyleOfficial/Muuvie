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

/// Places the planets of a star system by similarity: the most similar
/// movie on the closest and biggest orbit. Orbits follow the ranks, one
/// after the other, and the score widens the gap: a planet much less similar
/// than the one before it sits visibly farther out.
abstract final class OrbitLayout {
  static const starRadius = 56.0;
  static const _firstGap = 72.0;
  static const _orbitStep = 36.0;
  static const _largestPlanet = 30.0;
  static const _smallestPlanet = 18.0;

  /// Extra distance for each whole point of score lost: before the first
  /// orbit (from a perfect 1) and between two neighbouring orbits.
  static const scoreGap = 120.0;

  /// Successive planets are a golden angle apart, so neighbours in rank
  /// never line up on the same side of the star.
  static final _goldenAngle = math.pi * (3 - math.sqrt(5));

  /// One slot per score, in rank order. Scores are expected to fall from
  /// one rank to the next; a score higher than the previous one adds no gap.
  static List<OrbitSlot> slots(List<double> scores) {
    final slots = <OrbitSlot>[];
    var radius = 0.0;
    for (var rank = 0; rank < scores.length; rank++) {
      final score = scores[rank].clamp(0.0, 1.0);
      radius = rank == 0
          ? starRadius + _firstGap + (1 - score) * scoreGap
          : radius +
                _orbitStep +
                math.max(0.0, scores[rank - 1].clamp(0.0, 1.0) - score) *
                    scoreGap;
      slots.add(_slot(rank, radius));
    }
    return slots;
  }

  /// The angle the planet of [rank] starts at, whatever its score.
  static double startAngle(int rank) => (rank * _goldenAngle) % (2 * math.pi);

  static OrbitSlot _slot(int rank, double radius) => OrbitSlot(
    radius: radius,
    startAngle: startAngle(rank),
    angularSpeed: 0.18 / math.sqrt(radius / 100),
    planetRadius: math.max(_smallestPlanet, _largestPlanet - rank * 1.2),
  );

  /// The radius of the whole system, outermost planet included.
  static double extent(List<OrbitSlot> slots) {
    if (slots.isEmpty) return starRadius * 2;
    final outermost = slots.last;
    return outermost.radius + outermost.planetRadius;
  }
}
