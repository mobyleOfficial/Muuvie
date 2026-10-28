import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile_ui/retrospective/retrospective_bloc.dart';
import 'package:profile_ui/retrospective/retrospective_screen.dart';
import 'package:profile_ui/tabs/charts/charts_bloc.dart';
import 'package:profile_ui/tabs/charts/charts_screen.dart';
import 'package:profile_ui/tabs/charts/charts_state.dart';
import 'package:stats/stats.dart';

class _FakeStats implements StatsRepository {
  List<int> years = [2026];
  YearStats? year;
  Result<YearlyGoal> goal = const Failure(AppError.notFound);
  Result<Retrospective> retrospective = const Failure(AppError.notFound);
  final goals = <int?>[];
  final asked = <int>[];

  @override
  Future<Result<List<int>>> getYears(String userId) async => Success(years);

  @override
  Future<Result<YearStats>> getYear(String userId, int year) async {
    asked.add(year);
    return Success(this.year ?? YearStats(year: year));
  }

  @override
  Future<Result<List<CalendarDay>>> getCalendar(
    String userId,
    int year,
  ) async => Success([CalendarDay(date: DateTime(year, 1, 10), sessions: 2)]);

  @override
  Future<Result<List<RetrospectiveYear>>> getRetrospectiveYears() async =>
      const Success([]);

  @override
  Future<Result<Retrospective>> getRetrospective(int year) async =>
      retrospective;

  @override
  Future<Result<YearlyGoal>> getGoal(String userId, int year) async => goal;

  @override
  Future<Result<YearlyGoal>> setGoal(int year, int targetMovies) async {
    goals.add(targetMovies);
    return Success(
      YearlyGoal(year: year, targetMovies: targetMovies, watched: 3),
    );
  }

  @override
  Future<Result<void>> removeGoal(int year) async {
    goals.add(null);
    return const Success(null);
  }
}

Widget _wrap(Widget child) => MaterialApp(
  locale: const Locale('pt'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  late _FakeStats repository;

  ChartsCubit cubit() => ChartsCubit(
    userId: 'me',
    getYears: GetStatsYears(repository),
    getYearStats: GetYearStats(repository),
    getCalendar: GetStatsCalendar(repository),
    getGoal: GetYearlyGoal(repository),
    setGoal: SetYearlyGoal(repository),
    now: () => DateTime(2026, 10, 27),
  );

  setUp(() {
    repository = _FakeStats()
      ..year = YearStats(
        year: 2026,
        movies: 3,
        sessions: 5,
        minutes: 442,
        months: [
          for (var m = 1; m <= 12; m++)
            MonthStat(month: m, movies: m == 3 ? 2 : 0),
        ],
        genres: const [StatBucket(key: '18', label: 'Drama', movies: 2)],
        countries: const [StatBucket(key: 'JP', movies: 2)],
        directors: const [
          StatBucket(key: '5026', label: 'Akira Kurosawa', movies: 2),
        ],
        emotions: const [StatBucket(key: 'moved', movies: 2)],
      );
  });

  testWidgets('shows the totals, the breakdowns and opens the retrospective', (
    tester,
  ) async {
    final charts = cubit()..load();
    addTearDown(charts.close);
    int? opened;

    await tester.pumpWidget(
      _wrap(
        ChartsScreen(
          cubit: charts,
          isSelf: true,
          onOpenRetrospective: (y) => opened = y,
          onEditGoal: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('horas na frente da tela'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('Drama'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Akira Kurosawa'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Akira Kurosawa'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Definir meta'),
      -300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Definir meta'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Ver a retrospectiva de 2026'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Ver a retrospectiva de 2026'));
    expect(opened, 2026);
  });

  testWidgets(
    'the latest year with sessions opens first and others load on tap',
    (tester) async {
      repository.years = [2024];
      final charts = cubit()..load();
      addTearDown(charts.close);

      await tester.pumpWidget(_wrap(ChartsScreen(cubit: charts)));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, '2026'));
      await tester.pumpAndSettle();

      expect(repository.asked, [2024, 2026]);
      expect(find.text('Definir meta'), findsNothing);
    },
  );

  test('setting and removing the goal', () async {
    final charts = cubit();
    addTearDown(charts.close);
    await charts.load();

    await charts.setGoal(50);
    expect((charts.state as ChartsSuccess).goal?.targetMovies, 50);
    await charts.setGoal(null);
    expect((charts.state as ChartsSuccess).goal, isNull);
    expect(repository.goals, [50, null]);
  });

  testWidgets('the retrospective walks through the stories', (tester) async {
    repository.retrospective = const Success(
      Retrospective(
        year: 2026,
        movies: 3,
        minutes: 380,
        topGenres: [StatBucket(key: '18', label: 'Drama', movies: 2)],
        emotion: 'moved',
        favorite: RetrospectiveMovie(
          movieId: 10,
          title: 'Rashomon',
          year: 1950,
        ),
      ),
    );
    final story = RetrospectiveCubit(
      year: 2026,
      getRetrospective: GetRetrospective(repository),
    )..load();
    addTearDown(story.close);

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
        home: RetrospectiveScreen(
          cubit: story,
          onClose: () {},
          onShare: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Seu ano no cinema'), findsOneWidget);
    await tester.tapAt(const Offset(700, 400));
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);
    expect(find.text('filmes'), findsOneWidget);
  });
}
