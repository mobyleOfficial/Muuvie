import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:universe_ui/movie_universe/map/orbit_layout.dart';
import 'package:universe_ui/movie_universe/map/universe_game.dart';

/// The faint circles the planets travel on, centered on the star.
///
/// They are drawn as one triangle mesh, rebuilt only when the zoom changes.
/// Measured on a moto g9 plus: stroking the circles as paths made the GPU
/// tessellate them every frame (raster went from ~7 ms to ~16 ms with 60
/// orbits), and `drawCircle` with a stroke dropped the large ones entirely.
class OrbitRings extends Component with HasGameReference<UniverseGame> {
  /// The line keeps this width on screen whatever the zoom.
  static const _screenWidth = 1.0;
  static const _segments = 128;

  final List<OrbitSlot> slots;
  final Paint _paint;
  Vertices? _mesh;
  double _meshZoom = 0;

  OrbitRings({required this.slots, required Color color})
    : _paint = Paint()..color = color;

  @override
  void render(Canvas canvas) {
    final zoom = game.zoom;
    if (_mesh == null || (zoom - _meshZoom).abs() > _meshZoom * 0.02) {
      _mesh?.dispose();
      _mesh = _buildMesh(_screenWidth / zoom / 2);
      _meshZoom = zoom;
    }
    canvas.drawVertices(_mesh!, BlendMode.srcOver, _paint);
  }

  /// Each orbit is a thin annulus of [_segments] quads, with an inner and an
  /// outer vertex per step.
  Vertices _buildMesh(double halfWidth) {
    final positions = Float32List(slots.length * _segments * 4);
    final indices = Uint16List(slots.length * _segments * 6);
    var position = 0;
    var index = 0;
    for (var ring = 0; ring < slots.length; ring++) {
      final first = ring * _segments * 2;
      final inner = slots[ring].radius - halfWidth;
      final outer = slots[ring].radius + halfWidth;
      for (var step = 0; step < _segments; step++) {
        final angle = 2 * math.pi * step / _segments;
        final cosine = math.cos(angle);
        final sine = math.sin(angle);
        positions[position++] = inner * cosine;
        positions[position++] = inner * sine;
        positions[position++] = outer * cosine;
        positions[position++] = outer * sine;
        final current = first + step * 2;
        final next = first + ((step + 1) % _segments) * 2;
        indices
          ..[index++] = current
          ..[index++] = current + 1
          ..[index++] = next
          ..[index++] = next
          ..[index++] = current + 1
          ..[index++] = next + 1;
      }
    }
    return Vertices.raw(VertexMode.triangles, positions, indices: indices);
  }

  @override
  void onRemove() {
    _mesh?.dispose();
    _mesh = null;
    super.onRemove();
  }
}
