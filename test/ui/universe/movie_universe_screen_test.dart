import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/movies.dart';
import 'package:shelves/shelves.dart';
import 'package:universe_ui/universe_ui.dart';
import 'package:watch_logs/watch_logs.dart';

/// The list of the universe and its filters, as a screen reader user gets
/// them: the map itself is a canvas, so the list is where every planet and
/// action has to be reachable (research/features/movie-universe/roadmap.md).

class _FakeMoviesRepository implements MoviesRepository {
  @override
  Future<Result<List<SimilarMovie>>> getSimilarMovies({
    required int movieId,
  }) async => const Success([
    SimilarMovie(
      movie: Movie(
        id: 8,
        title: 'Inferno',
        posterPath: '',
        info: MovieInfo(
          overview: '',
          backdropPath: '',
          releaseDate: '1980-02-07',
        ),
        me: MovieListState(status: WatchStatus.watched),
      ),
      score: 0.8,
      sharedGenres: ['Terror'],
      sharedKeywords: ['bruxa'],
      genres: ['Terror'],
    ),
    SimilarMovie(
      movie: Movie(
        id: 9,
        title: 'Tenebre',
        posterPath: '',
        info: MovieInfo(
          overview: '',
          backdropPath: '',
          releaseDate: '1982-10-28',
        ),
      ),
      score: 0.5,
      genres: ['Mistério'],
    ),
  ]);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _UnusedShelvesRepository implements ShelvesRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _UnusedWatchLogsRepository implements WatchLogsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

Future<MovieUniverseCubit> _pumpList(
  WidgetTester tester, {
  required ThemeData theme,
}) async {
  final cubit = MovieUniverseCubit(
    getSimilarMovies: GetSimilarMovies(_FakeMoviesRepository()),
    addMovieToWatchlist: AddMovieToWatchlist(_UnusedShelvesRepository()),
    getMovieWatchState: GetMovieWatchState(_UnusedWatchLogsRepository()),
    origin: const Movie(id: 7, title: 'Suspiria', posterPath: ''),
    prefetchedPlanets: 0,
  );
  await cubit.load(startAsList: true);
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
      theme: theme,
      home: MovieUniverseScreen(
        cubit: cubit,
        onOpenMovie: (_) {},
        onAddToWatchlist: (_) {},
        onAddToShelves: (_) {},
      ),
    ),
  );
  await tester.pumpAndSettle();
  addTearDown(cubit.close);
  return cubit;
}

Future<void> _expectAccessible(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  for (final (name, theme) in [
    ('light', MuuvieTheme.light),
    ('dark', MuuvieTheme.dark),
  ]) {
    testWidgets('the list says the state and the reason of each planet '
        '($name)', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpList(tester, theme: theme);

      expect(find.text('Já assisti'), findsOneWidget);
      expect(find.text('Em comum: Terror, bruxa'), findsOneWidget);
      expect(find.byTooltip('Mais ações para Inferno'), findsOneWidget);
      expect(find.byTooltip('Viajar até Tenebre'), findsOneWidget);
      await _expectAccessible(tester);
      semantics.dispose();
    });

    testWidgets('the filters are reachable and labeled ($name)', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpList(tester, theme: theme);

      await tester.tap(find.byTooltip('Filtrar planetas'));
      await tester.pumpAndSettle();
      expect(find.text('Anos 1980'), findsOneWidget);
      expect(find.text('Mistério'), findsOneWidget);
      await _expectAccessible(tester);

      await tester.tap(find.text('Só os que não assisti'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10)); // closes the sheet
      await tester.pumpAndSettle();

      expect(find.text('1 de 2 planetas combinam'), findsOneWidget);
      expect(find.text('Inferno'), findsNothing);
      expect(find.text('Tenebre'), findsOneWidget);
      await _expectAccessible(tester);
      semantics.dispose();
    });
  }
}
