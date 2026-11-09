import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:universe_ui/movie_universe/graph/universe_graph.dart';
import 'package:universe_ui/movie_universe/map/universe_game.dart';

/// The routes between systems: a line from each system to the one it was
/// reached from. Drawn as a triangle mesh, rebuilt only when the routes or
/// the zoom change, like the orbits (see OrbitRings).
class RouteLines extends Component with HasGameReference<UniverseGame> {
  static const _screenWidth = 1.5;

  final Paint _paint;
  List<(Offset, Offset)> _routes = const [];
  Vertices? _mesh;
  double _meshZoom = 0;

  RouteLines({required Color color}) : _paint = Paint()..color = color;

  void showRoutesOf(UniverseGraph graph) {
    _routes = [
      for (final system in graph.systems)
        if (system.parentStarId case final parentId?)
          (graph.systemOf(parentId)!.center, system.center),
    ];
    _discardMesh();
  }

  @override
  void render(Canvas canvas) {
    if (_routes.isEmpty) return;
    final zoom = game.zoom;
    if (_mesh == null || (zoom - _meshZoom).abs() > _meshZoom * 0.02) {
      _discardMesh();
      _mesh = _buildMesh(_screenWidth / zoom / 2);
      _meshZoom = zoom;
    }
    canvas.drawVertices(_mesh!, BlendMode.srcOver, _paint);
  }

  Vertices _buildMesh(double halfWidth) {
    final positions = Float32List(_routes.length * 8);
    final indices = Uint16List(_routes.length * 6);
    var position = 0;
    var index = 0;
    for (var route = 0; route < _routes.length; route++) {
      final (from, to) = _routes[route];
      final along = to - from;
      final length = along.distance;
      if (length == 0) continue;
      final across = Offset(-along.dy, along.dx) / length * halfWidth;
      for (final corner in [
        from + across,
        from - across,
        to + across,
        to - across,
      ]) {
        positions[position++] = corner.dx;
        positions[position++] = corner.dy;
      }
      final first = route * 4;
      indices
        ..[index++] = first
        ..[index++] = first + 1
        ..[index++] = first + 2
        ..[index++] = first + 2
        ..[index++] = first + 1
        ..[index++] = first + 3;
    }
    return Vertices.raw(VertexMode.triangles, positions, indices: indices);
  }

  void _discardMesh() {
    _mesh?.dispose();
    _mesh = null;
  }

  @override
  void onRemove() {
    _discardMesh();
    super.onRemove();
  }
}
