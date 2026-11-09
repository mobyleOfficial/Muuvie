import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';
import 'package:universe_ui/movie_universe/map/poster_disc.dart';
import 'package:universe_ui/movie_universe/map/poster_image_loader.dart';
import 'package:universe_ui/movie_universe/map/universe_palette.dart';

/// The chosen movie, at the center: its poster inside a pulsing glow.
class StarBody extends PositionComponent {
  static const _glowScale = 2.4;

  final String? posterUrl;
  final UniversePalette palette;
  final bool animate;
  final PosterDisc _disc;
  final Paint _ring;
  late final Paint _glow;
  double _time = 0;
  bool _removed = false;

  StarBody({
    required this.posterUrl,
    required this.palette,
    required this.animate,
  }) : _disc = PosterDisc(placeholder: palette.placeholder),
       _ring = Paint()
         ..color = palette.starGlow
         ..style = PaintingStyle.stroke
         ..strokeWidth = 3,
       super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    const glowRadius = OrbitLayout.starRadius * _glowScale;
    _glow = Paint()
      ..shader = RadialGradient(
        colors: [
          palette.starGlow.withValues(alpha: 0.55),
          palette.starGlow.withValues(alpha: 0.12),
          palette.starGlow.withValues(alpha: 0),
        ],
        stops: const [0.35, 0.7, 1],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: glowRadius));
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
    if (animate) _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final pulse = 1 + 0.04 * math.sin(_time * 1.6);
    canvas
      ..save()
      ..scale(pulse)
      ..drawCircle(Offset.zero, OrbitLayout.starRadius * _glowScale, _glow)
      ..restore();
    _disc.paint(canvas, OrbitLayout.starRadius);
    canvas.drawCircle(Offset.zero, OrbitLayout.starRadius, _ring);
  }

  @override
  void onRemove() {
    _removed = true;
    _disc.dispose();
    super.onRemove();
  }
}
