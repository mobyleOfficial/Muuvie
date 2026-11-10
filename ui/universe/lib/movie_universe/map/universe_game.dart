import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/filter/universe_filter.dart';
import 'package:universe_ui/movie_universe/graph/universe_graph.dart';
import 'package:universe_ui/movie_universe/map/constellation_lines.dart';
import 'package:universe_ui/movie_universe/map/nebula_layer.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';
import 'package:universe_ui/movie_universe/map/poster_image_loader.dart';
import 'package:universe_ui/movie_universe/map/route_lines.dart';
import 'package:universe_ui/movie_universe/map/star_field.dart';
import 'package:universe_ui/movie_universe/map/system_component.dart';
import 'package:universe_ui/movie_universe/map/travel_flight.dart';
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
  static const _streamingInterval = 0.2;

  final UniversePalette palette;
  final bool animate;
  UniverseGraph _graph;
  int _focusedStarId;
  final Map<int, SystemComponent> _systems = {};
  final SystemStreaming _streaming = const SystemStreaming();
  final PosterCache posters = PosterCache(fetch: PosterImageLoader.load);
  late final RouteLines _routes;
  TravelFlight? _flight;
  Vector2 _flightDirection = Vector2.zero();

  /// Where the planets that just became systems were, by their movie id:
  /// each new star sets off from there when its system loads.
  final Map<int, (Vector2, double)> _departures = {};
  int? _selectedMovieId;
  UniverseFilter _filter;
  UniverseGraph? _syncedGraph;
  Map<int, Rect> _systemAreas = const {};
  double _sinceStreaming = 0;
  Vector2? _laidOutSize;

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

  /// From 0 at rest to 1 at the fastest point of a flight between systems.
  double get rush => _flight?.rush ?? 0;

  /// How far the zoom may drift, as a share, before a line mesh drawn at
  /// a fixed screen width (orbits, routes) is rebuilt. A flight changes the
  /// zoom every frame: rebuilding every system's orbits each time was most of
  /// the cost of a flight on a moto g9 plus, and lines a little thicker or
  /// thinner for a second are not seen.
  double get meshTolerance => _flight == null ? 0.02 : 0.3;

  /// The way the camera flies, as a unit vector on screen; zero at rest.
  Vector2 get flightDirection => _flightDirection;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.center;
    camera.backdrop.add(StarField(seed: _graph.originId));
    world.add(NebulaLayer(originId: _graph.originId, colors: palette.nebulae));
    _routes = RouteLines(color: palette.route);
    world.add(_routes);
    // Above the routes, under the systems added later.
    world.add(ConstellationLines(color: palette.constellation));
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
    // Flame calls this on every layout of the GameWidget, so on every state
    // the screen rebuilds with, even when nothing changed size: refocusing
    // then would cut every flight short.
    final resized = _laidOutSize != size;
    _laidOutSize = size.clone();
    super.onGameResize(size);
    if (isLoaded && resized) focusSystem(_focusedStarId, animated: false);
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
      if (animate) _noteDepartures(_syncedGraph);
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
      // The system in focus stays even while the camera flies away.
      pinned: {_focusedStarId},
    );
    for (final starId in change.toUnload) {
      _systems.remove(starId)?.removeFromParent();
    }
    for (final starId in change.toLoad) {
      final departure = _departures.remove(starId);
      final system = _graph.systemOf(starId)!;
      final component = SystemComponent(
        system: system,
        palette: palette,
        animate: animate,
        arrivingFrom: departure == null
            ? null
            : departure.$1 - Vector2(system.center.dx, system.center.dy),
        arrivingRadius: departure?.$2,
      );
      for (final body in component.planets) {
        body.selected = body.movie.id == _selectedMovieId;
      }
      component.applyFilter(_filter);
      _systems[starId] = component;
      world.add(component);
    }
  }

  /// Remembers where each planet that became a system was, so its star sets
  /// off from that spot instead of popping up at its new place.
  void _noteDepartures(UniverseGraph? previous) {
    _departures.clear();
    for (final component in _systems.values) {
      for (final body in component.planets) {
        final starId = body.movie.id;
        if (_graph.systemOf(starId) == null) continue;
        if (previous?.systemOf(starId) != null) continue;
        _departures[starId] = (
          body.absolutePosition.clone(),
          body.slot.planetRadius,
        );
      }
    }
  }

  /// Centers the camera on a system and zooms so it fits the screen. The
  /// camera flies there (see [TravelFlight]) unless [animated] is false or
  /// motion is reduced; a star that just left its orbit flies with it.
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
    // A system out of sight is not in the world yet: bring it now, so a new
    // star leaves with the camera.
    if (isMounted && !_systems.containsKey(starId)) _syncSystems();
    if (animated && animate) {
      final viewfinder = camera.viewfinder;
      final flight = TravelFlight(
        from: viewfinder.position,
        to: targetPosition,
        fromZoom: viewfinder.zoom,
        toZoom: targetZoom,
        screenWidth: size.x,
      );
      _flight = flight;
      final heading = targetPosition - viewfinder.position;
      _flightDirection = heading.length2 == 0
          ? Vector2.zero()
          : heading.normalized();
      _systems[starId]?.arriveIn(flight.duration);
    } else {
      _endFlight();
      _systems[starId]?.arriveIn(0);
      camera.viewfinder
        ..zoom = targetZoom
        ..position = targetPosition;
    }
    // A departure not used by now would play later, out of context.
    _departures.clear();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _sinceStreaming += dt;
    if (_sinceStreaming >= _streamingInterval) _syncSystems();
    final flight = _flight;
    if (flight == null) return;
    flight.advance(dt);
    camera.viewfinder
      ..position = flight.position
      ..zoom = flight.zoom;
    if (flight.isOver) _endFlight();
  }

  void _endFlight() {
    _flight = null;
    _flightDirection = Vector2.zero();
  }

  /// Pans by [screenDelta] logical pixels and zooms to [zoom]. A gesture
  /// stops any flight towards a system.
  void moveCamera({required Offset screenDelta, required double zoom}) {
    _endFlight();
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
        if (body.dimmed || !body.isOut) continue;
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

  /// Where the planets of the constellation shown are now, system by system
  /// in the order they were opened and planets in orbit order; empty while
  /// no constellation is shown.
  List<Vector2> constellationPoints() {
    if (_filter.constellation == null) return const [];
    return [
      for (final system in _graph.systems)
        if (_systems[system.star.id] case final component?)
          for (final body in component.planets)
            if (!body.dimmed) body.absolutePosition,
    ];
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
