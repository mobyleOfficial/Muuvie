import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:universe_ui/movie_universe/map/universe_game.dart';

/// The lines of a constellation (phase 5): one polyline through the planets
/// a public shelf keeps lit, system by system and in orbit order. Planets
/// move, so the points are read every frame; a single raw-points call draws
/// them, and nothing is drawn while no constellation is shown.
class ConstellationLines extends Component with HasGameReference<UniverseGame> {
  /// On-screen width, in logical pixels, at any zoom.
  static const _screenWidth = 1.5;

  final Paint _paint;
  Float32List _points = Float32List(0);

  ConstellationLines({required Color color})
    : _paint = Paint()
        ..color = color
        ..strokeCap = StrokeCap.round;

  @override
  void update(double dt) {
    final positions = game.constellationPoints();
    if (positions.length < 2) {
      _points = Float32List(0);
      return;
    }
    final points = _points.length == positions.length * 2
        ? _points
        : Float32List(positions.length * 2);
    for (var index = 0; index < positions.length; index++) {
      points[index * 2] = positions[index].x;
      points[index * 2 + 1] = positions[index].y;
    }
    _points = points;
  }

  @override
  void render(Canvas canvas) {
    if (_points.isEmpty) return;
    _paint.strokeWidth = _screenWidth / game.zoom;
    canvas.drawRawPoints(PointMode.polygon, _points, _paint);
  }
}
