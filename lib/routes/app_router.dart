import 'package:auth_ui/login_router.dart';
import 'package:social/social_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:muuvie/routes/auth_flow_page.dart';
import 'package:muuvie/routes/main_screen.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:movies_ui/person_detail/person_detail_router.dart';
import 'package:news_ui/article_detail/article_detail_router.dart';
import 'package:news_ui/news_list/news_list_router.dart';
import 'package:programacao/programacao_router.dart';
import 'package:profile_ui/profile_router.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:search/search_router.dart';
import 'package:locadoras_ui/locadoras_router.dart';
import 'package:shelves_ui/shelves_router.dart';
import 'package:watch_logs_ui/watch_logs_router.dart';
import 'package:imports_ui/imports_router.dart';
import 'package:cineclubes_ui/cineclubes_router.dart';
import 'package:gamification_ui/gamification_router.dart';
import 'package:onboarding_ui/onboarding_router.dart';
import 'package:maratonas_ui/maratonas_router.dart';
import 'package:whispers/whispers_router.dart';

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
          page: ProfileTab.page,
          children: [
            AutoRoute(page: ProfileRoute.page, initial: true),
            AutoRoute(page: MovieDetailRoute.page),
            AutoRoute(page: ShelfDetailRoute.page),
            AutoRoute(page: MovieShelvesRoute.page),
            AutoRoute(page: SavedShelvesRoute.page),
            AutoRoute(page: LocadoraDetailRoute.page),
            AutoRoute(page: PersonDetailRoute.page),
            AutoRoute(page: FollowsRoute.page),
            AutoRoute(page: MaratonaDetailRoute.page),
            AutoRoute(page: MaratonaEditorRoute.page),
            AutoRoute(page: CineClubeDetailRoute.page),
            AutoRoute(page: CineClubeEditorRoute.page),
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
            AutoRoute(page: MuuvieRankingRoute.page),
            AutoRoute(page: MostAnticipatedRoute.page),
            AutoRoute(page: MovieDetailRoute.page),
            AutoRoute(page: DiscoverListRoute.page),
            AutoRoute(page: ShelfDetailRoute.page),
            AutoRoute(page: MovieShelvesRoute.page),
            AutoRoute(page: SavedShelvesRoute.page),
            AutoRoute(page: LocadoraDetailRoute.page),
            AutoRoute(page: PublicProfileRoute.page),
            AutoRoute(page: PersonDetailRoute.page),
            AutoRoute(page: FollowsRoute.page),
            AutoRoute(page: ConversationRoute.page),
            AutoRoute(page: MaratonaDetailRoute.page),
            AutoRoute(page: CineClubeDetailRoute.page),
          ],
        ),
        AutoRoute(
          page: SocialTab.page,
          children: [
            AutoRoute(page: SocialRoute.page, initial: true),
            AutoRoute(page: PublicProfileRoute.page),
            AutoRoute(page: MovieDetailRoute.page),
            AutoRoute(page: LocadoraDetailRoute.page),
            AutoRoute(page: ShelfDetailRoute.page),
            AutoRoute(page: MovieShelvesRoute.page),
            AutoRoute(page: SavedShelvesRoute.page),
            AutoRoute(page: PersonDetailRoute.page),
            AutoRoute(page: WhispersRoute.page),
            AutoRoute(page: ConversationRoute.page),
            AutoRoute(page: FollowsRoute.page),
            AutoRoute(page: MaratonaDetailRoute.page),
            AutoRoute(page: MaratonaEditorRoute.page),
            AutoRoute(page: CineClubeDetailRoute.page),
            AutoRoute(page: CineClubeEditorRoute.page),
          ],
        ),
        // Atts, Catálogo and Perfil are SocialTab, SearchTab and ProfileTab (F0.7).
        AutoRoute(
          page: ProgramacaoTab.page,
          children: [
            AutoRoute(page: ProgramacaoRoute.page, initial: true),
            AutoRoute(page: MaratonaDetailRoute.page),
            AutoRoute(page: MaratonaEditorRoute.page),
            AutoRoute(page: CineClubeDetailRoute.page),
            AutoRoute(page: CineClubeEditorRoute.page),
            AutoRoute(page: MovieDetailRoute.page),
            AutoRoute(page: PublicProfileRoute.page),
            AutoRoute(page: ShelfDetailRoute.page),
            AutoRoute(page: MovieShelvesRoute.page),
            AutoRoute(page: SavedShelvesRoute.page),
            AutoRoute(page: LocadoraDetailRoute.page),
            AutoRoute(page: PersonDetailRoute.page),
            AutoRoute(page: FollowsRoute.page),
            AutoRoute(page: ConversationRoute.page),
          ],
        ),
        AutoRoute(
          page: NoticiasTab.page,
          children: [
            AutoRoute(page: NewsListRoute.page, initial: true),
            AutoRoute(page: ArticleDetailRoute.page),
            AutoRoute(page: MovieDetailRoute.page),
            AutoRoute(page: PersonDetailRoute.page),
            AutoRoute(page: PublicProfileRoute.page),
            AutoRoute(page: ShelfDetailRoute.page),
            AutoRoute(page: MovieShelvesRoute.page),
            AutoRoute(page: SavedShelvesRoute.page),
            AutoRoute(page: LocadoraDetailRoute.page),
            AutoRoute(page: MaratonaDetailRoute.page),
            AutoRoute(page: CineClubeDetailRoute.page),
          ],
        ),
      ],
    ),
    // The path lets a profile link (/@handle) match while the app runs;
    // profileDeepLink then opens it over the main screen.
    AutoRoute(page: PublicProfileRoute.page, path: '/:userId'),
    // Maratona links (/m/<slug>, F7.3), opened over the main screen too.
    AutoRoute(page: MaratonaDetailRoute.page, path: '/m/:slug'),
    // CineClube links (/c/<slug>, F8.3), opened over the main screen too.
    AutoRoute(page: CineClubeDetailRoute.page, path: '/c/:slug'),
    AutoRoute(page: MaratonaEditorRoute.page),
    AutoRoute(page: CineClubeEditorRoute.page),
    AutoRoute(page: FollowsRoute.page),
    AutoRoute(page: ConversationRoute.page),
    AutoRoute(page: LocadoraDetailRoute.page),
    AutoRoute(page: ShelfDetailRoute.page),
    AutoRoute(page: MovieShelvesRoute.page),
    AutoRoute(page: SavedShelvesRoute.page),
    AutoRoute(page: MovieDetailRoute.page),
    AutoRoute(page: PersonDetailRoute.page),
    CustomRoute(
      page: HighlightsEditorRoute.page,
      transitionsBuilder: TransitionsBuilders.slideBottom,
      duration: _animationDuration,
      reverseDuration: _animationDuration,
    ),
    for (final page in [
      ShelterRoute.page,
      MissionsRoute.page,
      DiaryRoute.page,
      WatchPartyRoute.page,
      PosterGameRoute.page,
      OnboardingRoute.page,
      SettingsRoute.page,
    ])
      CustomRoute(
        page: page,
        transitionsBuilder: TransitionsBuilders.slideBottom,
        duration: _animationDuration,
        reverseDuration: _animationDuration,
      ),
    CustomRoute(
      page: RetrospectiveRoute.page,
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
      page: AddMoviesToShelfRoute.page,
      transitionsBuilder: TransitionsBuilders.slideBottom,
      duration: _animationDuration,
      reverseDuration: _animationDuration,
    ),
    CustomRoute(
      page: AddToShelvesRoute.page,
      transitionsBuilder: TransitionsBuilders.slideBottom,
      duration: _animationDuration,
      reverseDuration: _animationDuration,
    ),
    CustomRoute(
      page: PickLocadoraShelvesRoute.page,
      transitionsBuilder: TransitionsBuilders.slideBottom,
      duration: _animationDuration,
      reverseDuration: _animationDuration,
    ),
    CustomRoute(
      page: LogSessionRoute.page,
      transitionsBuilder: TransitionsBuilders.slideBottom,
      duration: _animationDuration,
      reverseDuration: _animationDuration,
    ),
    CustomRoute(
      page: RateMovieRoute.page,
      transitionsBuilder: TransitionsBuilders.slideBottom,
      duration: _animationDuration,
      reverseDuration: _animationDuration,
    ),
    AutoRoute(page: MovieHistoryRoute.page),
    // Import flow (phase 3): start → job (preview, progress, report) → match queue.
    CustomRoute(
      page: ImportStartRoute.page,
      transitionsBuilder: TransitionsBuilders.slideBottom,
      duration: _animationDuration,
      reverseDuration: _animationDuration,
    ),
    CustomRoute(
      page: ImportJobRoute.page,
      transitionsBuilder: TransitionsBuilders.slideBottom,
      duration: _animationDuration,
      reverseDuration: _animationDuration,
    ),
    AutoRoute(page: ImportUnmatchedRoute.page),
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

@RoutePage(name: 'ProgramacaoTab')
class ProgramacaoTabPage extends AutoRouter {
  const ProgramacaoTabPage({super.key});
}

@RoutePage(name: 'NoticiasTab')
class NoticiasTabPage extends AutoRouter {
  const NoticiasTabPage({super.key});
}

/// Profile links (`https://muuvie.app/@handle`, F5.5), maratona links
/// (`/m/<slug>`, F7.3) and CineClube links (`/c/<slug>`, F8.3) open over the
/// main screen, so back returns to the app.
/// Other links open as usual.
DeepLink profileDeepLink(PlatformDeepLink link) {
  final segments = link.uri.pathSegments;
  if (segments.length == 2 &&
      segments.first == 'm' &&
      segments.last.isNotEmpty) {
    return DeepLink([
      const MainRoute(),
      MaratonaDetailRoute(slug: segments.last),
    ]);
  }
  if (segments.length == 2 &&
      segments.first == 'c' &&
      segments.last.isNotEmpty) {
    return DeepLink([
      const MainRoute(),
      CineClubeDetailRoute(slug: segments.last),
    ]);
  }
  if (segments.length == 1 &&
      segments.single.length > 1 &&
      segments.single.startsWith('@')) {
    return DeepLink([
      const MainRoute(),
      PublicProfileRoute(userId: segments.single),
    ]);
  }
  return DeepLink.defaultPath;
}
