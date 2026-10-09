import 'package:auth_ui/login_router.dart';
import 'package:social/social_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:muuvie/routes/auth_flow_page.dart';
import 'package:muuvie/routes/main_screen.dart';
import 'package:movies_ui/favorite_movies/favorite_movies_router.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:movies_ui/movie_list_detail/movie_list_detail_router.dart';
import 'package:movies_ui/watch_list/watch_list_router.dart';
import 'package:news_ui/article_detail/article_detail_router.dart';
import 'package:reviews/review_creation/review_creation_router.dart';
import 'package:movies_ui/home/movies_home_router.dart';
import 'package:user_activity/new_user_activity/new_user_activity_router.dart';
import 'package:user_activity/user_activities/user_activities_router.dart';
import 'package:profile_ui/profile_router.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:reviews/review_details/review_details_router.dart';
import 'package:reviews/reviews_list/reviews_router.dart';
import 'package:search/search_router.dart';

part 'app_router.gr.dart';

const _animationDuration = Duration(milliseconds: 300);

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: MainRoute.page,
          initial: true,
          children: [
            AutoRoute(
              page: HomeTab.page,
              children: [
                AutoRoute(page: MoviesHomeRoute.page, initial: true),
                AutoRoute(page: ReviewsRoute.page),
                AutoRoute(page: ReviewDetailsRoute.page),
                AutoRoute(page: MovieDetailRoute.page),
                AutoRoute(page: MovieListDetailRoute.page),
                AutoRoute(page: FavoriteMoviesRoute.page),
                AutoRoute(page: WatchListRoute.page),
                AutoRoute(page: ArticleDetailRoute.page),
              ],
            ),
            AutoRoute(
              page: SearchTab.page,
              children: [
                AutoRoute(page: SearchRoute.page, initial: true),
                AutoRoute(page: ReleaseDateDecadesRoute.page),
                AutoRoute(page: ReleaseDateYearsRoute.page),
                AutoRoute(page: ReleaseDateMoviesRoute.page),
                AutoRoute(page: BrowseCategoriesRoute.page),
                AutoRoute(page: MostPopularRoute.page),
                AutoRoute(page: HighestRatedRoute.page),
                AutoRoute(page: MostAnticipatedRoute.page),
                AutoRoute(page: FeaturedListsRoute.page),
                AutoRoute(page: MovieDetailRoute.page),
                AutoRoute(page: ReviewDetailsRoute.page),
                AutoRoute(page: MovieListDetailRoute.page),
              ],
            ),
            AutoRoute(
              page: SocialTab.page,
              children: [
                AutoRoute(page: SocialRoute.page, initial: true),
                AutoRoute(page: PublicProfileRoute.page),
                AutoRoute(page: MovieDetailRoute.page),
                AutoRoute(page: ReviewDetailsRoute.page),
                AutoRoute(page: MovieListDetailRoute.page),
                AutoRoute(page: FavoriteMoviesRoute.page),
                AutoRoute(page: WatchListRoute.page),
                AutoRoute(page: UserActivitiesRoute.page),
              ],
            ),
            AutoRoute(
              page: ProfileTab.page,
              children: [
                AutoRoute(page: ProfileRoute.page, initial: true),
                AutoRoute(page: ReviewDetailsRoute.page),
                AutoRoute(page: MovieDetailRoute.page),
                AutoRoute(page: MovieListDetailRoute.page),
                AutoRoute(page: FavoriteMoviesRoute.page),
                AutoRoute(page: WatchListRoute.page),
              ],
            ),
          ],
        ),
        AutoRoute(page: ReviewCreationRoute.page),
        AutoRoute(page: PublicProfileRoute.page),
        CustomRoute(
          page: NewUserActivityRoute.page,
          transitionsBuilder: TransitionsBuilders.slideBottom,
          duration: _animationDuration,
          reverseDuration: _animationDuration,
        ),
        CustomRoute(
          page: CreateListRoute.page,
          transitionsBuilder: TransitionsBuilders.slideBottom,
          duration: _animationDuration,
          reverseDuration: _animationDuration,
        ),
        CustomRoute(
          page: EditProfileRoute.page,
          transitionsBuilder: TransitionsBuilders.slideBottom,
          duration: _animationDuration,
          reverseDuration: _animationDuration,
        ),
        CustomRoute(
          page: AuthFlowRoute.page,
          transitionsBuilder: TransitionsBuilders.slideBottom,
          duration: _animationDuration,
          reverseDuration: _animationDuration,
          children: [
            AutoRoute(page: LoginRoute.page, initial: true),
            AutoRoute(page: SignUpRoute.page),
          ],
        ),
      ];
}

@RoutePage(name: 'HomeTab')
class HomeTabPage extends AutoRouter {
  const HomeTabPage({super.key});
}

@RoutePage(name: 'SearchTab')
class SearchTabPage extends AutoRouter {
  const SearchTabPage({super.key});
}

@RoutePage(name: 'SocialTab')
class SocialTabPage extends AutoRouter {
  const SocialTabPage({super.key});
}

@RoutePage(name: 'ProfileTab')
class ProfileTabPage extends AutoRouter {
  const ProfileTabPage({super.key});
}

