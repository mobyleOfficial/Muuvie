/// One square of the chunk grid, by its column
/// [x] and row [y].
class ChunkKey {
  final int x;
  final int y;

  const ChunkKey(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is ChunkKey && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'ChunkKey($x, $y)';
}
