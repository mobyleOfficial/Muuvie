import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:news/news.dart';
import 'package:news_ui/article_detail/article_detail_bloc.dart';
import 'package:news_ui/article_detail/article_detail_state.dart';
import 'package:news_ui/news_list/news_list_bloc.dart';
import 'package:news_ui/news_list/news_list_state.dart';
import 'package:shelves/shelves.dart';

const _article = Article(
  id: 3,
  title: 'Fernanda Torres brilha',
  summary: '',
  content: '',
  sourceUrl: 'https://g1/3',
  source: 'G1 Cinema',
  publishedAt: '2026-10-03',
  movies: [ArticleMovie(movieId: 10, title: 'Ainda Estou Aqui')],
);

class _FakeNews implements NewsRepository {
  final requests = <String?>[];
  final read = <int>{};

  @override
  Future<Result<ArticleListing>> getArticles({
    required int page,
    String? source,
  }) async {
    requests.add(source);
    return const Success(
      ArticleListing(
        totalPages: 1,
        totalResults: 1,
        page: 1,
        articles: [_article],
      ),
    );
  }

  @override
  Future<Result<Article>> getArticleDetail({required int articleId}) async =>
      const Success(_article);

  @override
  Future<Result<List<String>>> getSources() async =>
      const Success(['G1 Cinema', 'Omelete']);

  @override
  Result<Set<int>> readArticleIds() => Success({...read});

  @override
  Result<void> markArticleRead(int articleId) {
    read.add(articleId);
    return const Success(null);
  }
}

class _FakeShelves implements ShelvesRepository {
  bool fail = false;

  @override
  Future<Result<Paged<Shelf>>> getUserShelves({
    required String userId,
    required int page,
    bool profile = false,
  }) async => fail
      ? const Failure(AppError.network)
      : const Success(
          Paged(
            items: [
              Shelf(
                id: 2,
                ownerId: 'me',
                name: 'Quero ver',
                visibility: ContentVisibility.public,
                systemType: SystemShelfType.watchlist,
                sortMode: ShelfSort.manual,
                pinned: false,
                totalMovies: 0,
                totalWatched: 0,
                posterPaths: [],
                isSelf: true,
              ),
            ],
            page: 1,
            totalPages: 1,
            totalResults: 1,
            hasNext: false,
          ),
        );

  @override
  Future<Result<MovieShelves>> addMovieToShelves({
    required int movieId,
    required List<int> shelfIds,
  }) async =>
      Success(MovieShelves(movieId: movieId, shelfIds: shelfIds.toSet()));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  test(
    'the list loads the sources, filters by one and marks articles as read',
    () async {
      final news = _FakeNews()..read.add(1);
      final cubit = NewsListCubit(
        GetArticles(news),
        getSources: GetArticleSources(news),
        getReadArticles: GetReadArticles(news),
        markArticleRead: MarkArticleRead(news),
      );
      await Future<void>.delayed(Duration.zero);

      var state = cubit.state as NewsListSuccess;
      expect(state.sources, ['G1 Cinema', 'Omelete']);
      expect(state.readIds, {1});

      cubit.pagingController.fetchNextPage();
      await Future<void>.delayed(Duration.zero);
      cubit.selectSource('Omelete');
      cubit.pagingController.fetchNextPage();
      await Future<void>.delayed(Duration.zero);
      cubit.markRead(3);

      state = cubit.state as NewsListSuccess;
      expect(news.requests, [null, 'Omelete']);
      expect(state.selectedSource, 'Omelete');
      expect(state.readIds, {1, 3});
      expect(news.read, {1, 3});
      await cubit.close();
    },
  );

  test('switching back to a source keeps its pages', () async {
    final news = _FakeNews();
    final cubit = NewsListCubit(
      GetArticles(news),
      getSources: GetArticleSources(news),
    );
    await Future<void>.delayed(Duration.zero);
    final all = cubit.pagingController..fetchNextPage();
    await Future<void>.delayed(Duration.zero);

    cubit.selectSource('Omelete');
    cubit.pagingController.fetchNextPage();
    await Future<void>.delayed(Duration.zero);
    cubit.selectSource(null);

    expect(cubit.pagingController, same(all));
    expect(cubit.pagingController.items, [_article]);
    expect(news.requests, [null, 'Omelete']);
    await cubit.close();
  });

  test(
    'opening an article marks it as read and Quero ver turns on in one tap',
    () async {
      final news = _FakeNews();
      final cubit = ArticleDetailCubit(
        GetArticleDetail(news),
        3,
        addMovieToWatchlist: AddMovieToWatchlist(_FakeShelves()),
        markArticleRead: MarkArticleRead(news),
      );
      await Future<void>.delayed(Duration.zero);

      expect(news.read, {3});
      final movie = (cubit.state as ArticleDetailSuccess).article.movies.single;
      expect(await cubit.addToWatchlist(movie), true);
      expect(
        (cubit.state as ArticleDetailSuccess).article.movies.single.inQueroVer,
        true,
      );
      await cubit.close();
    },
  );

  test('a failed Quero ver turns the chip back off', () async {
    final cubit = ArticleDetailCubit(
      GetArticleDetail(_FakeNews()),
      3,
      addMovieToWatchlist: AddMovieToWatchlist(_FakeShelves()..fail = true),
    );
    await Future<void>.delayed(Duration.zero);

    final movie = (cubit.state as ArticleDetailSuccess).article.movies.single;
    expect(await cubit.addToWatchlist(movie), false);
    expect(
      (cubit.state as ArticleDetailSuccess).article.movies.single.inQueroVer,
      false,
    );
    await cubit.close();
  });
}
