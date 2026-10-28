import 'package:core/core.dart';
import 'package:news_domain/models/article_listing.dart';
import 'package:news_domain/repositories/news_repository.dart';

class GetArticlesParams {
  final int page;

  /// One outlet, or null for every source.
  final String? source;

  const GetArticlesParams({this.page = 1, this.source});
}

class GetArticles extends UseCase<GetArticlesParams, Result<ArticleListing>> {
  final NewsRepository _repository;

  GetArticles(this._repository);

  @override
  Future<Result<ArticleListing>> call([GetArticlesParams? params]) async {
    final value = params ?? const GetArticlesParams();
    return _repository.getArticles(page: value.page, source: value.source);
  }
}

/// The outlets of the source filter (F5.8).
class GetArticleSources extends UseCase<void, Result<List<String>>> {
  final NewsRepository _repository;

  GetArticleSources(this._repository);

  @override
  Future<Result<List<String>>> call([void params]) => _repository.getSources();
}

/// Ids of the articles already opened on this device.
class GetReadArticles {
  final NewsRepository _repository;

  GetReadArticles(this._repository);

  Set<int> call() => switch (_repository.readArticleIds()) {
    Success(:final data) => data,
    Failure() => const {},
  };
}

class MarkArticleRead {
  final NewsRepository _repository;

  MarkArticleRead(this._repository);

  void call(int articleId) => _repository.markArticleRead(articleId);
}
