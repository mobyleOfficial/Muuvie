import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';

/// Loads a poster as a raw [ui.Image] for the canvas, through the same disk
/// cache the rest of the app uses for posters.
abstract final class PosterImageLoader {
  /// The caller owns the image and must dispose it. Null when it fails.
  static Future<ui.Image?> load(String url) {
    final completer = Completer<ui.Image?>();
    final stream = CachedNetworkImageProvider(
      url,
    ).resolve(ImageConfiguration.empty);
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (imageInfo, _) {
        if (!completer.isCompleted) completer.complete(imageInfo.image.clone());
        imageInfo.dispose();
        stream.removeListener(listener);
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
