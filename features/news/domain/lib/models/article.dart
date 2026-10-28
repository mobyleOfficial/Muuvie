class Article {
  final int id;
  final String title;
  final String summary;
  final String content;
  final String? imageUrl;
  final String sourceUrl;
  final String source;
  final String publishedAt;

  /// Movies the article quotes (F5.8), most confident first.
  final List<ArticleMovie> movies;

  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    this.imageUrl,
    required this.sourceUrl,
    required this.source,
    required this.publishedAt,
    this.movies = const [],
  });

  Article copyWith({List<ArticleMovie>? movies}) => Article(
    id: id,
    title: title,
    summary: summary,
    content: content,
    imageUrl: imageUrl,
    sourceUrl: sourceUrl,
    source: source,
    publishedAt: publishedAt,
    movies: movies ?? this.movies,
  );
}

/// A movie quoted by an article. [inQueroVer] and [watched] are only known on
/// the article detail, for a logged-in user.
class ArticleMovie {
  /// Database id (opens the movie detail and goes to the shelves).
  final int movieId;
  final int? tmdbId;
  final String title;
  final String? posterPath;
  final int? year;
  final bool inQueroVer;
  final bool watched;

  const ArticleMovie({
    required this.movieId,
    this.tmdbId,
    required this.title,
    this.posterPath,
    this.year,
    this.inQueroVer = false,
    this.watched = false,
  });

  ArticleMovie copyWith({bool? inQueroVer}) => ArticleMovie(
    movieId: movieId,
    tmdbId: tmdbId,
    title: title,
    posterPath: posterPath,
    year: year,
    inQueroVer: inQueroVer ?? this.inQueroVer,
    watched: watched,
  );
}
