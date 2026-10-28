import 'dart:io';

import 'package:core/core.dart';
import 'package:injectable/injectable.dart';
import 'package:news/news.dart';
import 'package:objectbox/objectbox.dart';

@module
abstract class NewsModule {
  @lazySingleton
  NewsRemoteDataSource newsDataSource(
    @Named('backend') HttpClient httpClient,
  ) => NewsRemoteDataSourceImpl(httpClient);

  // Next to the ObjectBox directory, like the feature flags.
  @lazySingleton
  NewsReadLocalDataSource newsReadLocalDataSource(
    LocalClient localClient,
    Store store,
  ) => NewsReadLocalDataSource(
    localClient,
    File('${Directory(store.directoryPath).parent.path}/read_articles.json'),
  );

  @lazySingleton
  NewsRepository newsRepository(
    NewsRemoteDataSource remoteDataSource,
    NewsReadLocalDataSource readDataSource,
  ) => NewsRepositoryImpl(remoteDataSource, readDataSource);

  @injectable
  GetArticles getArticles(NewsRepository repository) => GetArticles(repository);

  @injectable
  GetArticleDetail getArticleDetail(NewsRepository repository) =>
      GetArticleDetail(repository);

  @injectable
  GetArticleSources getArticleSources(NewsRepository repository) =>
      GetArticleSources(repository);

  @injectable
  GetReadArticles getReadArticles(NewsRepository repository) =>
      GetReadArticles(repository);

  @injectable
  MarkArticleRead markArticleRead(NewsRepository repository) =>
      MarkArticleRead(repository);
}
