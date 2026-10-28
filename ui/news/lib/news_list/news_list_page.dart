import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:news/news.dart';
import 'package:news_ui/news_list/news_list_bloc.dart';
import 'package:news_ui/news_list/news_list_screen.dart';

/// Root of the Notícias tab in the new navigation (F0.7, F5.8).
@RoutePage()
class NewsListPage extends StatefulWidget {
  const NewsListPage({super.key});

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  late final NewsListCubit _cubit = NewsListCubit(
    GetIt.I<GetArticles>(),
    getSources: GetIt.I<GetArticleSources>(),
    getReadArticles: GetIt.I<GetReadArticles>(),
    markArticleRead: GetIt.I<MarkArticleRead>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      NewsListScreen(cubit: _cubit, highlightFirst: true);
}
