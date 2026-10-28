import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:maratonas/maratonas.dart';
import 'package:maratonas_ui/detail/maratona_detail_bloc.dart';
import 'package:maratonas_ui/detail/maratona_detail_screen.dart';
import 'package:maratonas_ui/detail/maratona_detail_state.dart';
import 'package:social/feed/activity_card.dart';
import 'package:social_network/social_network.dart';

import '../../helpers/fake_maratonas_repository.dart';
import '../../helpers/fake_social_network_repository.dart';

const _owner = MaratonaUser(id: 'ana-id', username: 'ana', displayName: 'Ana');

Maratona _maratona({MyParticipation? me}) => Maratona(
  id: 7,
  slug: 'terror-70',
  title: 'Terror dos anos 70',
  startsOn: DateTime(2026, 10, 1),
  endsOn: DateTime(2026, 10, 31),
  status: MaratonaStatus.active,
  owner: _owner,
  levels: const [MaratonaLevel(id: 5, name: 'Maratonista', minChallenges: 2)],
  totalChallenges: 2,
  totalParticipants: 3,
  me: me,
);

const _free = MaratonaChallenge(
  id: 12,
  categoryId: 1,
  description: 'Um filme brasileiro',
);

List<MaratonaCategory> _categories({bool done = false}) => [
  MaratonaCategory(
    id: 1,
    name: 'Terror',
    challenges: [
      MaratonaChallenge(
        id: 11,
        categoryId: 1,
        description: 'Um terror dos anos 70',
        type: ChallengeType.criteria,
        criteria: const ChallengeCriteria([
          CriteriaRule(CriteriaField.genre, [27]),
        ]),
        completed: done,
      ),
      _free,
    ],
  ),
];

final _me = MyParticipation(
  levelId: 5,
  queueShelfId: 40,
  completed: 1,
  joinedAt: DateTime(2026, 10, 2),
);

void main() {
  late FakeMaratonasRepository repository;

  MaratonaDetailCubit cubit() => MaratonaDetailCubit(
    slug: 'terror-70',
    getMaratona: GetMaratona(repository),
    getChallenges: GetMaratonaChallenges(repository),
    joinMaratona: JoinMaratona(repository),
    leaveMaratona: LeaveMaratona(repository),
    cancelMaratona: CancelMaratona(repository),
    setChallengeLink: SetChallengeLink(repository),
  );

  setUp(() {
    repository = FakeMaratonasRepository()
      ..maratonaResult = Success(_maratona())
      ..challengesResult = Success(_categories());
    final social = FakeSocialNetworkRepository();
    GetIt.instance
      ..registerFactory(() => GetMaratonaProgress(social))
      ..registerFactory(() => ToggleActivityLove(social));
  });

  tearDown(() => GetIt.instance.reset());

  group('MaratonaDetailCubit', () {
    test('loads the maratona with the challenges', () async {
      final detail = cubit();
      addTearDown(detail.close);

      await detail.load();

      final state = detail.state as MaratonaDetailSuccess;
      expect(state.maratona.slug, 'terror-70');
      expect(state.categories.single.challenges.length, 2);
    });

    test('a wrong password comes back as forbidden', () async {
      final detail = cubit();
      addTearDown(detail.close);
      await detail.load();
      repository.joinResult = const Failure(AppError.forbidden);

      final error = await detail.join(levelId: 5, password: 'errada');

      expect(error, AppError.forbidden);
      expect(repository.calls, contains('join terror-70 5 null errada'));
      expect((detail.state as MaratonaDetailSuccess).busy, false);
    });

    test('joining reloads the challenges with the participation', () async {
      final detail = cubit();
      addTearDown(detail.close);
      await detail.load();
      repository.joinResult = Success(_maratona(me: _me));

      expect(await detail.join(), isNull);

      final state = detail.state as MaratonaDetailSuccess;
      expect(state.maratona.joined, true);
      expect(
        repository.calls.where((c) => c == 'challenges terror-70').length,
        2,
      );
    });

    test('marking a challenge replaces it with its new links', () async {
      final detail = cubit();
      addTearDown(detail.close);
      await detail.load();
      repository.linkResult = Success(
        MaratonaChallenge(
          id: 12,
          categoryId: 1,
          description: 'Um filme brasileiro',
          completed: true,
          links: [
            ChallengeLink(
              challengeId: 12,
              movieId: 30,
              title: 'Cidade de Deus',
              completedAt: DateTime(2026, 10, 5),
            ),
          ],
        ),
      );

      expect(await detail.setLink(12, 30, true), isNull);

      final state = detail.state as MaratonaDetailSuccess;
      expect(state.completed, 1);
      expect(state.categories.single.challenges.last.links.single.movieId, 30);
    });
  });

  group('MaratonaDetailScreen', () {
    Future<void> pump(WidgetTester tester, MaratonaDetailCubit detail) async {
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
            body: MaratonaDetailScreen(
              cubit: detail,
              onJoin: () {},
              onLeave: () {},
              onEdit: () {},
              onCancel: () {},
              onOpenUser: (_) {},
              onOpenMovie: (_, _) {},
              onOpenQueue: (_) {},
              onOpenChallenge: (_) {},
              onOpenLink: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a visitor sees the join button', (tester) async {
      final detail = cubit()..load();
      addTearDown(detail.close);

      await pump(tester, detail);

      expect(find.text('Terror dos anos 70'), findsOneWidget);
      expect(find.text('Acontecendo'), findsOneWidget);
      expect(find.text('3 participantes'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Participar'), findsOneWidget);
    });

    testWidgets('a participant sees the progress and the done challenges', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      repository
        ..maratonaResult = Success(_maratona(me: _me))
        ..challengesResult = Success(_categories(done: true));
      final detail = cubit()..load();
      addTearDown(detail.close);

      await pump(tester, detail);

      expect(find.text('1 de 2 desafios'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Sair'), findsOneWidget);

      await tester.tap(find.text('Desafios'));
      await tester.pumpAndSettle();

      expect(find.text('Um terror dos anos 70'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Concluído')), findsOneWidget);
      expect(find.text('Conclui sozinho'), findsOneWidget);
      semantics.dispose();
    });
  });

  testWidgets('the feed card tells the challenge done and opens the maratona', (
    tester,
  ) async {
    ActivityMaratona? opened;
    final activity = Activity(
      id: 1,
      type: ActivityType.finishedChallenge,
      actor: const SocialUser(
        id: 'ana-id',
        username: 'ana',
        displayName: 'Ana',
      ),
      visibility: ContentVisibility.public,
      movie: const ActivityMovie(id: 10, title: 'Suspiria'),
      maratona: const ActivityMaratona(
        id: 7,
        slug: 'terror-70',
        title: 'Terror dos anos 70',
      ),
      challenge: const ActivityChallenge(
        id: 11,
        description: 'Um terror dos anos 70',
      ),
      createdAt: DateTime.now(),
    );

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
          body: ActivityCard(
            activity: activity,
            onOpenActor: () {},
            onOpenMovie: (_) {},
            onOpenShelf: (_) {},
            onOpenLocadora: (_) {},
            onOpenMaratona: (maratona) => opened = maratona,
            onToggleLove: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('concluiu um desafio em'), findsOneWidget);
    expect(find.text('Um terror dos anos 70'), findsOneWidget);

    await tester.tap(find.text('Terror dos anos 70'));
    expect(opened?.slug, 'terror-70');
  });
}
