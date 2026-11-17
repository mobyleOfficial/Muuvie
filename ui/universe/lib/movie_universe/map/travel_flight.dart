import 'dart:math' as math;

import 'package:flame/components.dart';

/// One camera flight between two points of the map, the way a jump between
/// systems feels: it speeds up, pulls back to show where it is going and
/// settles on the arrival. Long trips take longer, within bounds, so a
/// short hop does not drag and a long one does not blink.
class TravelFlight {
  static const _shortest = 1.1;
  static const _longest = 2.2;

  /// How far, in screen widths, a flight must go to take [_longest].
  static const _longTrip = 4.0;

  /// The most the camera pulls back at mid flight: the zoom drops to this
  /// share of the smaller of the two ends.
  static const _deepestPullBack = 0.25;

  final Vector2 from;
  final Vector2 to;
  final double fromZoom;
  final double toZoom;

  /// In seconds.
  final double duration;
  final double _pullBack;
  double _elapsed = 0;

  TravelFlight._({
    required this.from,
    required this.to,
    required this.fromZoom,
    required this.toZoom,
    required this.duration,
    required double pullBack,
  }) : _pullBack = pullBack;

  /// [screenWidth] is in logical pixels; the trip is measured at the zoom
  /// the camera leaves with.
  factory TravelFlight({
    required Vector2 from,
    required Vector2 to,
    required double fromZoom,
    required double toZoom,
    required double screenWidth,
  }) {
    final screens = screenWidth <= 0
        ? 0.0
        : from.distanceTo(to) * fromZoom / screenWidth;
    final reach = (screens / _longTrip).clamp(0.0, 1.0);
    return TravelFlight._(
      from: from.clone(),
      to: to.clone(),
      fromZoom: fromZoom,
      toZoom: toZoom,
      duration: _shortest + (_longest - _shortest) * reach,
      // A hop within the screen barely pulls back.
      pullBack: _deepestPullBack * reach,
    );
  }

  /// From 0 at take-off to 1 on arrival.
  double get progress => (_elapsed / duration).clamp(0.0, 1.0);

  bool get isOver => _elapsed >= duration;

  /// How fast the flight goes now, from 0 at both ends to 1 at mid flight:
  /// drives the star streaks.
  double get rush => math.sin(math.pi * progress);

  void advance(double dt) => _elapsed += dt;

  Vector2 get position {
    final eased = easeInOutCubic(progress);
    return from + (to - from) * eased;
  }

  double get zoom {
    final eased = easeInOutCubic(progress);
    final straight = fromZoom + (toZoom - fromZoom) * eased;
    // Zoom is scale: the pull-back works on its logarithm, so it looks the
    // same at any level.
    final lowest = math.min(fromZoom, toZoom) * (1 - _pullBack);
    final dip = math.sin(math.pi * progress);
    return math.exp(
      math.log(straight) + (math.log(lowest) - math.log(straight)) * dip * dip,
    );
  }

  static double easeInOutCubic(double value) => value < 0.5
      ? 4 * value * value * value
      : 1 - math.pow(-2 * value + 2, 3) / 2;

  static double easeOutBack(double value) {
    const overshoot = 1.70158;
    const lift = overshoot + 1;
    final shifted = value - 1;
    return 1 +
        lift * shifted * shifted * shifted +
        overshoot * shifted * shifted;
  }
}
