import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:news_data/models/remote/remote_article.dart';
import 'package:news_data/models/remote/remote_article_listing.dart';
import 'package:news_data/datasources/remote/news_remote_data_source.dart';

/// News on the v1 API (`/api/v1/articles`): Page envelope, source filter and
/// the movies each article quotes. See the backend README, "News".
@injectable
class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  static const _base = '/api/v1';
  static const _pageSize = 20;

  final HttpClient _httpClient;

  NewsRemoteDataSourceImpl(@Named('backend') this._httpClient);

  @override
  Future<Result<RemoteArticleListing>> getArticles({
    required int page,
    String? source,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '$_base/articles',
      queryParams: {'page': page, 'limit': _pageSize, 'source': ?source},
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) => Success(
        RemoteArticleListing.fromPage(data),
      ),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<RemoteArticle>> getArticleDetail({
    required int articleId,
  }) async {
    final result = await _httpClient.get<Map<String, dynamic>>(
      '$_base/articles/$articleId',
    );

    return switch (result) {
      Success<Map<String, dynamic>>(:final data) => Success(
        RemoteArticle.fromJson(data),
      ),
      Failure<Map<String, dynamic>>(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<String>>> getSources() async {
    final result = await _httpClient.get<List<dynamic>>(
      '$_base/articles/sources',
    );

    return switch (result) {
      Success<List<dynamic>>(:final data) => Success(data.cast<String>()),
      Failure<List<dynamic>>(:final error) => Failure(error),
    };
  }
}
