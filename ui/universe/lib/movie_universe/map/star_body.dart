import 'dart:math' as math;

import 'package:common/common.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';
import 'package:universe_ui/movie_universe/map/poster_detail.dart';
import 'package:universe_ui/movie_universe/map/poster_disc.dart';
import 'package:universe_ui/movie_universe/map/universe_game.dart';
import 'package:universe_ui/movie_universe/map/universe_palette.dart';

/// The chosen movie, at the center: its poster inside a pulsing glow. The
/// poster is w185 from afar and w342 up close.
class StarBody extends PositionComponent with HasGameReference<UniverseGame> {
  static const _glowScale = 2.4;
  static const _largePosterRadius = 90.0;

  final UniversePalette palette;
  final bool animate;
  final PosterDisc _disc;
  final PosterDetail _poster;
  final Paint _ring;
  late final Paint _glow;
  double _time = 0;

  StarBody({
    required String posterPath,
    required UniversePalette palette,
    required bool animate,
  }) : this._(
         posterPath: posterPath,
         palette: palette,
         animate: animate,
         disc: PosterDisc(placeholder: palette.placeholder),
       );

  StarBody._({
    required String posterPath,
    required this.palette,
    required this.animate,
    required PosterDisc disc,
  }) : _disc = disc,
       _poster = PosterDetail(
         smallUrl: posterPath.isEmpty
             ? null
             : TmdbImageUrl.buildPosterMedium(posterPath),
         largeUrl: posterPath.isEmpty
             ? null
             : TmdbImageUrl.buildPosterLarge(posterPath),
         switchUpAt: _largePosterRadius,
         disc: disc,
       ),
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
  }

  @override
  void update(double dt) {
    _poster.update(
      screenRadius: OrbitLayout.starRadius * game.zoom,
      cache: game.posters,
    );
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
    _poster.dispose();
    super.onRemove();
  }
}
