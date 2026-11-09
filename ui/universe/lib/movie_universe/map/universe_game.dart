import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/graph/universe_graph.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';
import 'package:universe_ui/movie_universe/map/route_lines.dart';
import 'package:universe_ui/movie_universe/map/star_field.dart';
import 'package:universe_ui/movie_universe/map/system_component.dart';
import 'package:universe_ui/movie_universe/map/universe_palette.dart';

/// What a tap hit on the map.
sealed class UniverseHit {
  const UniverseHit();
}

final class PlanetHit extends UniverseHit {
  final Movie movie;

  const PlanetHit(this.movie);
}

/// The star of a system: tapping it focuses that system.
final class StarHit extends UniverseHit {
  final int starId;

  const StarHit(this.starId);
}

/// The star map. It only draws and answers hit tests: gestures come from the
/// Flutter widget around it, and the universe graph and selection live in
/// the cubit. [syncGraph] brings new systems in as the user travels.
class UniverseGame extends FlameGame {
  static const minZoom = 0.12;
  static const maxZoom = 3.0;

  /// A tap counts within this many logical pixels of a planet, so the touch
  /// target never gets below 48x48 however far the user zooms out.
  static const _minimumTouchRadius = 24.0;
  static const _margin = 16.0;
  static const _focusSpeed = 4.0;

  final UniversePalette palette;
  final bool animate;
  UniverseGraph _graph;
  int _focusedStarId;
  final Map<int, SystemComponent> _systems = {};
  late final RouteLines _routes;
  Vector2? _focusPosition;
  double? _focusZoom;

  UniverseGame({
    required UniverseGraph graph,
    required int focusedStarId,
    required this.palette,
    required this.animate,
  }) : _graph = graph,
       _focusedStarId = focusedStarId;

  @override
  Color backgroundColor() => palette.space;

  double get zoom => camera.viewfinder.zoom;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;
    camera.backdrop.add(StarField(seed: _graph.originId));
    _routes = RouteLines(color: palette.route);
    world.add(_routes);
    _addSystemsOf(_graph);
    focusSystem(_focusedStarId, animated: false);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) focusSystem(_focusedStarId, animated: false);
  }

  /// Adds the systems new in [graph] and drops the planets that left their
  /// orbit. Systems already on the map are kept as they are.
  /// Before the game loads, it only keeps [graph] for [onLoad].
  void syncGraph(UniverseGraph graph) {
    _graph = graph;
    if (isLoaded) _addSystemsOf(graph);
  }

  void _addSystemsOf(UniverseGraph graph) {
    for (final system in graph.systems) {
      final existing = _systems[system.star.id];
      if (existing != null) {
        existing.keepOnly(system);
        continue;
      }
      final component = SystemComponent(
        system: system,
        palette: palette,
        animate: animate,
      );
      _systems[system.star.id] = component;
      world.add(component);
    }
    _routes.showRoutesOf(graph);
  }

  /// Centers the camera on a system and zooms so it fits the screen. The
  /// camera glides there unless [animated] is false or motion is reduced.
  void focusSystem(int starId, {bool animated = true}) {
    final system = _graph.systemOf(starId);
    if (system == null) return;
    _focusedStarId = starId;
    final shortestSide = math.min(size.x, size.y);
    if (shortestSide <= 0) return;
    final targetZoom = ((shortestSide / 2 - _margin) / system.extent).clamp(
      minZoom,
      maxZoom,
    );
    final targetPosition = Vector2(system.center.dx, system.center.dy);
    if (animated && animate) {
      _focusPosition = targetPosition;
      _focusZoom = targetZoom;
    } else {
      camera.viewfinder
        ..zoom = targetZoom
        ..position = targetPosition;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final target = _focusPosition;
    final targetZoom = _focusZoom;
    if (target == null || targetZoom == null) return;
    final viewfinder = camera.viewfinder;
    final step = math.min(1.0, dt * _focusSpeed);
    viewfinder
      ..position = viewfinder.position + (target - viewfinder.position) * step
      ..zoom = viewfinder.zoom + (targetZoom - viewfinder.zoom) * step;
    if (viewfinder.position.distanceTo(target) < 1 &&
        (viewfinder.zoom - targetZoom).abs() < 0.001) {
      _focusPosition = null;
      _focusZoom = null;
    }
  }

  /// Pans by [screenDelta] logical pixels and zooms to [zoom]. A gesture
  /// stops any glide towards a system.
  void moveCamera({required Offset screenDelta, required double zoom}) {
    _focusPosition = null;
    _focusZoom = null;
    final viewfinder = camera.viewfinder;
    viewfinder.zoom = zoom.clamp(minZoom, maxZoom);
    // The camera cannot wander past the explored universe. The getter
    // returns a copy, so the clamped value is assigned back.
    final bounds = _graph.bounds;
    final moved =
        viewfinder.position -
        Vector2(screenDelta.dx, screenDelta.dy) / viewfinder.zoom;
    viewfinder.position = Vector2(
      moved.x.clamp(bounds.left, bounds.right),
      moved.y.clamp(bounds.top, bounds.bottom),
    );
  }

  /// The planet or star under [screenPoint], the closest when several are.
  UniverseHit? hitAt(Offset screenPoint) {
    final worldPoint = camera.globalToLocal(
      Vector2(screenPoint.dx, screenPoint.dy),
    );
    final minimumRadius = _minimumTouchRadius / zoom;
    UniverseHit? closest;
    var closestDistance = double.infinity;
    void consider(UniverseHit hit, Vector2 center, double radius) {
      final distance = center.distanceTo(worldPoint);
      if (distance <= math.max(radius, minimumRadius) &&
          distance < closestDistance) {
        closest = hit;
        closestDistance = distance;
      }
    }

    for (final system in _systems.values) {
      consider(
        StarHit(system.star.id),
        system.position,
        OrbitLayout.starRadius,
      );
      for (final body in system.planets) {
        consider(
          PlanetHit(body.movie),
          body.absolutePosition,
          body.visibleRadius,
        );
      }
    }
    return closest;
  }

  /// Highlights the planet of [movieId]; null clears the highlight.
  void showSelected(int? movieId) {
    for (final system in _systems.values) {
      for (final body in system.planets) {
        body.selected = body.movie.id == movieId;
      }
    }
  }
}
