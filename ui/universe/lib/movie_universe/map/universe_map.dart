import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:movies/movies.dart';
import 'package:universe_ui/movie_universe/graph/universe_graph.dart';
import 'package:universe_ui/movie_universe/map/universe_game.dart';
import 'package:universe_ui/movie_universe/map/universe_palette.dart';

/// Hosts the [UniverseGame] and turns gestures into camera moves and taps:
/// drag to pan, pinch to zoom, tap a planet to select it, tap a star to fly
/// to its system.
class UniverseMap extends StatefulWidget {
  final UniverseGraph graph;
  final int currentStarId;
  final Movie? selected;
  final ValueChanged<Movie?> onSelect;
  final ValueChanged<int> onFocusSystem;

  const UniverseMap({
    super.key,
    required this.graph,
    required this.currentStarId,
    required this.selected,
    required this.onSelect,
    required this.onFocusSystem,
  });

  @override
  State<UniverseMap> createState() => _UniverseMapState();
}

class _UniverseMapState extends State<UniverseMap> {
  UniverseGame? _game;
  double _zoomAtGestureStart = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _game ??= UniverseGame(
      graph: widget.graph,
      focusedStarId: widget.currentStarId,
      palette: UniversePalette(
        highlight: Theme.of(context).colorScheme.primaryContainer,
      ),
      // Reduced motion: the planets stay put, the star does not pulse and
      // the camera jumps between systems instead of gliding.
      animate: !MediaQuery.disableAnimationsOf(context),
    );
  }

  @override
  void didUpdateWidget(UniverseMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final game = _game!;
    if (!identical(oldWidget.graph, widget.graph)) {
      game.syncGraph(widget.graph);
    }
    if (oldWidget.currentStarId != widget.currentStarId) {
      game.focusSystem(widget.currentStarId);
    }
    if (oldWidget.selected?.id != widget.selected?.id) {
      game.showSelected(widget.selected?.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = _game!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: (_) => _zoomAtGestureStart = game.zoom,
      onScaleUpdate: (details) => game.moveCamera(
        screenDelta: details.focalPointDelta,
        zoom: _zoomAtGestureStart * details.scale,
      ),
      onTapUp: (details) => switch (game.hitAt(details.localPosition)) {
        PlanetHit(:final movie) => widget.onSelect(movie),
        StarHit(:final starId) => widget.onFocusSystem(starId),
        null => widget.onSelect(null),
      },
      child: GameWidget(game: game),
    );
  }
}
