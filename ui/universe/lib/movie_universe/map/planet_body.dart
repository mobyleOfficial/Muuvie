import 'dart:math' as math;

import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';
import 'package:universe_ui/movie_universe/map/poster_detail.dart';
import 'package:universe_ui/movie_universe/map/poster_disc.dart';
import 'package:universe_ui/movie_universe/map/status_badge.dart';
import 'package:universe_ui/movie_universe/map/travel_flight.dart';
import 'package:universe_ui/movie_universe/map/universe_game.dart';
import 'package:universe_ui/movie_universe/map/universe_palette.dart';

/// A similar movie in orbit around the star. Its poster is the small one
/// (w92) from afar and the medium one (w185) up close.
class PlanetBody extends PositionComponent with HasGameReference<UniverseGame> {
  static const _selectedScale = 1.25;

  /// Seconds a planet takes to come out to its orbit when its system
  /// arrives.
  static const _comingOutDuration = 0.7;

  /// On-screen radius, in logical pixels, past which w92 looks blurry.
  static const _largePosterRadius = 40.0;

  final Movie movie;
  final OrbitSlot slot;
  final bool animate;
  bool selected = false;

  /// The viewer's state of the movie, drawn as a badge.
  WatchStatus? status;

  /// Left out by the filter: faded, and taps go through it.
  bool dimmed = false;
  double _angle;

  /// From 0, still inside the star, to 1, on its orbit.
  double _out = 1;
  double _outDelay = 0;
  bool _waitingToComeOut = false;
  final PosterDisc _disc;
  final PosterDetail _poster;
  final Paint _ring;
  final Paint _selectedRing;
  final Paint _selectedHalo;
  final Paint _fade;
  final StatusBadge _badge;

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
       _fade = Paint()..color = palette.fade,
       _badge = StatusBadge(palette: palette),
       status = movie.me?.status,
       super(anchor: Anchor.center) {
    _moveToAngle();
  }

  /// The radius on screen, bigger while selected.
  double get visibleRadius =>
      slot.planetRadius * (selected ? _selectedScale : 1) * _size;

  /// On its orbit, or on its way there: a planet still inside its arriving
  /// star cannot be tapped.
  bool get isOut => _out > 0;

  /// Keeps the planet inside the star until [comeOut].
  void hide() {
    _out = 0;
    _waitingToComeOut = true;
    _moveToAngle();
  }

  /// Sends the planet out to its orbit after [delay] seconds, overshooting
  /// it a little before it settles; [instantly] puts it there.
  void comeOut({double delay = 0, bool instantly = false}) {
    _waitingToComeOut = false;
    _outDelay = delay;
    _out = instantly ? 1 : math.max(_out, 0.0001);
    _moveToAngle();
  }

  /// The planet grows to full size in the first part of the way out.
  double get _size => (_out * 1.8).clamp(0.0, 1.0);

  @override
  void update(double dt) {
    _poster.update(
      screenRadius: visibleRadius * game.zoom,
      cache: game.posters,
    );
    final comingOut = !_waitingToComeOut && _out < 1;
    if (comingOut) {
      if (_outDelay > 0) {
        _outDelay -= dt;
      } else {
        _out = math.min(1.0, _out + dt / _comingOutDuration);
      }
    }
    // The selected planet holds still, so its card points at it.
    if (animate && !selected) {
      _angle = (_angle + slot.angularSpeed * dt) % (2 * math.pi);
    }
    if (comingOut || (animate && !selected)) _moveToAngle();
  }

  void _moveToAngle() {
    final distance = _out >= 1
        ? slot.radius
        : slot.radius * TravelFlight.easeOutBack(_out);
    position.setValues(
      distance * math.cos(_angle),
      distance * math.sin(_angle),
    );
  }

  @override
  void render(Canvas canvas) {
    if (_out <= 0) return;
    final size = _size;
    if (size < 1) {
      // Scaled rather than drawn smaller, so the poster shader is kept.
      canvas
        ..save()
        ..scale(size);
      _paintBody(canvas, slot.planetRadius * (selected ? _selectedScale : 1));
      canvas.restore();
      return;
    }
    _paintBody(canvas, visibleRadius);
  }

  void _paintBody(Canvas canvas, double radius) {
    if (selected) canvas.drawCircle(Offset.zero, radius + 8, _selectedHalo);
    _disc.paint(canvas, radius);
    canvas.drawCircle(Offset.zero, radius, selected ? _selectedRing : _ring);
    // A faded planet drops its badge too: half of it would stick out of
    // the fade.
    if (dimmed) {
      canvas.drawCircle(Offset.zero, radius + 2, _fade);
    } else if (status case final status?) {
      _badge.paint(canvas, radius, status, zoom: game.zoom);
    }
  }

  @override
  void onRemove() {
    _poster.dispose();
    super.onRemove();
  }
}
