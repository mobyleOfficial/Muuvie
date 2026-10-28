import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:news/news.dart';
import 'package:news_ui/news_list/news_list_state.dart';

/// The news list (F5.8): newest first, filtered by source, with the articles
/// already read marked. The filter and the marks are optional, so the home
/// screen can show a plain list.
class NewsListCubit extends Cubit<NewsListState> {
  final GetArticles _getArticles;
  final GetArticleSources? _getSources;
  final MarkArticleRead? _markArticleRead;

  int _totalPages = 1;

  late final PagingController<int, Article> pagingController = PagingController(
    getNextPageKey: (state) {
      final nextKey = state.nextIntPageKey;

      if (nextKey > _totalPages) {
        return null;
      }
      return nextKey;
    },
    fetchPage: _fetchPage,
  );

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

  String? get _source => switch (state) {
    NewsListSuccess(:final selectedSource) => selectedSource,
    _ => null,
  };

  Future<void> _loadSources() async {
    final getSources = _getSources;
    if (getSources == null) return;
    final result = await getSources();
    if (isClosed) return;
    if (result case Success(:final data)) {
      _update((current) => current.copyWith(sources: data));
    }
  }

  Future<List<Article>> _fetchPage(int page) async {
    final result = await _getArticles(
      GetArticlesParams(page: page, source: _source),
    );

    switch (result) {
      case Success(:final data):
        _totalPages = data.totalPages;
        return data.articles;
      case Failure(:final error):
        throw Exception(error.message);
    }
  }

  void selectSource(String? source) {
    if (source == _source) return;
    _update((current) => current.copyWith(selectedSource: () => source));
    refresh();
  }

  void refresh() {
    _totalPages = 1;
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
    pagingController.dispose();
    return super.close();
  }
}
