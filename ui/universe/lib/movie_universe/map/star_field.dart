import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:universe_ui/movie_universe/map/universe_game.dart';
import 'package:universe_ui/movie_universe/streaming/chunk_grid.dart';
import 'package:universe_ui/movie_universe/streaming/chunk_key.dart';

/// The background stars, drawn in screen space behind the world. Three
/// layers move slower than the camera (parallax), so the planets feel in
/// front of a deep sky.
///
/// Each layer is cut into tiles, and each tile's stars come from
/// `hash(seed, x, y)` with the layer as salt: the sky never repeats, and the
/// same place always shows the same stars. The last [_cachedTiles] tiles
/// stay ready.
///
/// During a flight between systems the stars stretch into streaks along the
/// way the camera goes, longest at mid flight and on the nearest layer.
class StarField extends Component with HasGameReference<UniverseGame> {
  static const _tileSize = 512.0;
  static const _cachedTiles = 96;

  /// How much of the camera movement each layer follows.
  static const _layerDepths = [0.08, 0.2, 0.45];
  static const _layerCounts = [36, 22, 11];
  static const _layerSizes = [1.0, 1.6, 2.4];

  /// Streak length, in logical pixels, at the fastest point of a flight.
  static const _layerStreaks = [8.0, 22.0, 44.0];

  /// Below this rush the stars stay points.
  static const _minimumRush = 0.04;

  final int seed;
  late final List<Paint> _paints;
  final LinkedHashMap<(int, ChunkKey), Float32List> _tiles = LinkedHashMap();

  /// Reused for the streaks of a layer: two triangles per star. Grown when
  /// a layer needs more.
  Float32List _streaks = Float32List(0);

  StarField({required this.seed});

  @override
  Future<void> onLoad() async {
    _paints = [
      for (var layer = 0; layer < _layerSizes.length; layer++)
        Paint()
          ..color = Color.fromRGBO(255, 255, 255, 0.35 + layer * 0.25)
          ..strokeWidth = _layerSizes[layer]
          ..strokeCap = StrokeCap.round,
    ];
  }

  @override
  void render(Canvas canvas) {
    final viewfinder = game.camera.viewfinder;
    final viewport = game.camera.viewport.size;
    final rush = game.rush;
    final direction = game.flightDirection;
    for (var layer = 0; layer < _layerDepths.length; layer++) {
      final shift = viewfinder.position * _layerDepths[layer] * viewfinder.zoom;
      final firstX = (shift.x / _tileSize).floor();
      final firstY = (shift.y / _tileSize).floor();
      final lastX = ((shift.x + viewport.x) / _tileSize).floor();
      final lastY = ((shift.y + viewport.y) / _tileSize).floor();
      if (rush > _minimumRush && direction.length2 > 0) {
        _renderStreaks(
          canvas,
          layer: layer,
          shift: shift,
          tilesX: (firstX, lastX),
          tilesY: (firstY, lastY),
          streak: direction * (_layerStreaks[layer] * rush),
        );
        continue;
      }
      for (var tileX = firstX; tileX <= lastX; tileX++) {
        for (var tileY = firstY; tileY <= lastY; tileY++) {
          canvas
            ..save()
            ..translate(
              tileX * _tileSize - shift.x,
              tileY * _tileSize - shift.y,
            )
            ..drawRawPoints(
              PointMode.points,
              _tile(layer, ChunkKey(tileX, tileY)),
              _paints[layer],
            )
            ..restore();
        }
      }
    }
  }

  /// Each star of the layer as a thin quad to the side the camera flies to:
  /// the stars move the other way, so it trails behind them as they rush
  /// past. All of a layer goes in one triangle mesh: drawn as lines, the
  /// streaks cost a moto g9 plus about 8 ms of raster per frame.
  void _renderStreaks(
    Canvas canvas, {
    required int layer,
    required Vector2 shift,
    required (int, int) tilesX,
    required (int, int) tilesY,
    required Vector2 streak,
  }) {
    final (firstX, lastX) = tilesX;
    final (firstY, lastY) = tilesY;
    final tiles = (lastX - firstX + 1) * (lastY - firstY + 1);
    final needed = tiles * _layerCounts[layer] * 12;
    if (_streaks.length < needed) _streaks = Float32List(needed);
    final across = Vector2(-streak.y, streak.x)
      ..normalize()
      ..scale(_layerSizes[layer] / 2);
    var index = 0;
    void corner(double x, double y) {
      _streaks[index++] = x;
      _streaks[index++] = y;
    }

    for (var tileX = firstX; tileX <= lastX; tileX++) {
      for (var tileY = firstY; tileY <= lastY; tileY++) {
        final points = _tile(layer, ChunkKey(tileX, tileY));
        final offsetX = tileX * _tileSize - shift.x;
        final offsetY = tileY * _tileSize - shift.y;
        for (var point = 0; point < points.length; point += 2) {
          final x = points[point] + offsetX;
          final y = points[point + 1] + offsetY;
          final endX = x + streak.x;
          final endY = y + streak.y;
          corner(x + across.x, y + across.y);
          corner(x - across.x, y - across.y);
          corner(endX + across.x, endY + across.y);
          corner(endX + across.x, endY + across.y);
          corner(x - across.x, y - across.y);
          corner(endX - across.x, endY - across.y);
        }
      }
    }
    final mesh = Vertices.raw(
      VertexMode.triangles,
      Float32List.sublistView(_streaks, 0, index),
    );
    canvas.drawVertices(mesh, BlendMode.srcOver, _paints[layer]);
    mesh.dispose();
  }

  Float32List _tile(int layer, ChunkKey key) {
    final cacheKey = (layer, key);
    final cached = _tiles.remove(cacheKey);
    if (cached != null) return _tiles[cacheKey] = cached;
    final random = math.Random(ChunkGrid.seedOf(seed, key, salt: layer + 1));
    final points = Float32List.fromList([
      for (var index = 0; index < _layerCounts[layer] * 2; index++)
        random.nextDouble() * _tileSize,
    ]);
    _tiles[cacheKey] = points;
    while (_tiles.length > _cachedTiles) {
      _tiles.remove(_tiles.keys.first);
    }
    return points;
  }
}
