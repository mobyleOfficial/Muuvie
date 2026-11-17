import 'dart:math' as math;
import 'dart:ui';

import 'package:core/core.dart';
import 'package:universe_ui/movie_universe/map/universe_palette.dart';

/// The viewer's state on the edge of a planet: a check for Já assisti, a
/// bookmark for Quero ver. The glyph carries the meaning, the color only
/// repeats it. It never gets smaller on screen than [minimumScreenRadius],
/// however far the user zooms out. Its geometry is kept until the size
/// changes, so most frames only draw it.
class StatusBadge {
  static const minimumScreenRadius = 7.0;

  final UniversePalette palette;
  final Paint _glyph;
  final Paint _outline;
  final Paint _watchedFill;
  final Paint _watchlistFill;
  final Paint _checkStroke;
  double? _builtForPlanet;
  double? _builtForRadius;
  late Offset _center;
  late double _radius;
  late Path _check;
  late Path _bookmark;

  StatusBadge({required this.palette})
    : _glyph = Paint()..color = palette.badgeGlyph,
      _outline = Paint()
        ..color = palette.badgeGlyph
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
      _watchedFill = Paint()..color = palette.watchedBadge,
      _watchlistFill = Paint()..color = palette.watchlistBadge,
      _checkStroke = Paint()
        ..color = palette.badgeGlyph
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

  /// [zoom] is the camera's: the badge is drawn in world units.
  void paint(
    Canvas canvas,
    double planetRadius,
    WatchStatus status, {
    required double zoom,
  }) {
    final radius = math.max(planetRadius * 0.34, minimumScreenRadius / zoom);
    // Rebuilt only when the size moves by more than 2%, so a pinch does not
    // rebuild it every frame.
    final builtRadius = _builtForRadius;
    if (_builtForPlanet != planetRadius ||
        builtRadius == null ||
        (radius - builtRadius).abs() > builtRadius * 0.02) {
      _build(planetRadius, radius);
    }
    switch (status) {
      case WatchStatus.watched:
        canvas.drawCircle(_center, _radius, _watchedFill);
        canvas.drawCircle(_center, _radius, _outline);
        canvas.drawPath(_check, _checkStroke);
      case WatchStatus.wantToWatch:
        canvas.drawCircle(_center, _radius, _watchlistFill);
        canvas.drawCircle(_center, _radius, _outline);
        canvas.drawPath(_bookmark, _glyph);
    }
  }

  /// Top right of the planet, half outside its edge.
  void _build(double planetRadius, double radius) {
    _builtForPlanet = planetRadius;
    _builtForRadius = radius;
    _radius = radius;
    const angle = -math.pi / 4;
    _center = Offset(math.cos(angle), math.sin(angle)) * planetRadius;
    final unit = _radius * 0.5;
    _checkStroke.strokeWidth = _radius * 0.28;
    _outline.strokeWidth = _radius * 0.2;
    _check = Path()
      ..moveTo(_center.dx - unit, _center.dy)
      ..lineTo(_center.dx - unit * 0.2, _center.dy + unit * 0.7)
      ..lineTo(_center.dx + unit, _center.dy - unit * 0.6);
    _bookmark = Path()
      ..moveTo(_center.dx - unit * 0.6, _center.dy - unit)
      ..lineTo(_center.dx + unit * 0.6, _center.dy - unit)
      ..lineTo(_center.dx + unit * 0.6, _center.dy + unit)
      ..lineTo(_center.dx, _center.dy + unit * 0.45)
      ..lineTo(_center.dx - unit * 0.6, _center.dy + unit)
      ..close();
  }
}
