import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamification/gamification.dart';
import 'package:gamification_ui/diary/diary_bloc.dart';
import 'package:gamification_ui/diary/diary_screen.dart';
import 'package:gamification_ui/diary/diary_state.dart';
import 'package:gamification_ui/missions/missions_bloc.dart';
import 'package:gamification_ui/missions/missions_screen.dart';
import 'package:gamification_ui/party/watch_party_bloc.dart';
import 'package:gamification_ui/party/watch_party_state.dart';
import 'package:gamification_ui/poster/poster_game_bloc.dart';
import 'package:gamification_ui/poster/poster_game_state.dart';
import 'package:gamification_ui/shelter/shelter_bloc.dart';
import 'package:gamification_ui/shelter/shelter_screen.dart';
import 'package:stats/stats.dart';

import '../../helpers/fake_gamification_repository.dart';

class _NoGoal implements StatsRepository {
  @override
  Future<Result<YearlyGoal>> getGoal(String userId, int year) async =>
      const Failure(AppError.notFound);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
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

const _host = PartyUser(id: 'ana', username: 'ana', displayName: 'Ana');

void main() {
  late FakeGamificationRepository repository;

  setUp(() => repository = FakeGamificationRepository());
  tearDown(() => repository.dispose());

  testWidgets('the starter pack lists the three buckets and asks to choose', (
    tester,
  ) async {
    final cubit = ShelterCubit(
      getShelter: GetPetShelter(repository),
      chooseStarter: ChooseStarterPet(repository),
      pinPet: PinPet(repository),
    )..load();
    addTearDown(cubit.close);
    Pet? chosen;

    await tester.pumpWidget(
      _wrap(
        ShelterScreen(
          cubit: cubit,
          onChooseStarter: (p) => chosen = p,
          onPin: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Escolha seu balde de pipoca'), findsOneWidget);
    expect(find.text('Pipoca salgada'), findsOneWidget);
    await tester.tap(find.text('Pipoca salgada'));
    expect(chosen?.slug, 'pipoca-salgada');
  });

  testWidgets('the shelter shows the pinned bichinho and the locked ones', (
    tester,
  ) async {
    const pinned = Pet(
      slug: 'pipoca-doce',
      rarity: PetRarity.starter,
      unlocked: true,
      level: 3,
      xp: 350,
      levelXp: 300,
      nextLevelXp: 600,
      starter: true,
      pinned: true,
    );
    repository.shelter = const PetShelter(
      starterChosen: true,
      pinned: pinned,
      pets: [
        pinned,
        Pet(slug: 'claquete', unlocked: true, level: 1),
        Pet(
          slug: 'rolo-de-filme',
          rarity: PetRarity.rare,
          progress: 12,
          rule: PetRule(type: PetRuleType.movies, target: 50),
        ),
      ],
    );
    final cubit = ShelterCubit(
      getShelter: GetPetShelter(repository),
      chooseStarter: ChooseStarterPet(repository),
      pinPet: PinPet(repository),
    )..load();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _wrap(
        ShelterScreen(
          cubit: cubit,
          onChooseStarter: (_) {},
          onPin: (p) => cubit.pin(p.slug),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nível 3'), findsWidgets);
    expect(find.text('350 de 600 XP'), findsOneWidget);
    expect(find.text('Assista 50 filmes'), findsOneWidget);
    await tester.tap(find.text('Claquete'));
    await tester.pumpAndSettle();
    expect(repository.pins, ['claquete']);
  });

  testWidgets('missions show their progress and XP', (tester) async {
    repository.missions = MissionWeek(
      weekStart: DateTime(2026, 10, 26),
      weekEnd: DateTime(2026, 11, 1),
      missions: const [
        Mission(
          slug: 'two-movies',
          type: 'movies',
          target: 2,
          progress: 1,
          xp: 40,
        ),
        Mission(
          slug: 'horror',
          type: 'criteria_movies',
          target: 1,
          progress: 1,
          xp: 40,
          completed: true,
        ),
      ],
    );
    final cubit = MissionsCubit(getMissions: GetMissions(repository))..load();
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrap(MissionsScreen(cubit: cubit)));
    await tester.pumpAndSettle();

    expect(find.text('Conclua 2 filmes'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('Cumprida!'), findsOneWidget);
    expect(find.text('+40 XP'), findsNWidgets(2));
  });

  group('Caderninho', () {
    DiaryCubit cubit() => DiaryCubit(
      getDay: GetDiaryDay(repository),
      saveDay: SaveDiaryDay(repository),
      getMonth: GetDiaryMonth(repository),
      getYear: GetDiaryYear(repository),
      getGoal: GetYearlyGoal(_NoGoal()),
      now: () => DateTime(2026, 10, 27, 15),
    );

    test('opening a day does not save it; edits wait for save', () async {
      final diary = cubit();
      addTearDown(diary.close);
      await diary.load();

      diary.setMood(DiaryMood.good);
      for (var i = 0; i < 7; i++) {
        diary.addTask(DiaryTask(description: 'Meta $i'));
      }
      diary.toggleTask(0);
      diary.moveTask(0, 3);
      diary.setNote('Dia bom');

      expect(repository.savedDays, isEmpty);
      final ready = diary.state as DiaryReady;
      expect(ready.dirty, isTrue);
      expect(ready.day.tasks.length, DiaryDay.maxTasks);
      expect(ready.day.tasks[3].description, 'Meta 0');
      expect(ready.day.tasks[3].done, isTrue);

      expect(await diary.save(), isNull);
      expect(repository.savedDays.single.mood, DiaryMood.good);
      expect((diary.state as DiaryReady).dirty, isFalse);
      // Tapping the same mood again clears it.
      diary.setMood(DiaryMood.good);
      expect((diary.state as DiaryReady).day.mood, isNull);
    });

    test('the future is not a day of the Caderninho', () async {
      final diary = cubit();
      addTearDown(diary.close);
      await diary.load();

      await diary.goTo(DateTime(2026, 10, 30));

      expect((diary.state as DiaryReady).day.date, DateTime(2026, 10, 27));
    });

    testWidgets('the screen shows the moods, the goals and the privacy note', (
      tester,
    ) async {
      repository.day = DiaryDay(
        date: DateTime(2026, 10, 27),
        mood: DiaryMood.great,
        tasks: const [
          DiaryTask(category: DiaryCategory.movie, description: 'Ver Ran'),
        ],
        saved: true,
      );
      final diary = cubit()..load();
      addTearDown(diary.close);

      await tester.pumpWidget(
        _wrap(
          DiaryScreen(
            cubit: diary,
            onGoTo: (_) {},
            onPickDay: () {},
            onAddTask: () {},
            onSave: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hoje'), findsOneWidget);
      expect(find.text('Ver Ran'), findsOneWidget);
      expect(find.text('Metas (1 de 6)'), findsOneWidget);
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect((diary.state as DiaryReady).day.tasks.single.done, isTrue);
    });
  });

  test(
    'a watch party reads the room again when the WebSocket says so',
    () async {
      repository.party = WatchParty(
        code: 'ABC234',
        host: _host,
        title: 'Ran',
        startAt: DateTime.utc(2026, 10, 27, 20),
      );
      final party = WatchPartyCubit(actions: WatchPartyActions(repository));
      addTearDown(party.close);

      await party.join('abc234');
      expect(party.state, isA<WatchPartyRoom>());
      repository.party = const WatchParty(
        code: 'ABC234',
        host: _host,
        title: 'Ran agora',
      );
      repository.events.add(const PartyEvent(code: 'ABC234', event: 'message'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect((party.state as WatchPartyRoom).party.title, 'Ran agora');

      repository.events.add(const PartyEvent(code: 'ABC234', event: 'closed'));
      await Future<void>.delayed(Duration.zero);
      expect(party.state, isA<WatchPartyClosed>());
    },
  );

  test('an unknown code stays in the lobby with the error', () async {
    repository.joinResult = const Failure(AppError.notFound);
    final party = WatchPartyCubit(actions: WatchPartyActions(repository));
    addTearDown(party.close);

    await party.join('ZZZZZZ');

    expect((party.state as WatchPartyLobby).error, AppError.notFound);
  });

  test('the countdown uses the clock of the server', () {
    final room = WatchParty(
      code: 'ABC234',
      host: _host,
      title: 'Ran',
      startAt: DateTime.utc(2026, 10, 27, 20, 0, 30),
      clockOffset: const Duration(seconds: 10),
    );

    expect(
      room.remaining(DateTime.utc(2026, 10, 27, 20)),
      const Duration(seconds: 20),
    );
  });

  test(
    'the poster game scores a quick right answer and resets the streak on a wrong one',
    () async {
      const a = GameMovie(movieId: 1, title: 'Ran');
      const b = GameMovie(movieId: 2, title: 'Ikiru');
      repository.round = const PosterRound(movie: a, options: [b, a]);
      final game = PosterGameCubit(getRound: GetPosterRound(repository));
      addTearDown(game.close);

      await game.next();
      game.answer(1, 0);
      final first = game.state as PosterGamePlaying;
      expect(first.correct, isTrue);
      expect(first.score, PosterGameCubit.maxPoints);
      expect(first.streak, 1);

      await game.next();
      game.answer(2, 0.5);
      final second = game.state as PosterGamePlaying;
      expect(second.correct, isFalse);
      expect(second.score, PosterGameCubit.maxPoints);
      expect(second.streak, 0);
      expect(second.rounds, 2);
    },
  );
}
