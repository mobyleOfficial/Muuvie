import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:universe_ui/movie_universe/movie_universe_page.dart';

part 'universe_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib/movie_universe'])
class UniverseRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [AutoRoute(page: MovieUniverseRoute.page)];
}
