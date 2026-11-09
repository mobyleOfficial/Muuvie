import 'package:flutter_test/flutter_test.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';

void main() {
  test('closer ranks orbit nearer, faster and bigger', () {
    final slots = OrbitLayout.slots(10);

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
    final slots = OrbitLayout.slots(10);

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

  test('the same rank always lands on the same orbit', () {
    expect(OrbitLayout.slot(3).startAngle, OrbitLayout.slot(3).startAngle);
    expect(OrbitLayout.slot(3).radius, OrbitLayout.slots(5)[3].radius);
  });

  test('the extent reaches the edge of the outermost planet', () {
    final outermost = OrbitLayout.slot(9);

    expect(OrbitLayout.extent(10), outermost.radius + outermost.planetRadius);
    expect(OrbitLayout.extent(0), OrbitLayout.starRadius * 2);
  });
}
