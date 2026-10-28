import 'package:news_domain/domain.dart';

class RemoteArticle {
  final int id;
  final String title;
  final String summary;
  final String content;
  final String? imageUrl;
  final String sourceUrl;
  final String source;
  final String publishedAt;
  final List<Map<String, dynamic>> movies;

  const RemoteArticle({
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

  factory RemoteArticle.fromJson(Map<String, dynamic> json) => RemoteArticle(
    id: (json['id'] as num).toInt(),
    title: json['title'] as String,
    summary: json['summary'] as String? ?? '',
    content: json['content'] as String? ?? '',
    imageUrl: json['imageUrl'] as String?,
    sourceUrl: json['sourceUrl'] as String,
    source: json['source'] as String,
    publishedAt: json['publishedAt'] as String,
    movies:
        (json['movies'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        const [],
  );

  Article toDomain() => Article(
    id: id,
    title: title,
    summary: summary,
    content: content,
    imageUrl: imageUrl,
    sourceUrl: sourceUrl,
    source: source,
    publishedAt: publishedAt,
    movies: movies.map(_movie).toList(),
  );

  static ArticleMovie _movie(Map<String, dynamic> json) {
    final me = json['me'] as Map<String, dynamic>?;
    return ArticleMovie(
      movieId: (json['movieId'] as num).toInt(),
      tmdbId: (json['tmdbId'] as num?)?.toInt(),
      title: json['title'] as String? ?? '',
      posterPath: json['posterPath'] as String?,
      year: (json['year'] as num?)?.toInt(),
      inQueroVer: me?['inQueroVer'] as bool? ?? false,
      watched: me?['watched'] as bool? ?? false,
    );
  }
}
