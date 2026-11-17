import 'package:universe_ui/movie_universe/map/poster_disc.dart';
import 'package:universe_ui/movie_universe/streaming/poster_cache.dart';

/// Picks the poster size for how big a body is on screen: [smallUrl] from
/// afar, [largeUrl] once its radius passes [switchUpAt] logical pixels. It
/// switches back below three quarters of that, so a zoom resting on the
/// threshold does not reload the poster over and over. The poster on the
/// disc stays until the other size arrives.
class PosterDetail {
  final String? smallUrl;
  final String? largeUrl;
  final double switchUpAt;
  final PosterDisc disc;
  bool? _large;
  String? _requested;
  bool _disposed = false;

  PosterDetail({
    required this.smallUrl,
    required this.largeUrl,
    required this.switchUpAt,
    required this.disc,
  });

  bool get showsLarge => _large ?? false;

  void update({required double screenRadius, required PosterCache cache}) {
    final small = smallUrl;
    final large = largeUrl;
    if (small == null || large == null || _disposed) return;
    final wantsLarge = _large == true
        ? screenRadius > switchUpAt * 0.75
        : screenRadius > switchUpAt;
    if (wantsLarge == _large) return;
    _large = wantsLarge;
    final url = wantsLarge ? large : small;
    _requested = url;
    cache.acquire(url).then((image) {
      if (_disposed || _requested != url) {
        image?.dispose();
      } else {
        disc.image = image;
      }
    });
  }

  void dispose() {
    _disposed = true;
    disc.dispose();
  }
}
