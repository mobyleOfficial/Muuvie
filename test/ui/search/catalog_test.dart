import 'dart:async';

import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:profile/profile.dart';
import 'package:search/discover/catalog_movie_card.dart';
import 'package:search/discover/discover_hub.dart';
import 'package:search/search_bloc.dart';
import 'package:search/search_screen.dart';
import 'package:search/search_state.dart';
import 'package:shelves/shelves.dart';

MovieListing _listing(List<Movie> movies) =>
    MovieListing(totalPages: 1, totalResults: movies.length, movies: movies);

class _Movies implements MoviesRepository {
  Result<MovieListing> trending = Success(_listing(const []));
  Result<MovieListing> loved = Success(_listing(const []));
  Result<MovieListing> releases = Success(_listing(const []));
  final recent = StreamController<List<RecentSearch>>.broadcast();
  final removed = <int?>[];
  final added = <String>[];

  @override
  Future<Result<MovieListing>> getTrendingOnMuuvie({required int page}) async =>
      trending;

  @override
  Future<Result<MovieListing>> getMostLovedOnMuuvie({
    required int page,
  }) async => loved;

  @override
  Future<Result<MovieListing>> discoverMovies({
    required int page,
    int? primaryReleaseYear,
    String? releaseDateGte,
    String? releaseDateLte,
    String? sortBy,
    String? withGenres,
    String? withOriginalLanguage,
    String? withOriginCountry,
    int? minimumVoteCount,
  }) async => releases;

  @override
  Future<Result<List<Genre>>> getGenres() async =>
      const Success([Genre(id: 27, name: 'Terror')]);

  final searched = <String>[];

  @override
  Future<Result<MovieListing>> searchMovies({
    required String query,
    required int page,
  }) async {
    searched.add(query);
    return Success(_listing(const []));
  }

  @override
  Stream<List<RecentSearch>> observeRecentSearches() => recent.stream;

  @override
  Result<void> removeRecentSearches({int? id}) {
    removed.add(id);
    return const Success(null);
  }

  @override
  Result<void> addRecentSearch({required String query}) {
    added.add(query);
    return const Success(null);
  }

  Future<void> dispose() => recent.close();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _emptyPage = Paged<Never>(
  items: [],
  page: 1,
  totalPages: 0,
  totalResults: 0,
  hasNext: false,
);

class _Shelves implements ShelvesRepository {
  @override
  Future<Result<Paged<Shelf>>> discoverShelves({
    String? query,
    required int page,
  }) async => const Success(_emptyPage);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Locadoras implements LocadorasRepository {
  @override
  Future<Result<Paged<Locadora>>> discoverLocadoras({
    String? query,
    required int page,
  }) async => const Success(_emptyPage);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Profiles implements ProfilesRepository {
  final queries = <String?>[];
  Paged<ProfileCard> found = _emptyPage;

  @override
  Future<Result<Paged<ProfileCard>>> discoverProfiles({
    String? query,
    required int page,
  }) async {
    queries.add(query);
    return Success(found);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('pt'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: home),
);

void main() {
  late _Movies movies;
  late _Profiles profiles;

  setUp(() {
    movies = _Movies();
    profiles = _Profiles();
    GetIt.I
      ..registerFactory(() => GetGenres(movies))
      ..registerFactory(() => GetTrendingOnMuuvie(movies))
      ..registerFactory(() => GetMostLovedOnMuuvie(movies))
      ..registerFactory(() => DiscoverMovies(movies))
      ..registerFactory(() => AddRecentSearch(movies))
      ..registerFactory(() => ObserveRecentSearches(movies))
      ..registerFactory(() => RemoveRecentSearches(movies))
      ..registerFactory(() => DiscoverShelves(_Shelves()))
      ..registerFactory(() => DiscoverLocadoras(_Locadoras()))
      ..registerFactory(() => DiscoverProfiles(profiles));
  });
  tearDown(() async {
    await movies.dispose();
    await GetIt.I.reset();
  });

  testWidgets(
    'the hub shows the genres and the Muuvie rows, hides empty ones and retries failed ones',
    (tester) async {
      movies.trending = const Failure(AppError.network);
      movies.loved = Success(
        _listing(const [
          Movie(
            id: 1,
            title: 'Suspiria',
            posterPath: '',
            me: MovieListState(rating: Rating.favorite),
          ),
        ]),
      );

      await tester.pumpWidget(_app(const DiscoverHub()));
      await tester.pumpAndSettle();

      expect(find.text('Terror'), findsOneWidget);
      expect(find.text('Mais amados no Muuvie'), findsOneWidget);
      expect(find.byType(CatalogStateMark), findsOneWidget);
      // Lançamentos came empty, so the row is not there.
      expect(find.text('Em cartaz e lançamentos'), findsNothing);
      expect(find.text('Não foi possível carregar esta seção'), findsOneWidget);

      movies.trending = Success(
        _listing(const [Movie(id: 2, title: 'Nosferatu', posterPath: '')]),
      );
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar esta seção'), findsNothing);
      expect(find.text('Nosferatu'), findsOneWidget);
    },
  );

  testWidgets('the hub scrolls back to the top after reaching the end', (
    tester,
  ) async {
    final rowOf = [
      for (var id = 1; id <= 10; id++)
        Movie(id: id, title: 'Filme $id', posterPath: ''),
    ];
    // Failed rows are shorter than their placeholders, as on the phone.
    movies.trending = const Failure(AppError.network);
    movies.loved = const Failure(AppError.network);
    movies.releases = Success(_listing(rowOf));
    profiles.found = Paged(
      items: [
        for (var id = 1; id <= 6; id++)
          ProfileCard(id: '$id', username: 'cinefilo$id'),
      ],
      page: 1,
      totalPages: 1,
      totalResults: 6,
      hasNext: false,
    );
    tester.view
      ..physicalSize = const Size(412, 500)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(const DiscoverHub()));
    await tester.pumpAndSettle();
    expect(find.text('Terror'), findsOneWidget);

    // Small steps, like a finger, so the rows above are rebuilt one at a time.
    final hub = find.byType(Scrollable).first;
    ScrollPosition position() => tester.state<ScrollableState>(hub).position;
    for (var i = 0; i < 60; i++) {
      await tester.drag(hub, const Offset(0, -80));
      await tester.pumpAndSettle();
    }
    expect(position().pixels, position().maxScrollExtent);

    for (var i = 0; i < 60; i++) {
      await tester.drag(hub, const Offset(0, 80));
      await tester.pumpAndSettle();
    }
    expect(position().pixels, 0);
  });

  testWidgets(
    'the search shows recent searches, asks for 3 letters and searches people',
    (tester) async {
      final cubit = SearchCubit(SearchMovies(movies));
      addTearDown(cubit.close);
      await tester.pumpWidget(_app(SearchScreen(cubit: cubit)));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TextField));
      await tester.pump();
      movies.recent.add([
        RecentSearch(id: 7, query: 'giallo', searchedAt: DateTime(2026)),
      ]);
      await tester.pumpAndSettle();

      expect(find.text('Buscas recentes'), findsOneWidget);
      await tester.tap(find.byTooltip('Remover'));
      expect(movies.removed, [7]);

      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pumpAndSettle();
      expect(find.text('Digite pelo menos 3 letras'), findsOneWidget);

      await tester.tap(find.text('Pessoas'));
      await tester.pumpAndSettle();
      expect(profiles.queries.last, 'ab');

      await tester.testTextInput.receiveAction(TextInputAction.search);
      expect(movies.added, ['ab']);
    },
  );

  testWidgets(
    'the back button leaves the search field, then clears it, before the tab',
    (tester) async {
      final cubit = SearchCubit(SearchMovies(movies));
      addTearDown(cubit.close);
      await tester.pumpWidget(_app(SearchScreen(cubit: cubit)));
      await tester.pumpAndSettle();

      EditableText field() =>
          tester.widget<EditableText>(find.byType(EditableText));
      await tester.enterText(find.byType(TextField), 'giallo');
      await tester.pumpAndSettle();
      expect(field().focusNode.hasFocus, isTrue);

      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(field().focusNode.hasFocus, isFalse);
      expect(field().controller.text, 'giallo');

      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(field().controller.text, isEmpty);
      expect(find.byType(DiscoverHub), findsOneWidget);
    },
  );

  test('the same query searches again after going below 3 letters', () async {
    final cubit = SearchCubit(SearchMovies(movies));
    addTearDown(cubit.close);
    const wait = Duration(milliseconds: 400);

    cubit.onSearchChanged('abc');
    expect(cubit.state, isA<SearchSearching>());
    await Future<void>.delayed(wait);
    cubit.onSearchChanged('ab');
    expect(cubit.state, isA<SearchIdle>());
    cubit.onSearchChanged('abc');
    await Future<void>.delayed(wait);

    expect(movies.searched, ['abc', 'abc']);
    expect(cubit.state, isA<SearchResults>());
  });
}
