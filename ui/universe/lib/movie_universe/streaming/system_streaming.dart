import 'dart:ui';

/// Which systems the map keeps in the world. A system comes in when its
/// area gets within [loadMargin] of the screen, ahead of the camera, and
/// leaves only once it is farther than [unloadMargin]; the gap between the
/// two keeps a system at the edge from coming and going every frame.
///
/// The graph keeps every system, so a system that left loads again from
/// memory, with no call.
class SystemStreaming {
  final double loadMargin;
  final double unloadMargin;

  const SystemStreaming({this.loadMargin = 800, this.unloadMargin = 2400})
    : assert(unloadMargin > loadMargin);

  /// Given the area of every system and the [loaded] ones, what to add and
  /// what to remove for the camera seeing [view].
  ({Set<int> toLoad, Set<int> toUnload}) update({
    required Map<int, Rect> systemAreas,
    required Set<int> loaded,
    required Rect view,
    Set<int> pinned = const {},
  }) {
    final loadArea = view.inflate(loadMargin);
    final keepArea = view.inflate(unloadMargin);
    final toLoad = <int>{};
    final toUnload = <int>{};
    for (final MapEntry(key: starId, value: area) in systemAreas.entries) {
      final isLoaded = loaded.contains(starId);
      if (!isLoaded && (pinned.contains(starId) || area.overlaps(loadArea))) {
        toLoad.add(starId);
      } else if (isLoaded &&
          !pinned.contains(starId) &&
          !area.overlaps(keepArea)) {
        toUnload.add(starId);
      }
    }
    // A system no longer in the graph cannot stay on the map.
    toUnload.addAll(loaded.where((starId) => !systemAreas.containsKey(starId)));
    return (toLoad: toLoad, toUnload: toUnload);
  }
}
