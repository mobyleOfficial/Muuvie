import 'dart:math' as math;
import 'dart:ui';

/// A faint colored cloud in the world, behind the systems. Clouds are
/// generated per chunk from a seed, so a place keeps its clouds.
class NebulaCloud {
  final Offset center;
  final double radius;
  final Paint paint;

  NebulaCloud({
    required this.center,
    required this.radius,
    required Color color,
  }) : paint = Paint()
         ..shader = Gradient.radial(
           center,
           radius,
           [
             color,
             color.withValues(alpha: color.a * 0.35),
             color.withValues(alpha: 0),
           ],
           const [0, 0.55, 1],
         );

  /// Up to two clouds inside [bounds]; about half the chunks get none.
  static List<NebulaCloud> generate({
    required int seed,
    required Rect bounds,
    required List<Color> colors,
  }) {
    final random = math.Random(seed);
    final count = random.nextDouble() < 0.5 ? 0 : 1 + random.nextInt(2);
    return [
      for (var index = 0; index < count; index++)
        NebulaCloud(
          center: Offset(
            bounds.left + random.nextDouble() * bounds.width,
            bounds.top + random.nextDouble() * bounds.height,
          ),
          radius: bounds.shortestSide * (0.25 + random.nextDouble() * 0.3),
          color: colors[random.nextInt(colors.length)],
        ),
    ];
  }
}
