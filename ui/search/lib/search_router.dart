import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:search/release_date/decades/release_date_decades_page.dart';
import 'package:search/release_date/years/release_date_years_page.dart';
import 'package:search/release_date/movies/release_date_movies_page.dart';
import 'package:search/browse_categories/browse_categories_page.dart';
import 'package:search/most_popular/most_popular_page.dart';
import 'package:search/muuvie_ranking/muuvie_ranking_page.dart';
import 'package:search/most_anticipated/most_anticipated_page.dart';
import 'package:search/discover/discover_list_page.dart';
import 'package:search/search_page.dart';

part 'search_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class SearchRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SearchRoute.page),
    AutoRoute(page: ReleaseDateDecadesRoute.page),
    AutoRoute(page: ReleaseDateYearsRoute.page),
    AutoRoute(page: ReleaseDateMoviesRoute.page),
    AutoRoute(page: BrowseCategoriesRoute.page),
    AutoRoute(page: MostPopularRoute.page),
    AutoRoute(page: MuuvieRankingRoute.page),
    AutoRoute(page: MostAnticipatedRoute.page),
    AutoRoute(page: DiscoverListRoute.page),
  ];
}
