/// A GIF from the server-side search. [url] is kept with the log so it renders later.
class Gif {
  final String id;
  final String url;
  final String? previewUrl;

  const Gif({required this.id, required this.url, this.previewUrl});

  @override
  bool operator ==(Object other) => other is Gif && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// One page of the GIF search. [nextCursor] is null on the last page.
class GifPage {
  final List<Gif> gifs;
  final String? nextCursor;

  const GifPage({required this.gifs, this.nextCursor});
}
