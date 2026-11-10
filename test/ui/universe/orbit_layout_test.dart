import 'package:flutter_test/flutter_test.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';

List<double> _fallingScores(int count) => [
  for (var rank = 0; rank < count; rank++) 0.9 - rank * 0.05,
];

void main() {
  test('closer ranks orbit nearer, faster and bigger', () {
    final slots = OrbitLayout.slots(_fallingScores(10));

    for (var rank = 1; rank < slots.length; rank++) {
      expect(slots[rank].radius, greaterThan(slots[rank - 1].radius));
      expect(slots[rank].angularSpeed, lessThan(slots[rank - 1].angularSpeed));
      expect(
        slots[rank].planetRadius,
        lessThanOrEqualTo(slots[rank - 1].planetRadius),
      );
    }
  });

  test('neighbouring planets never overlap their orbits', () {
    // Equal scores: the tightest the layout can get.
    final slots = OrbitLayout.slots(List.filled(10, 1.0));

    for (var rank = 1; rank < slots.length; rank++) {
      final gap = slots[rank].radius - slots[rank - 1].radius;
      expect(
        gap,
        greaterThanOrEqualTo(
          slots[rank].planetRadius / 2 + slots[rank - 1].planetRadius / 2,
        ),
      );
    }
    expect(
      slots.first.radius - slots.first.planetRadius,
      greaterThan(OrbitLayout.starRadius),
    );
  });

  test('a bigger drop in score is a bigger gap between orbits', () {
    final close = OrbitLayout.slots([0.9, 0.85]);
    final far = OrbitLayout.slots([0.9, 0.4]);

    expect(
      far[1].radius - far[0].radius,
      greaterThan(close[1].radius - close[0].radius),
    );
    expect(
      far[1].radius - far[0].radius - (close[1].radius - close[0].radius),
      closeTo(0.45 * OrbitLayout.scoreGap, 1e-9),
    );
  });

  test('the less similar the first planet, the farther its orbit', () {
    expect(
      OrbitLayout.slots([0.3]).single.radius,
      greaterThan(OrbitLayout.slots([0.9]).single.radius),
    );
  });

  test('a score above the previous one adds no gap and never goes inward', () {
    final slots = OrbitLayout.slots([0.4, 0.9]);

    expect(slots[1].radius, greaterThan(slots[0].radius));
  });

  test('the same rank always starts at the same angle', () {
    expect(
      OrbitLayout.slots([0.9, 0.8, 0.7, 0.6])[3].startAngle,
      OrbitLayout.startAngle(3),
    );
  });

  test('the extent reaches the edge of the outermost planet', () {
    final slots = OrbitLayout.slots(_fallingScores(10));

    expect(
      OrbitLayout.extent(slots),
      slots.last.radius + slots.last.planetRadius,
    );
    expect(OrbitLayout.extent(const []), OrbitLayout.starRadius * 2);
  });
}
