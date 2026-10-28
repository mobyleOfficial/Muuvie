import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:locadoras_ui/locadoras_router.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:movies_ui/person_detail/person_detail_router.dart';
import 'package:news_ui/article_detail/article_detail_router.dart';
import 'package:profile_ui/profile_router.dart';
import 'package:public_profile/public_profile_router.dart';
import 'package:search/discover/discover_list_page.dart';
import 'package:search/muuvie_ranking/muuvie_ranking_page.dart';
import 'package:cineclubes_ui/cineclubes_router.dart';
import 'package:maratonas_ui/maratonas_router.dart';
import 'package:search/search_router.dart';
import 'package:whispers/whispers_router.dart';

String? resolveRouteTitle(
  RouteData<dynamic> routeData,
  AppLocalizations? l10n,
) => switch (routeData.name) {
  MovieDetailRoute.name => routeData.argsAs<MovieDetailRouteArgs>().movieTitle,
  PublicProfileRoute.name => () {
    final args = routeData.argsAs<PublicProfileRouteArgs>();
    // An @handle reads well as a title; a raw user id does not.
    return args.displayName ??
        (args.userId.startsWith('@') ? args.userId : l10n?.profile);
  }(),
  PersonDetailRoute.name =>
    routeData.argsAs<PersonDetailRouteArgs>().personName,
  DiscoverListRoute.name => switch (routeData
      .argsAs<DiscoverListRouteArgs>()
      .kind) {
    DiscoverKind.shelves => l10n?.discoverShelves,
    DiscoverKind.locadoras => l10n?.discoverLocadoras,
    DiscoverKind.profiles => l10n?.discoverProfiles,
  },
  ReleaseDateDecadesRoute.name => l10n?.routeReleaseDate ?? 'Release Date',
  ReleaseDateYearsRoute.name =>
    routeData.argsAs<ReleaseDateYearsRouteArgs>().decadeLabel,
  ReleaseDateMoviesRoute.name =>
    routeData.argsAs<ReleaseDateMoviesRouteArgs>().title,
  BrowseCategoriesRoute.name => l10n?.routeBrowse ?? 'Browse',
  MostPopularRoute.name => l10n?.routeMostPopular ?? 'Most Popular',
  MuuvieRankingRoute.name => switch (routeData
      .argsAs<MuuvieRankingRouteArgs>()
      .ranking) {
    MuuvieRanking.trending => l10n?.discoverTrending,
    MuuvieRanking.loved => l10n?.discoverMostLoved,
  },
  MostAnticipatedRoute.name => l10n?.routeMostAnticipated ?? 'Most Anticipated',
  ArticleDetailRoute.name =>
    routeData.argsAs<ArticleDetailRouteArgs>().articleTitle,
  ShelfDetailRoute.name => routeData.argsAs<ShelfDetailRouteArgs>().shelfName,
  MovieShelvesRoute.name => l10n?.movieShelvesTitle,
  SavedShelvesRoute.name => l10n?.savedShelvesTitle,
  LocadoraDetailRoute.name =>
    routeData.argsAs<LocadoraDetailRouteArgs>().locadoraName,
  FollowsRoute.name => routeData.argsAs<FollowsRouteArgs>().profileName,
  WhispersRoute.name => l10n?.attsWhispers,
  MaratonaDetailRoute.name => () {
    final title = routeData
        .argsAs<MaratonaDetailRouteArgs>(
          orElse: () => MaratonaDetailRouteArgs(
            slug: routeData.params.getString('slug', ''),
          ),
        )
        .title;
    return title.isNotEmpty ? title : l10n?.programacaoMaratonasTab;
  }(),
  MaratonaEditorRoute.name =>
    routeData
                .argsAs<MaratonaEditorRouteArgs>(
                  orElse: () => const MaratonaEditorRouteArgs(),
                )
                .slug ==
            null
        ? l10n?.maratonaEditorNewTitle
        : l10n?.maratonaEditorEditTitle,
  CineClubeDetailRoute.name => () {
    final title = routeData
        .argsAs<CineClubeDetailRouteArgs>(
          orElse: () => CineClubeDetailRouteArgs(
            slug: routeData.params.getString('slug', ''),
          ),
        )
        .title;
    return title.isNotEmpty ? title : l10n?.programacaoCineClubesTab;
  }(),
  CineClubeEditorRoute.name =>
    routeData
                .argsAs<CineClubeEditorRouteArgs>(
                  orElse: () => const CineClubeEditorRouteArgs(),
                )
                .slug ==
            null
        ? l10n?.cineclubeEditorNewTitle
        : l10n?.cineclubeEditorEditTitle,
  ConversationRoute.name => routeData.argsAs<ConversationRouteArgs>().name,
  _ => null,
};
