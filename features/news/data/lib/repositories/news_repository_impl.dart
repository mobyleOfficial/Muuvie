import 'package:core/core.dart';
import 'package:news_domain/domain.dart';

import 'package:news_data/datasources/local/news_read_local_data_source.dart';
import 'package:news_data/datasources/remote/news_remote_data_source.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource _dataSource;
  final NewsReadLocalDataSource? _readDataSource;

  NewsRepositoryImpl(this._dataSource, [this._readDataSource]);

  @override
  Future<Result<ArticleListing>> getArticles({
    required int page,
    String? source,
  }) async {
    final result = await _dataSource.getArticles(page: page, source: source);

    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<Article>> getArticleDetail({required int articleId}) async {
    final result = await _dataSource.getArticleDetail(articleId: articleId);

    return switch (result) {
      Success(:final data) => Success(data.toDomain()),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<List<String>>> getSources() => _dataSource.getSources();

  @override
  Result<Set<int>> readArticleIds() =>
      _readDataSource?.readIds() ?? const Success({});

  @override
  Result<void> markArticleRead(int articleId) =>
      _readDataSource?.markRead(articleId) ?? const Success(null);
}
