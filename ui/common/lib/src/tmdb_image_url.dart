class TmdbImageUrl {
  TmdbImageUrl._();

  static const _base = 'https://image.tmdb.org/t/p';

  static const posterSmall = '$_base/w92';
  static const posterMedium = '$_base/w185';
  static const posterLarge = '$_base/w342';
  static const backdrop = '$_base/w780';

  static String buildPosterSmall(String path) => _build(posterSmall, path);
  static String buildPosterMedium(String path) => _build(posterMedium, path);
  static String buildPosterLarge(String path) => _build(posterLarge, path);
  static String buildBackdrop(String path) => _build(backdrop, path);

  static String _build(String base, String path) =>
      path.startsWith('http') ? path : '$base$path';
}
