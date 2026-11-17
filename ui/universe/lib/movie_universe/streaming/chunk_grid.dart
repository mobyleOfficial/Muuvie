import 'dart:ui';

import 'package:universe_ui/movie_universe/streaming/chunk_key.dart';

/// The universe cut into squares of [size] world units. Decoration is
/// generated per chunk from [seedOf], so a place looks the same every time
/// the camera comes back to it.
abstract final class ChunkGrid {
  static const size = 1600.0;

  static ChunkKey chunkOf(Offset point) =>
      ChunkKey((point.dx / size).floor(), (point.dy / size).floor());

  /// Every chunk [rect] touches.
  static Iterable<ChunkKey> covering(Rect rect) sync* {
    final first = chunkOf(rect.topLeft);
    final last = chunkOf(rect.bottomRight);
    for (var x = first.x; x <= last.x; x++) {
      for (var y = first.y; y <= last.y; y++) {
        yield ChunkKey(x, y);
      }
    }
  }

  static Rect boundsOf(ChunkKey key) =>
      Rect.fromLTWH(key.x * size, key.y * size, size, size);

  /// A seed from the origin movie and the chunk: `hash(movieId, x, y)`,
  /// mixed so that neighbouring chunks get unrelated seeds. Stable across
  /// runs and platforms, unlike [Object.hash].
  static int seedOf(int originId, ChunkKey key, {int salt = 0}) {
    var hash = 0x811c9dc5;
    for (final value in [originId, key.x, key.y, salt]) {
      hash = ((hash ^ (value & 0xffffffff)) * 0x01000193) & 0xffffffff;
      hash ^= hash >> 15;
    }
    return hash & 0x7fffffff;
  }
}
