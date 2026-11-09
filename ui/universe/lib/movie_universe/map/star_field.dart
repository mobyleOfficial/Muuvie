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
class StarField extends Component with HasGameReference<UniverseGame> {
  static const _tileSize = 512.0;
  static const _cachedTiles = 96;

  /// How much of the camera movement each layer follows.
  static const _layerDepths = [0.08, 0.2, 0.45];
  static const _layerCounts = [36, 22, 11];
  static const _layerSizes = [1.0, 1.6, 2.4];

  final int seed;
  late final List<Paint> _paints;
  final LinkedHashMap<(int, ChunkKey), Float32List> _tiles = LinkedHashMap();

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
    for (var layer = 0; layer < _layerDepths.length; layer++) {
      final shift = viewfinder.position * _layerDepths[layer] * viewfinder.zoom;
      final firstX = (shift.x / _tileSize).floor();
      final firstY = (shift.y / _tileSize).floor();
      final lastX = ((shift.x + viewport.x) / _tileSize).floor();
      final lastY = ((shift.y + viewport.y) / _tileSize).floor();
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
