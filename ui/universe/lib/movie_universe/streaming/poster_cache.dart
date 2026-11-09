import 'dart:collection';
import 'dart:ui' as ui;

/// Loads one image for a URL; null when it fails.
typedef PosterFetch = Future<ui.Image?> Function(String url);

/// The poster images of the map, decoded once and shared. At most
/// [capacity] stay in memory, the least recently asked for leaving first.
///
/// [acquire] hands out a clone: the caller disposes it when done, and the
/// pixels are freed once the cache and every clone let go.
class PosterCache {
  final int capacity;
  final PosterFetch _fetch;
  final LinkedHashMap<String, ui.Image> _images = LinkedHashMap();
  final Map<String, Future<void>> _loading = {};
  bool _disposed = false;

  PosterCache({required PosterFetch fetch, this.capacity = 80})
    : _fetch = fetch;

  int get length => _images.length;

  bool contains(String url) => _images.containsKey(url);

  Future<ui.Image?> acquire(String url) async {
    final cached = _images.remove(url);
    if (cached != null) {
      _images[url] = cached;
      return cached.clone();
    }
    await _loading.putIfAbsent(url, () => _load(url));
    // Read again rather than use what the load produced: other loads may
    // have pushed it out meanwhile, and a disposed image cannot be cloned.
    return _images[url]?.clone();
  }

  Future<void> _load(String url) async {
    final image = await _fetch(url);
    _loading.remove(url);
    if (image == null) return;
    if (_disposed) {
      image.dispose();
      return;
    }
    _images[url] = image;
    while (_images.length > capacity) {
      final oldest = _images.keys.first;
      _images.remove(oldest)!.dispose();
    }
  }

  void dispose() {
    _disposed = true;
    for (final image in _images.values) {
      image.dispose();
    }
    _images.clear();
  }
}
