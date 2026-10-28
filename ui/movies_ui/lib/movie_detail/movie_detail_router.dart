import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:movies_ui/movie_detail/movie_detail_page.dart';

part 'movie_detail_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib/movie_detail'])
class MovieDetailRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [AutoRoute(page: MovieDetailRoute.page)];
}
