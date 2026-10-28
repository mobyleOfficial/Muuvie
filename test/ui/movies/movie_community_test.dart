import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_community_section.dart';
import 'package:social/feed/movie_activities_feed.dart';
import 'package:social_network/social_network.dart';

import '../../helpers/fake_social_network_repository.dart';

class _FakeCommunityRepository implements MovieCommunityRepository {
  @override
  Future<Result<MovieCommunity>> getCommunity(int movieId) async =>
      const Success(
        MovieCommunity(
          ratings: {Rating.favorite: 2, Rating.notForMe: 1},
          watched: 3,
          wantToWatch: 1,
          shelves: 4,
          emotions: [EmotionCount(emotion: Emotion.joy, count: 2)],
        ),
      );

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

void main() {
  tearDown(() => GetIt.I.reset());

  testWidgets(
    'the community shows the numbers, a bar per given label and emotion, '
    'and opens the shelves',
    (tester) async {
      GetIt.I.registerFactory(
        () => GetMovieCommunity(_FakeCommunityRepository()),
      );
      var opened = false;
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
          home: Scaffold(
            body: SingleChildScrollView(
              child: MovieCommunitySection(
                movieId: 10,
                onOpenShelves: () => opened = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Favoritado'), findsOneWidget);
      expect(find.text('Não foi pra mim'), findsOneWidget);
      expect(find.text('Adorei'), findsNothing);
      expect(find.bySemanticsLabel('Favoritado: 2'), findsOneWidget);
      expect(find.bySemanticsLabel('3 Assistiram'), findsOneWidget);
      expect(find.bySemanticsLabel('Alegria: 2'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('4 Estantes'));
      expect(opened, isTrue);
    },
  );

  test('the Comunidade tab reloads with the kind and people filters', () async {
    final repository = FakeSocialNetworkRepository();
    final cubit = MovieActivitiesCubit(
      movieId: 10,
      kind: MovieActivityKind.ratings,
      getActivities: GetMovieActivities(repository),
      toggleLove: ToggleActivityLove(repository),
    );
    addTearDown(cubit.close);

    await cubit.load();
    await cubit.setFilters(scope: FeedScope.me);
    await cubit.showEverything();
    await cubit.setFilters(kind: MovieActivityKind.updates);

    expect(repository.calls, [
      'movie 10 all ratings',
      'movie 10 me ratings',
      'movie 10 me null',
      'movie 10 me updates',
    ]);
  });
}
