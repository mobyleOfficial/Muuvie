import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:universe_ui/movie_universe/streaming/chunk_grid.dart';
import 'package:universe_ui/movie_universe/streaming/chunk_key.dart';

void main() {
  test('a point belongs to the chunk it falls in, negatives included', () {
    expect(ChunkGrid.chunkOf(Offset.zero), const ChunkKey(0, 0));
    expect(ChunkGrid.chunkOf(const Offset(1599, 1600)), const ChunkKey(0, 1));
    expect(ChunkGrid.chunkOf(const Offset(-1, -1601)), const ChunkKey(-1, -2));
  });

  test('a rect is covered by every chunk it touches', () {
    final keys = ChunkGrid.covering(
      const Rect.fromLTRB(-10, -10, 1700, 10),
    ).toSet();

    expect(keys, {
      const ChunkKey(-1, -1),
      const ChunkKey(0, -1),
      const ChunkKey(1, -1),
      const ChunkKey(-1, 0),
      const ChunkKey(0, 0),
      const ChunkKey(1, 0),
    });
  });

  test('seeds are stable and differ between neighbours and origins', () {
    final seed = ChunkGrid.seedOf(42, const ChunkKey(3, -2));

    expect(ChunkGrid.seedOf(42, const ChunkKey(3, -2)), seed);
    expect(ChunkGrid.seedOf(42, const ChunkKey(4, -2)), isNot(seed));
    expect(ChunkGrid.seedOf(43, const ChunkKey(3, -2)), isNot(seed));
    expect(ChunkGrid.seedOf(42, const ChunkKey(3, -2), salt: 1), isNot(seed));
    expect(seed, greaterThanOrEqualTo(0));
  });
}
