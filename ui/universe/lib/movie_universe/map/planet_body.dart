import 'dart:math' as math;

import 'package:common/common.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';
import 'package:universe_ui/movie_universe/map/poster_detail.dart';
import 'package:universe_ui/movie_universe/map/poster_disc.dart';
import 'package:universe_ui/movie_universe/map/universe_game.dart';
import 'package:universe_ui/movie_universe/map/universe_palette.dart';

/// A similar movie in orbit around the star. Its poster is the small one
/// (w92) from afar and the medium one (w185) up close.
class PlanetBody extends PositionComponent with HasGameReference<UniverseGame> {
  static const _selectedScale = 1.25;

  /// On-screen radius, in logical pixels, past which w92 looks blurry.
  static const _largePosterRadius = 40.0;

  final Movie movie;
  final OrbitSlot slot;
  final bool animate;
  bool selected = false;
  double _angle;
  final PosterDisc _disc;
  final PosterDetail _poster;
  final Paint _ring;
  final Paint _selectedRing;
  final Paint _selectedHalo;

  PlanetBody({
    required Movie movie,
    required OrbitSlot slot,
    required UniversePalette palette,
    required bool animate,
  }) : this._(
         movie: movie,
         slot: slot,
         palette: palette,
         animate: animate,
         disc: PosterDisc(placeholder: palette.placeholder),
       );

  PlanetBody._({
    required this.movie,
    required this.slot,
    required UniversePalette palette,
    required this.animate,
    required PosterDisc disc,
  }) : _angle = slot.startAngle,
       _disc = disc,
       _poster = PosterDetail(
         smallUrl: movie.posterPath.isEmpty
             ? null
             : TmdbImageUrl.buildPosterSmall(movie.posterPath),
         largeUrl: movie.posterPath.isEmpty
             ? null
             : TmdbImageUrl.buildPosterMedium(movie.posterPath),
         switchUpAt: _largePosterRadius,
         disc: disc,
       ),
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
  void update(double dt) {
    _poster.update(
      screenRadius: visibleRadius * game.zoom,
      cache: game.posters,
    );
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
    _poster.dispose();
    super.onRemove();
  }
}
