import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_bloc.dart';
import 'package:movies_ui/movie_detail/movie_detail_links.dart';
import 'package:movies_ui/movie_detail/movie_detail_screen.dart';
import 'package:shelves/shelves.dart';
import 'package:social/feed/movie_activities_feed.dart';
import 'package:social_network/social_network.dart';
import 'package:watch_logs/watch_logs.dart';

import '../../helpers/fake_social_network_repository.dart';

class _Movies implements MoviesRepository {
  final String? overviewLanguage;
  final bool overviewTranslated;

  _Movies({this.overviewLanguage, this.overviewTranslated = false});

  @override
  Future<Result<Movie>> getMovieDetail({required int movieId}) async => Success(
    Movie(
      id: 1,
      title: 'Interstellar',
      posterPath: '',
      info: MovieInfo(
        overview: 'Overview',
        overviewLanguage: overviewLanguage,
        overviewTranslated: overviewTranslated,
        backdropPath: '',
        releaseDate: '2014-11-06',
        runtime: 169,
        genres: ['Drama'],
        director: 'Christopher Nolan',
      ),
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WatchLogs implements WatchLogsRepository {
  @override
  Future<Result<MovieUserState>> getMovieState(int movieId) async =>
      const Success(MovieUserState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Community implements MovieCommunityRepository {
  @override
  Future<Result<MovieCommunity>> getCommunity(int movieId) async =>
      const Success(MovieCommunity(watched: 2));

  @override
  Future<Result<MovieEvents>> getEvents(int movieId) async =>
      const Success(MovieEvents());

  @override
  Future<Result<MovieEventPage>> getCineClubes(
    int movieId, {
    int page = 1,
  }) async => const Success(MovieEventPage());

  @override
  Future<Result<MovieEventPage>> getMaratonas(
    int movieId, {
    int page = 1,
  }) async => const Success(MovieEventPage());

  @override
  Future<Result<MovieTimeline>> getTimeline(
    int movieId, {
    int months = 12,
  }) async => const Success(MovieTimeline());
}

class _Shelves implements ShelvesRepository {
  @override
  Future<Result<Paged<PublicShelf>>> getPublicShelvesWithMovie({
    required int movieId,
    required int page,
  }) async => const Success(
    Paged(items: [], page: 1, totalPages: 0, totalResults: 0, hasNext: false),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Links implements MovieDetailLinks {
  /// As if this detail were opened from a universe.
  bool universeOpen = false;

  @override
  bool canOpenUniverse(BuildContext context) => !universeOpen;

  @override
  Widget activities(
    int movieId, {
    ValueListenable<MovieActivityKind?>? kindRequests,
  }) => MovieActivitiesFeed(movieId: movieId, kindRequests: kindRequests);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Links links;

  setUp(() {
    links = _Links();
    final social = FakeSocialNetworkRepository();
    final watchLogs = _WatchLogs();
    final community = _Community();
    GetIt.I
      ..registerFactory(() => GetMovieCommunity(community))
      ..registerFactory(() => GetMovieEvents(community))
      ..registerFactory(() => GetMovieCineClubes(community))
      ..registerFactory(() => GetMovieMaratonas(community))
      ..registerFactory(() => GetMovieTimeline(community))
      ..registerFactory(() => GetPublicShelvesWithMovie(_Shelves()))
      ..registerFactory(() => GetMovieActivities(social))
      ..registerFactory(() => ToggleActivityLove(social))
      ..registerFactory(() => GetMovieWatchState(watchLogs))
      ..registerFactory(() => LogWatchSession(watchLogs))
      ..registerFactory(() => StartRewatch(watchLogs))
      ..registerFactory(() => SetWatchingNow(watchLogs))
      ..registerSingleton<MovieDetailLinks>(links);
  });
  tearDown(() => GetIt.I.reset());

  Future<void> pumpDetail(
    WidgetTester tester, {
    String? overviewLanguage,
    bool overviewTranslated = false,
    Locale locale = const Locale('pt'),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(412, 860);
    addTearDown(tester.view.reset);
    final cubit = MovieDetailCubit(
      GetMovieDetail(
        _Movies(
          overviewLanguage: overviewLanguage,
          overviewTranslated: overviewTranslated,
        ),
      ),
      1,
    );
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: MovieDetailScreen(cubit: cubit, onAddToShelves: (_, _) {}),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a synopsis in English says so, unless the app is in English', (
    tester,
  ) async {
    await pumpDetail(tester, overviewLanguage: 'en');
    expect(find.text('Sinopse disponível só em inglês'), findsOneWidget);

    await pumpDetail(tester);
    expect(find.text('Sinopse disponível só em inglês'), findsNothing);

    await pumpDetail(
      tester,
      overviewLanguage: 'en',
      locale: const Locale('en'),
    );
    expect(find.text('Synopsis available only in English'), findsNothing);
    expect(find.text('Overview'), findsOneWidget);
  });

  Future<void> openActions(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Ações'));
    await tester.pumpAndSettle();
  }

  testWidgets('the actions offer the universe of the movie', (tester) async {
    await pumpDetail(tester);
    await openActions(tester);

    expect(find.text('Explorar universo'), findsOneWidget);
  });

  testWidgets('only one universe at a time: a detail opened from one does not '
      'offer another', (tester) async {
    links.universeOpen = true;
    await pumpDetail(tester);
    await openActions(tester);

    expect(find.text('Explorar universo'), findsNothing);
    expect(find.text('Criar CineClube com este filme'), findsOneWidget);
  });

  testWidgets('a machine translated synopsis says so', (tester) async {
    await pumpDetail(tester, overviewTranslated: true);

    expect(find.text('Sinopse traduzida automaticamente'), findsOneWidget);
    expect(find.text('Sinopse disponível só em inglês'), findsNothing);
  });

  testWidgets(
    'every tab opens with the header expanded on a phone, without overflow',
    (tester) async {
      await pumpDetail(tester);

      for (final tab in ['Comunidade', 'Atividade', 'Sobre']) {
        await tester.tap(find.text(tab).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: tab);
      }
      // Scrolling the header away gives the tab the whole screen.
      await tester.tap(find.text('Atividade').first);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(NestedScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
