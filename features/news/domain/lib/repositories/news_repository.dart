import 'package:core/core.dart';
import 'package:news_domain/models/article.dart';
import 'package:news_domain/models/article_listing.dart';

abstract interface class NewsRepository {
  /// Newest first; [source] limits to one outlet.
  Future<Result<ArticleListing>> getArticles({
    required int page,
    String? source,
  });
  Future<Result<Article>> getArticleDetail({required int articleId});
  Future<Result<List<String>>> getSources();

  /// Articles opened on this device (the "lido" mark of the list).
  Result<Set<int>> readArticleIds();
  Result<void> markArticleRead(int articleId);
}
