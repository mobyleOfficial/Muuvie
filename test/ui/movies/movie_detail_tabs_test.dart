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
  @override
  Future<Result<Movie>> getMovieDetail({required int movieId}) async =>
      const Success(
        Movie(
          id: 1,
          title: 'Interstellar',
          posterPath: '',
          info: MovieInfo(
            overview: 'Overview',
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
  @override
  Widget activities(
    int movieId, {
    ValueListenable<MovieActivityKind?>? kindRequests,
  }) => MovieActivitiesFeed(movieId: movieId, kindRequests: kindRequests);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
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
      ..registerSingleton<MovieDetailLinks>(_Links());
  });
  tearDown(() => GetIt.I.reset());

  testWidgets(
    'every tab opens with the header expanded on a phone, without overflow',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(412, 860);
      addTearDown(tester.view.reset);
      final cubit = MovieDetailCubit(GetMovieDetail(_Movies()), 1);
      addTearDown(cubit.close);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pt'),
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
