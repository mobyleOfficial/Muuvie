import 'dart:collection';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:universe_ui/movie_universe/map/nebula_cloud.dart';
import 'package:universe_ui/movie_universe/map/universe_game.dart';
import 'package:universe_ui/movie_universe/streaming/chunk_grid.dart';
import 'package:universe_ui/movie_universe/streaming/chunk_key.dart';

/// The clouds of the chunks the camera sees. Each chunk's clouds come from
/// `hash(originId, x, y)`; the clouds of the last [_cachedChunks] chunks
/// stay ready, older ones are generated again when the camera returns.
class NebulaLayer extends Component with HasGameReference<UniverseGame> {
  static const _cachedChunks = 48;

  final int originId;
  final List<Color> colors;
  final LinkedHashMap<ChunkKey, List<NebulaCloud>> _clouds = LinkedHashMap();

  NebulaLayer({required this.originId, required this.colors})
    : super(priority: -10);

  @override
  void render(Canvas canvas) {
    final view = game.camera.visibleWorldRect;
    for (final key in ChunkGrid.covering(view)) {
      for (final cloud in _cloudsOf(key)) {
        if (!view.overlaps(
          Rect.fromCircle(center: cloud.center, radius: cloud.radius),
        )) {
          continue;
        }
        canvas.drawCircle(cloud.center, cloud.radius, cloud.paint);
      }
    }
  }

  List<NebulaCloud> _cloudsOf(ChunkKey key) {
    final cached = _clouds.remove(key);
    if (cached != null) return _clouds[key] = cached;
    final clouds = NebulaCloud.generate(
      seed: ChunkGrid.seedOf(originId, key),
      bounds: ChunkGrid.boundsOf(key),
      colors: colors,
    );
    _clouds[key] = clouds;
    while (_clouds.length > _cachedChunks) {
      _clouds.remove(_clouds.keys.first);
    }
    return clouds;
  }
}
