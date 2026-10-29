import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:news/news.dart';
import 'package:news_ui/news_list/news_list_state.dart';

/// The news list (F5.8): newest first, filtered by source, with the articles
/// already read marked. The filter and the marks are optional, so the home
/// screen can show a plain list. Every source keeps its own pages, so
/// switching back shows them as they were instead of reloading.
class NewsListCubit extends Cubit<NewsListState> {
  final GetArticles _getArticles;
  final GetArticleSources? _getSources;
  final MarkArticleRead? _markArticleRead;

  /// One paged list per source visited; the null key holds every source.
  final Map<String?, PagingController<int, Article>> _controllers = {};
  final Map<String?, int> _totalPages = {};

  NewsListCubit(
    this._getArticles, {
    GetArticleSources? getSources,
    GetReadArticles? getReadArticles,
    MarkArticleRead? markArticleRead,
  }) : _getSources = getSources,
       _markArticleRead = markArticleRead,
       super(NewsListSuccess(readIds: getReadArticles?.call() ?? const {})) {
    _loadSources();
  }

  /// The paged list of the source on screen.
  PagingController<int, Article> get pagingController =>
      _controllers.putIfAbsent(_source, () => _controllerFor(_source));

  String? get _source => switch (state) {
    NewsListSuccess(:final selectedSource) => selectedSource,
    _ => null,
  };

  PagingController<int, Article> _controllerFor(String? source) =>
      PagingController(
        getNextPageKey: (state) {
          final nextKey = state.nextIntPageKey;

          if (nextKey > (_totalPages[source] ?? 1)) {
            return null;
          }
          return nextKey;
        },
        fetchPage: (page) => _fetchPage(page, source),
      );

  Future<void> _loadSources() async {
    final getSources = _getSources;
    if (getSources == null) return;
    final result = await getSources();
    if (isClosed) return;
    if (result case Success(:final data)) {
      _update((current) => current.copyWith(sources: data));
    }
  }

  Future<List<Article>> _fetchPage(int page, String? source) async {
    final result = await _getArticles(
      GetArticlesParams(page: page, source: source),
    );

    switch (result) {
      case Success(:final data):
        _totalPages[source] = data.totalPages;
        return data.articles;
      case Failure(:final error):
        throw Exception(error.message);
    }
  }

  /// Shows the source as it was left; one never opened loads its first page.
  void selectSource(String? source) {
    if (source == _source) return;
    _update((current) => current.copyWith(selectedSource: () => source));
  }

  /// Pull to refresh: reloads the source on screen only.
  void refresh() {
    _totalPages.remove(_source);
    pagingController.refresh();
  }

  void markRead(int articleId) {
    _markArticleRead?.call(articleId);
    _update(
      (current) => current.copyWith(readIds: {...current.readIds, articleId}),
    );
  }

  void _update(NewsListSuccess Function(NewsListSuccess) change) {
    final current = state;
    if (current is NewsListSuccess && !isClosed) emit(change(current));
  }

  @override
  Future<void> close() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    return super.close();
  }
}
