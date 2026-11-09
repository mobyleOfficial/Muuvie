import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';
import 'package:universe_ui/movie_universe/map/poster_disc.dart';
import 'package:universe_ui/movie_universe/map/poster_image_loader.dart';
import 'package:universe_ui/movie_universe/map/universe_palette.dart';

/// A similar movie in orbit around the star.
class PlanetBody extends PositionComponent {
  static const _selectedScale = 1.25;

  final Movie movie;
  final OrbitSlot slot;
  final String? posterUrl;
  final bool animate;
  bool selected = false;
  double _angle;
  bool _removed = false;
  final PosterDisc _disc;
  final Paint _ring;
  final Paint _selectedRing;
  final Paint _selectedHalo;

  PlanetBody({
    required this.movie,
    required this.slot,
    required this.posterUrl,
    required UniversePalette palette,
    required this.animate,
  }) : _angle = slot.startAngle,
       _disc = PosterDisc(placeholder: palette.placeholder),
       _ring = Paint()
         ..color = palette.planetRing
         ..style = PaintingStyle.stroke
         ..strokeWidth = 1.5,
       _selectedRing = Paint()
         ..color = palette.highlight
         ..style = PaintingStyle.stroke
         ..strokeWidth = 3,
       _selectedHalo = Paint()
         ..color = palette.highlight.withValues(alpha: 0.6)
         ..style = PaintingStyle.stroke
         ..strokeWidth = 6,
       super(anchor: Anchor.center) {
    _moveToAngle();
  }

  /// The radius on screen, bigger while selected.
  double get visibleRadius =>
      slot.planetRadius * (selected ? _selectedScale : 1);

  @override
  Future<void> onLoad() async {
    final url = posterUrl;
    if (url == null) return;
    PosterImageLoader.load(url).then((image) {
      if (_removed) {
        image?.dispose();
      } else {
        _disc.image = image;
      }
    });
  }

  @override
  void update(double dt) {
    // The selected planet holds still, so its card points at it.
    if (!animate || selected) return;
    _angle = (_angle + slot.angularSpeed * dt) % (2 * math.pi);
    _moveToAngle();
  }

  void _moveToAngle() => position.setValues(
    slot.radius * math.cos(_angle),
    slot.radius * math.sin(_angle),
  );

  @override
  void render(Canvas canvas) {
    final radius = visibleRadius;
    if (selected) canvas.drawCircle(Offset.zero, radius + 8, _selectedHalo);
    _disc.paint(canvas, radius);
    canvas.drawCircle(Offset.zero, radius, selected ? _selectedRing : _ring);
  }

  @override
  void onRemove() {
    _removed = true;
    _disc.dispose();
    super.onRemove();
  }
}
