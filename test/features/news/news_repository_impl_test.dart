import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news/news.dart';

import '../../helpers/fake_http_client.dart';

class _LocalClient implements LocalClient {
  @override
  Result<T> execute<T>(T Function() action) => Success(action());

  @override
  Stream<T> watch<T>(Stream<T> Function() action) => action();
}

const _articleJson = {
  'id': 3,
  'title': 'Fernanda Torres brilha',
  'summary': 'Resumo',
  'content': 'Texto',
  'imageUrl': null,
  'sourceUrl': 'https://g1/3',
  'source': 'G1 Cinema',
  'publishedAt': '2026-10-03T10:00:00Z',
  'movies': [
    {
      'movieId': 10,
      'tmdbId': 100,
      'title': 'Ainda Estou Aqui',
      'posterPath': '/a.jpg',
      'year': 2024,
      'me': {'inQueroVer': true, 'watched': false},
    },
  ],
};

void main() {
  late FakeHttpClient http;
  late Directory temp;
  late NewsRepositoryImpl repository;

  setUp(() {
    http = FakeHttpClient();
    temp = Directory.systemTemp.createTempSync('news_test');
    repository = NewsRepositoryImpl(
      NewsRemoteDataSourceImpl(http),
      NewsReadLocalDataSource(_LocalClient(), File('${temp.path}/read.json')),
    );
  });

  tearDown(() => temp.deleteSync(recursive: true));

  test('the list reads the v1 page and filters by source', () async {
    http.response = const Success({
      'results': [_articleJson],
      'page': 2,
      'totalPages': 3,
      'totalResults': 41,
      'hasNext': true,
    });

    final result = await GetArticles(repository)(
      const GetArticlesParams(page: 2, source: 'G1 Cinema'),
    );

    final listing = (result as Success<ArticleListing>).data;
    expect(http.calls.single.path, '/api/v1/articles');
    expect(http.calls.single.query, {
      'page': 2,
      'limit': 20,
      'source': 'G1 Cinema',
    });
    expect(listing.totalPages, 3);
    expect(listing.articles.single.movies.single.title, 'Ainda Estou Aqui');
  });

  test('without a source the filter is not sent', () async {
    http.response = const Success({
      'results': [],
      'page': 1,
      'totalPages': 0,
      'totalResults': 0,
      'hasNext': false,
    });

    await GetArticles(repository)();

    expect(http.calls.single.query, {'page': 1, 'limit': 20});
  });

  test('the detail carries the Quero ver state of each quoted movie', () async {
    http.response = const Success(_articleJson);

    final result = await GetArticleDetail(repository)(3);

    final movie = (result as Success<Article>).data.movies.single;
    expect(http.calls.single.path, '/api/v1/articles/3');
    expect(movie.movieId, 10);
    expect(movie.inQueroVer, true);
    expect(movie.watched, false);
  });

  test('read articles survive a new repository on the same file', () {
    MarkArticleRead(repository)(3);
    MarkArticleRead(repository)(5);
    MarkArticleRead(repository)(3);

    final reopened = NewsRepositoryImpl(
      NewsRemoteDataSourceImpl(http),
      NewsReadLocalDataSource(_LocalClient(), File('${temp.path}/read.json')),
    );

    expect(GetReadArticles(reopened)(), {3, 5});
  });
}
