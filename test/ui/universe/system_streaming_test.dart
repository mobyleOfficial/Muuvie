import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:universe_ui/movie_universe/streaming/system_streaming.dart';

void main() {
  const streaming = SystemStreaming(loadMargin: 100, unloadMargin: 300);
  const view = Rect.fromLTWH(0, 0, 400, 800);
  Rect area(double x) => Rect.fromCircle(center: Offset(x, 400), radius: 50);

  test('systems on screen or just ahead of it come in', () {
    final change = streaming.update(
      systemAreas: {1: area(200), 2: area(520), 3: area(1000)},
      loaded: const {},
      view: view,
    );

    expect(change.toLoad, {1, 2});
    expect(change.toUnload, isEmpty);
  });

  test('a system between the two margins neither comes nor goes', () {
    final notLoaded = streaming.update(
      systemAreas: {1: area(600)},
      loaded: const {},
      view: view,
    );
    final loaded = streaming.update(
      systemAreas: {1: area(600)},
      loaded: const {1},
      view: view,
    );

    expect(notLoaded.toLoad, isEmpty);
    expect(loaded.toUnload, isEmpty);
  });

  test('a system past the far margin leaves, unless it is pinned', () {
    expect(
      streaming
          .update(systemAreas: {1: area(2000)}, loaded: const {1}, view: view)
          .toUnload,
      {1},
    );
    expect(
      streaming
          .update(
            systemAreas: {1: area(2000)},
            loaded: const {1},
            view: view,
            pinned: const {1},
          )
          .toUnload,
      isEmpty,
    );
  });

  test('a pinned system comes in wherever it is', () {
    expect(
      streaming
          .update(
            systemAreas: {1: area(9000)},
            loaded: const {},
            view: view,
            pinned: const {1},
          )
          .toLoad,
      {1},
    );
  });

  test('a system gone from the graph leaves the map', () {
    expect(
      streaming
          .update(systemAreas: const {}, loaded: const {7}, view: view)
          .toUnload,
      {7},
    );
  });
}
