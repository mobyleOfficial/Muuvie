import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news/news.dart';
import 'package:news_ui/article_detail/article_detail_state.dart';
import 'package:shelves/shelves.dart' show AddMovieToWatchlist;

class ArticleDetailCubit extends Cubit<ArticleDetailState> {
  final GetArticleDetail _getArticleDetail;
  final int _articleId;
  final AddMovieToWatchlist? _addMovieToWatchlist;

  ArticleDetailCubit(
    this._getArticleDetail,
    this._articleId, {
    AddMovieToWatchlist? addMovieToWatchlist,
    MarkArticleRead? markArticleRead,
  }) : _addMovieToWatchlist = addMovieToWatchlist,
       super(const ArticleDetailLoading()) {
    markArticleRead?.call(_articleId);
    _fetchArticleDetail();
  }

  void reload() {
    emit(const ArticleDetailLoading());
    _fetchArticleDetail();
  }

  Future<void> _fetchArticleDetail() async {
    final result = await _getArticleDetail(_articleId);
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(ArticleDetailSuccess(data));
      case Failure(:final error):
        emit(ArticleDetailError(error.message));
    }
  }

  /// "Quero ver" in one tap (F5.8). The chip turns on right away and goes
  /// back if the request fails.
  Future<bool> addToWatchlist(ArticleMovie movie) async {
    final current = state;
    final add = _addMovieToWatchlist;
    if (current is! ArticleDetailSuccess || add == null) return false;
    _setInQueroVer(current.article, movie.movieId, true);
    final result = await add(movie.movieId);
    if (isClosed) return false;
    if (result is Failure) {
      _setInQueroVer(current.article, movie.movieId, false);
      return false;
    }
    return true;
  }

  void _setInQueroVer(Article article, int movieId, bool value) => emit(
    ArticleDetailSuccess(
      article.copyWith(
        movies: [
          for (final movie in article.movies)
            movie.movieId == movieId
                ? movie.copyWith(inQueroVer: value)
                : movie,
        ],
      ),
    ),
  );
}
