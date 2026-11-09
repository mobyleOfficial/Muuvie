import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';

/// Loads a poster as a raw [ui.Image] for the canvas, through the same disk
/// cache the rest of the app uses for posters, but not through Flutter's
/// in-memory image cache.
abstract final class PosterImageLoader {
  /// The caller owns the image and must dispose it. Null when it fails.
  static Future<ui.Image?> load(String url) {
    final completer = Completer<ui.Image?>();
    final provider = CachedNetworkImageProvider(url);
    final stream = provider.resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (imageInfo, _) {
        if (!completer.isCompleted) completer.complete(imageInfo.image.clone());
        imageInfo.dispose();
        stream.removeListener(listener);
        // The map keeps its own bounded cache (PosterCache): leaving the
        // decoded poster in Flutter's image cache too would hold up to
        // 100 MB of posters the map already let go.
        PaintingBinding.instance.imageCache.evict(provider);
      },
      onError: (_, _) {
        if (!completer.isCompleted) completer.complete(null);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }
}
