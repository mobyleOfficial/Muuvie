import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_ui/movie_universe/map/travel_flight.dart';

TravelFlight _flight({required double distance}) => TravelFlight(
  from: Vector2.zero(),
  to: Vector2(distance, 0),
  fromZoom: 1,
  toZoom: 0.5,
  screenWidth: 400,
);

void main() {
  test('starts where the camera is and lands on the system', () {
    final flight = _flight(distance: 1200);
    expect(flight.position, Vector2.zero());
    expect(flight.zoom, closeTo(1, 1e-9));

    flight.advance(flight.duration);
    expect(flight.isOver, isTrue);
    expect(flight.position.x, closeTo(1200, 1e-6));
    expect(flight.zoom, closeTo(0.5, 1e-9));
  });

  test('pulls back past both ends at mid flight on a long trip', () {
    final flight = _flight(distance: 1600)..advance(0);
    flight.advance(flight.duration / 2);
    expect(flight.zoom, lessThan(0.5));
    expect(flight.rush, closeTo(1, 1e-9));
  });

  test('a hop within the screen is short and barely pulls back', () {
    final hop = _flight(distance: 100);
    final trip = _flight(distance: 4000);
    expect(hop.duration, lessThan(trip.duration));
    hop.advance(hop.duration / 2);
    expect(hop.zoom, greaterThan(0.5 * 0.9));
  });

  test('moves slowly at both ends and fastest in the middle', () {
    final flight = _flight(distance: 1200);
    double positionAt(double share) {
      final probe = _flight(distance: 1200)..advance(flight.duration * share);
      return probe.position.x;
    }

    final start = positionAt(0.05) - positionAt(0);
    final middle = positionAt(0.55) - positionAt(0.5);
    final end = positionAt(1) - positionAt(0.95);
    expect(middle, greaterThan(start * 5));
    expect(middle, greaterThan(end * 5));
  });
}
