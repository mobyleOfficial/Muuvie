import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/filter/universe_filter.dart';
import 'package:universe_ui/movie_universe/graph/universe_graph.dart';
import 'package:universe_ui/movie_universe/map/nebula_layer.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';
import 'package:universe_ui/movie_universe/map/poster_image_loader.dart';
import 'package:universe_ui/movie_universe/map/route_lines.dart';
import 'package:universe_ui/movie_universe/map/star_field.dart';
import 'package:universe_ui/movie_universe/map/system_component.dart';
import 'package:universe_ui/movie_universe/map/universe_palette.dart';
import 'package:universe_ui/movie_universe/streaming/poster_cache.dart';
import 'package:universe_ui/movie_universe/streaming/system_streaming.dart';

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
///
/// Only the systems near the camera are in the world (see
/// [SystemStreaming]); the others live in the graph alone, and their
/// posters can leave the [posters] cache.
class UniverseGame extends FlameGame {
  static const minZoom = 0.12;
  static const maxZoom = 3.0;

  /// A tap counts within this many logical pixels of a planet, so the touch
  /// target never gets below 48x48 however far the user zooms out.
  static const _minimumTouchRadius = 24.0;
  static const _margin = 16.0;
  static const _focusSpeed = 4.0;
  static const _streamingInterval = 0.2;

  final UniversePalette palette;
  final bool animate;
  UniverseGraph _graph;
  int _focusedStarId;
  final Map<int, SystemComponent> _systems = {};
  final SystemStreaming _streaming = const SystemStreaming();
  final PosterCache posters = PosterCache(fetch: PosterImageLoader.load);
  late final RouteLines _routes;
  Vector2? _focusPosition;
  double? _focusZoom;
  int? _selectedMovieId;
  UniverseFilter _filter;
  UniverseGraph? _syncedGraph;
  Map<int, Rect> _systemAreas = const {};
  double _sinceStreaming = 0;

  UniverseGame({
    required UniverseGraph graph,
    required int focusedStarId,
    required this.palette,
    required this.animate,
    UniverseFilter filter = UniverseFilter.none,
  }) : _graph = graph,
       _focusedStarId = focusedStarId,
       _filter = filter;

  @override
  Color backgroundColor() => palette.space;

  double get zoom => camera.viewfinder.zoom;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;
    camera.backdrop.add(StarField(seed: _graph.originId));
    world.add(NebulaLayer(originId: _graph.originId, colors: palette.nebulae));
    _routes = RouteLines(color: palette.route);
    world.add(_routes);
    focusSystem(_focusedStarId, animated: false);
    // The camera is only measured once mounted: the first update streams.
    _sinceStreaming = _streamingInterval;
  }

  @override
  void onRemove() {
    posters.dispose();
    super.onRemove();
  }

  /// The systems in the world now, by star id.
  Iterable<int> get loadedStarIds => _systems.keys;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) focusSystem(_focusedStarId, animated: false);
  }

  /// Adds the systems new in [graph], drops the planets that left their
  /// orbit and shows the viewer's latest state of each movie. Systems
  /// already on the map stay where they are.
  /// Before the game loads, it only keeps [graph] for [onLoad].
  void syncGraph(UniverseGraph graph) {
    _graph = graph;
    if (isMounted) _syncSystems();
  }

  /// Brings the world in line with the graph and the camera: drops the
  /// planets that left their orbit, adds the systems that came near and
  /// removes the ones that went far.
  void _syncSystems() {
    _sinceStreaming = 0;
    // Planets, areas and routes only change with the graph; the camera alone
    // only moves systems in and out.
    final graphChanged = !identical(_graph, _syncedGraph);
    if (graphChanged) {
      _syncedGraph = _graph;
      for (final MapEntry(key: starId, value: component) in _systems.entries) {
        final system = _graph.systemOf(starId);
        if (system == null) continue;
        // A new state can change what the filter keeps (now watched, say).
        component
          ..sync(system)
          ..applyFilter(_filter);
      }
      _systemAreas = {
        for (final system in _graph.systems)
          system.star.id: Rect.fromCircle(
            center: system.center,
            radius: system.extent,
          ),
      };
      _routes.showRoutesOf(_graph);
    }
    final change = _streaming.update(
      systemAreas: _systemAreas,
      loaded: _systems.keys.toSet(),
      view: camera.visibleWorldRect,
      // The system in focus stays even while the camera glides away.
      pinned: {_focusedStarId},
    );
    for (final starId in change.toUnload) {
      _systems.remove(starId)?.removeFromParent();
    }
    for (final starId in change.toLoad) {
      final component = SystemComponent(
        system: _graph.systemOf(starId)!,
        palette: palette,
        animate: animate,
      );
      for (final body in component.planets) {
        body.selected = body.movie.id == _selectedMovieId;
      }
      component.applyFilter(_filter);
      _systems[starId] = component;
      world.add(component);
    }
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
    _sinceStreaming += dt;
    if (_sinceStreaming >= _streamingInterval) _syncSystems();
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
        if (body.dimmed) continue;
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
    _selectedMovieId = movieId;
    for (final system in _systems.values) {
      for (final body in system.planets) {
        body.selected = body.movie.id == movieId;
      }
    }
  }

  /// Fades the planets [filter] leaves out, in every system on the map and
  /// in the ones that come later.
  void showFilter(UniverseFilter filter) {
    _filter = filter;
    for (final system in _systems.values) {
      system.applyFilter(filter);
    }
  }
}
