import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watch_logs/watch_logs.dart';
import 'package:watch_logs_ui/log_session/log_session_cubit.dart';
import 'package:watch_logs_ui/movie_panel/movie_watch_cubit.dart';
import 'package:watch_logs_ui/rating/rate_movie_cubit.dart';
import 'package:watch_logs_ui/rating/rate_movie_screen.dart';

WatchLog _log({int id = 1, WatchMode mode = WatchMode.watched}) => WatchLog(
  id: id,
  userId: 'ana',
  movieId: 10,
  watchedOn: DateTime(2026, 10, 1),
  cycle: 1,
  mode: mode,
  minutesWatched: 40,
  completed: mode == WatchMode.watched,
  emotions: const [Emotion.joy],
  createdAt: DateTime(2026, 10, 1),
);

class _FakeRepository implements WatchLogsRepository {
  final drafts = <WatchLogDraft>[];
  final ratings = <RatingDraft>[];
  Result<MovieUserState> state = const Success(MovieUserState());
  int stateLoads = 0;

  @override
  Future<Result<MovieUserState>> getMovieState(int movieId) async {
    stateLoads++;
    return state;
  }

  @override
  Future<Result<WatchLog>> logSession({
    required int movieId,
    required WatchLogDraft draft,
  }) async {
    drafts.add(draft);
    return Success(_log());
  }

  @override
  Future<Result<WatchLog>> updateLog(int logId, WatchLogDraft draft) async {
    drafts.add(draft);
    return Success(_log(id: logId));
  }

  @override
  Future<Result<MovieRating>> rate(int movieId, RatingDraft draft) async {
    ratings.add(draft);
    return Success(MovieRating(id: 1, rating: draft.rating));
  }

  @override
  Future<Result<List<Emotion>>> getRecentEmotions() async =>
      const Success([Emotion.fear]);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  late _FakeRepository repository;

  setUp(() => repository = _FakeRepository());

  Widget wrap(Widget child, {Locale locale = const Locale('en')}) =>
      MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      );

  RateMovieCubit rateCubit({MovieRating? current, bool watched = false}) =>
      RateMovieCubit(
        movieId: 10,
        current: current,
        alreadyWatched: watched,
        setMovieRating: SetMovieRating(repository),
        removeMovieRating: RemoveMovieRating(repository),
        getRecentEmotions: GetRecentEmotions(repository),
      );

  testWidgets('the form lists the labels and hides the session for on hold', (
    tester,
  ) async {
    // Tall enough for the seven labels and the switches below them.
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final cubit = rateCubit();
    addTearDown(cubit.close);
    await tester.pumpWidget(
      wrap(
        RateMovieScreen(
          cubit: cubit,
          movieTitle: 'Casablanca',
          canRemove: false,
          onSave: () {},
          onRemove: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Favorite'), findsOneWidget);
    expect(find.text('On hold'), findsOneWidget);
    expect(find.text('Create a 100% session'), findsOneWidget);

    await tester.tap(find.text('On hold'));
    await tester.pumpAndSettle();
    expect(cubit.state.rating, Rating.onHold);
    expect(find.text('Create a 100% session'), findsNothing);
  });

  test(
    'rating a movie not watched yet logs the session with the emotions',
    () async {
      final cubit = rateCubit();
      addTearDown(cubit.close);
      expect(cubit.state.createLog, isTrue);

      cubit.setRating(Rating.liked);
      cubit.setEmotions({Emotion.joy});
      cubit.setVisibility(ContentVisibility.secret);
      await cubit.save();

      final draft = repository.ratings.single;
      expect(draft.rating, Rating.liked);
      expect(draft.createLog, isTrue);
      expect(draft.emotions, [Emotion.joy]);
      expect(draft.visibility, ContentVisibility.secret);
    },
  );

  test('abandoning never logs the session, even with the switch on', () async {
    final cubit = rateCubit();
    addTearDown(cubit.close);

    cubit.setEmotions({Emotion.joy});
    cubit.setRating(Rating.abandoned);
    await cubit.save();

    final draft = repository.ratings.single;
    expect(draft.rating, Rating.abandoned);
    expect(draft.createLog, isFalse);
    expect(draft.emotions, isEmpty);
  });

  test('re-rating a watched movie does not log again by default', () async {
    final cubit = rateCubit(
      current: const MovieRating(id: 1, rating: Rating.notForMe),
      watched: true,
    );
    addTearDown(cubit.close);

    cubit.setEmotions({Emotion.joy});
    await cubit.save();

    final draft = repository.ratings.single;
    expect(draft.rating, Rating.notForMe);
    expect(draft.createLog, isFalse);
    expect(draft.emotions, isEmpty);
  });

  test(
    'the session form caps minutes at the runtime and edits keep the log',
    () async {
      final cubit = LogSessionCubit(
        movieId: 10,
        movieTitle: 'Casablanca',
        runtime: 102,
        existing: _log(id: 7, mode: WatchMode.minutes),
        logWatchSession: LogWatchSession(repository),
        updateWatchLog: UpdateWatchLog(repository),
        getRecentEmotions: GetRecentEmotions(repository),
      );
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.mode, WatchMode.minutes);
      expect(cubit.state.minutes, 40);
      expect(cubit.state.emotions, {Emotion.joy});
      expect(cubit.state.recentEmotions, [Emotion.fear]);

      cubit.setMinutes(500);
      expect(cubit.state.minutes, 102);

      final saved = await cubit.save();
      expect(saved?.id, 7);
      expect(repository.drafts.single.minutesWatched, 102);
      expect(repository.drafts.single.percent, isNull);
    },
  );

  MovieWatchCubit panelCubit() => MovieWatchCubit(
    movieId: 10,
    getMovieWatchState: GetMovieWatchState(repository),
    logWatchSession: LogWatchSession(repository),
    startRewatch: StartRewatch(repository),
    setWatchingNow: SetWatchingNow(repository),
  );

  test('signed out, the panel is a guest', () async {
    repository.state = const Failure(AppError.unauthorized);
    final cubit = panelCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state, isA<MovieWatchGuest>());
  });

  test('one-tap Ja assisti logs today and reloads the state', () async {
    final cubit = panelCubit();
    addTearDown(cubit.close);
    await Future<void>.delayed(Duration.zero);
    repository.state = const Success(
      MovieUserState(status: WatchStatus.watched),
    );

    final ok = await cubit.markWatched(today: DateTime(2026, 10, 26, 22, 30));

    expect(ok, isTrue);
    final draft = repository.drafts.single;
    expect(draft.watchedOn, DateTime(2026, 10, 26));
    expect(draft.mode, WatchMode.watched);
    expect(
      (cubit.state as MovieWatchReady).userState.status,
      WatchStatus.watched,
    );
  });
}
