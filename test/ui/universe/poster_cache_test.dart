import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:universe_ui/movie_universe/streaming/poster_cache.dart';

ui.Image _image() {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(const ui.Rect.fromLTWH(0, 0, 1, 1), ui.Paint());
  return recorder.endRecording().toImageSync(1, 1);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> fetched;
  late PosterCache cache;

  setUp(() {
    fetched = [];
    cache = PosterCache(
      capacity: 2,
      fetch: (url) async {
        fetched.add(url);
        return url.contains('broken') ? null : _image();
      },
    );
  });

  tearDown(() => cache.dispose());

  test('a poster is fetched once and handed out as clones', () async {
    final results = await Future.wait([cache.acquire('a'), cache.acquire('a')]);
    final again = await cache.acquire('a');

    expect(fetched, ['a']);
    for (final image in [...results, again]) {
      expect(image, isNotNull);
      image!.dispose();
    }
  });

  test('past the capacity the least recently asked for leaves', () async {
    (await cache.acquire('a'))!.dispose();
    (await cache.acquire('b'))!.dispose();
    (await cache.acquire('a'))!.dispose(); // a is now the most recent
    (await cache.acquire('c'))!.dispose();

    expect(cache.length, 2);
    expect(cache.contains('a'), isTrue);
    expect(cache.contains('b'), isFalse);
    expect(cache.contains('c'), isTrue);
  });

  test('a clone outlives the eviction of its poster', () async {
    final clone = await cache.acquire('a');
    (await cache.acquire('b'))!.dispose();
    (await cache.acquire('c'))!.dispose();

    expect(cache.contains('a'), isFalse);
    expect(clone!.width, 1);
    clone.dispose();
  });

  test('a poster that fails answers null and is not kept', () async {
    expect(await cache.acquire('broken'), isNull);
    expect(cache.length, 0);
  });
}
