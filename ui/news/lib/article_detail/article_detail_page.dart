import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:news/news.dart';
import 'package:news_ui/article_detail/article_detail_bloc.dart';
import 'package:news_ui/article_detail/article_detail_screen.dart';
import 'package:shelves/shelves.dart' show AddMovieToWatchlist;

@RoutePage()
class ArticleDetailPage extends StatefulWidget {
  final int articleId;
  final String articleTitle;

  const ArticleDetailPage({
    super.key,
    required this.articleId,
    required this.articleTitle,
  });

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late final ArticleDetailCubit _cubit = ArticleDetailCubit(
    GetIt.I<GetArticleDetail>(),
    widget.articleId,
    addMovieToWatchlist: GetIt.I<AddMovieToWatchlist>(),
    markArticleRead: GetIt.I<MarkArticleRead>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ArticleDetailScreen(cubit: _cubit);
}
