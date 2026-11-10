import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// A poster cropped to a disc centered on the origin, or a plain disc while
/// it loads. The poster is painted through a cached image shader rather than
/// a clip: with dozens of planets on screen, a clip per planet is what costs
/// the most on the GPU.
class PosterDisc {
  final Paint _placeholder;
  final Paint _poster = Paint()..filterQuality = FilterQuality.medium;
  ui.Image? _image;
  double _shaderRadius = -1;

  PosterDisc({required Color placeholder})
    : _placeholder = Paint()..color = placeholder;

  /// Takes ownership of [image]: it is disposed with this disc.
  set image(ui.Image? image) {
    _image?.dispose();
    _image = image;
    _shaderRadius = -1;
  }

  void paint(Canvas canvas, double radius) {
    final image = _image;
    if (image == null) {
      canvas.drawCircle(Offset.zero, radius, _placeholder);
      return;
    }
    if (radius != _shaderRadius) _buildShader(image, radius);
    canvas.drawCircle(Offset.zero, radius, _poster);
  }

  /// Maps a square from the upper middle of the 2:3 poster, where faces and
  /// titles usually are, onto the disc of [radius].
  void _buildShader(ui.Image image, double radius) {
    final side = image.width.toDouble();
    final top = ((image.height - side) * 0.3).clamp(0, double.infinity);
    final scale = 2 * radius / side;
    _poster.shader = ImageShader(
      image,
      TileMode.clamp,
      TileMode.clamp,
      Float64List.fromList([
        scale, 0, 0, 0, //
        0, scale, 0, 0, //
        0, 0, 1, 0, //
        -radius, -radius - top * scale, 0, 1,
      ]),
      filterQuality: FilterQuality.medium,
    );
    _shaderRadius = radius;
  }

  void dispose() => image = null;
}
