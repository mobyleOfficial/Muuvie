import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:news_ui/article_detail/article_detail_page.dart';

part 'article_detail_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib/article_detail'])
class ArticleDetailRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [AutoRoute(page: ArticleDetailRoute.page)];
}
