import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:universe_ui/movie_universe/map/universe_game.dart';

/// The background stars, drawn in screen space behind the world. Three
/// layers move slower than the camera (parallax), so the planets feel in
/// front of a deep sky. Positions come from a seed, so the same movie always
/// shows the same sky.
class StarField extends Component with HasGameReference<UniverseGame> {
  static const _tileSize = 1024.0;

  /// How much of the camera movement each layer follows.
  static const _layerDepths = [0.08, 0.2, 0.45];
  static const _layerCounts = [140, 90, 45];
  static const _layerSizes = [1.0, 1.6, 2.4];

  final int seed;
  late final List<Float32List> _layers;
  late final List<Paint> _paints;

  StarField({required this.seed});

  @override
  Future<void> onLoad() async {
    final random = math.Random(seed);
    _layers = [
      for (final count in _layerCounts)
        Float32List.fromList([
          for (var i = 0; i < count * 2; i++) random.nextDouble() * _tileSize,
        ]),
    ];
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
    for (var layer = 0; layer < _layers.length; layer++) {
      final shift = viewfinder.position * _layerDepths[layer] * viewfinder.zoom;
      final offsetX = -(shift.x % _tileSize);
      final offsetY = -(shift.y % _tileSize);
      // The tile repeats to cover the viewport whatever its size.
      for (var x = offsetX - _tileSize; x < viewport.x; x += _tileSize) {
        for (var y = offsetY - _tileSize; y < viewport.y; y += _tileSize) {
          canvas
            ..save()
            ..translate(x, y)
            ..drawRawPoints(PointMode.points, _layers[layer], _paints[layer])
            ..restore();
        }
      }
    }
  }
}
