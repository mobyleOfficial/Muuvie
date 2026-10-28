import 'package:cineclubes/cineclubes.dart';
import 'package:cineclubes_ui/detail/cineclube_detail_bloc.dart';
import 'package:cineclubes_ui/detail/cineclube_detail_screen.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/fake_cineclubes_repository.dart';

const _owner = CineClubeUser(id: 'ana-id', username: 'ana', displayName: 'Ana');
const _bia = CineClubeUser(id: 'bia-id', username: 'bia', displayName: 'Bia');

CineClube _cineclube({CineClubeMembership? me, bool cycle = false}) =>
    CineClube(
      id: 3,
      slug: 'kurosawa',
      title: 'Kurosawa de outubro',
      status: CineClubeStatus.active,
      isCycle: cycle,
      startsOn: DateTime(2026, 10, 5),
      endsOn: DateTime(2026, 10, 18),
      owner: _owner,
      sessions: [
        CineClubeSession(
          id: 1,
          movie: const CineClubeMovie(id: 10, title: 'Rashomon', year: 1950),
          startsOn: DateTime(2026, 10, 5),
          endsOn: DateTime(2026, 10, 11),
          debateOn: DateTime(2099, 10, 11),
        ),
        if (cycle)
          CineClubeSession(
            id: 2,
            movie: const CineClubeMovie(id: 11, title: 'Ran'),
            startsOn: DateTime(2026, 10, 12),
            endsOn: DateTime(2026, 10, 18),
            debateOn: DateTime(2099, 10, 18),
          ),
      ],
      currentSessionId: 1,
      totalParticipants: 2,
      watchProviders: const [WatchProviderInfo(name: 'Mubi')],
      me: me,
    );

void main() {
  late FakeCineClubesRepository repository;

  CineClubeDetailCubit cubit() => CineClubeDetailCubit(
    slug: 'kurosawa',
    getCineClube: GetCineClube(repository),
    joinCineClube: JoinCineClube(repository),
    leaveCineClube: LeaveCineClube(repository),
    cancelCineClube: CancelCineClube(repository),
  );

  setUp(() {
    repository = FakeCineClubesRepository()
      ..cineclubeResult = Success(_cineclube())
      ..progressResult = Success(
        CineClubeLogPage(
          logs: [
            CineClubeLog(
              id: 50,
              user: _bia,
              sessionId: 1,
              watchedOn: DateTime(2026, 10, 6),
              completed: true,
              hasSpoiler: true,
              hidden: true,
              createdAt: DateTime(2026, 10, 6),
            ),
          ],
        ),
      )
      ..participantsResult = Success(
        ParticipantPage(
          participants: [
            CineClubeParticipant(
              user: _bia,
              progress: SessionProgress.completed,
              joinedAt: DateTime(2026, 10, 2),
            ),
          ],
        ),
      );
    GetIt.instance
      ..registerFactory(() => GetCineClubeProgress(repository))
      ..registerFactory(() => GetCineClubeParticipants(repository));
  });

  tearDown(() => GetIt.instance.reset());

  Widget wrap(CineClubeDetailCubit cubit, {VoidCallback? onJoin}) =>
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
          body: CineClubeDetailScreen(
            cubit: cubit,
            onJoin: onJoin ?? () {},
            onLeave: () {},
            onEdit: () {},
            onCancel: () {},
            onOpenUser: (_) {},
            onOpenMovie: (_) {},
            onOpenLink: (_) {},
          ),
        ),
      );

  testWidgets('shows the movie, where to watch it and the join button', (
    tester,
  ) async {
    final detail = cubit()..load();
    addTearDown(detail.close);
    var joined = false;

    await tester.pumpWidget(wrap(detail, onJoin: () => joined = true));
    await tester.pumpAndSettle();

    expect(find.text('Kurosawa de outubro'), findsOneWidget);
    expect(find.text('Rashomon'), findsOneWidget);
    expect(find.text('Onde assistir'), findsOneWidget);
    expect(find.text('Mubi'), findsOneWidget);
    await tester.tap(find.text('Entrar no CineClube'));
    expect(joined, isTrue);
  });

  testWidgets('a hidden log shows the spoiler notice instead of the comment', (
    tester,
  ) async {
    final detail = cubit()..load();
    addTearDown(detail.close);

    await tester.pumpWidget(wrap(detail));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Progresso'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Bia', findRichText: true), findsOneWidget);
    expect(
      find.text(
        'Comentário escondido até você terminar o filme ou chegar o dia do debate.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('participants filter by progress', (tester) async {
    final detail = cubit()..load();
    addTearDown(detail.close);

    await tester.pumpWidget(wrap(detail));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Participantes'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Assistiu'));
    await tester.pumpAndSettle();

    expect(repository.progressFilters.last, SessionProgress.completed);
  });

  testWidgets('a cycle lists its movies and picking one changes the tabs', (
    tester,
  ) async {
    repository.cineclubeResult = Success(
      _cineclube(
        cycle: true,
        me: CineClubeMembership(
          joinedAt: DateTime(2026, 10, 2),
          progress: SessionProgress.watching,
        ),
      ),
    );
    final detail = cubit()..load();
    addTearDown(detail.close);

    await tester.pumpWidget(wrap(detail));
    await tester.pumpAndSettle();

    expect(find.text('Assistindo · 0 de 2 filmes'), findsOneWidget);
    expect(find.text('Sair'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, '2. Ran'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Progresso'));
    await tester.pumpAndSettle();

    expect(repository.progressSessions.last, 2);
  });

  testWidgets('joining with a password failure keeps the user out', (
    tester,
  ) async {
    repository.joinResult = const Failure(AppError.forbidden);
    final detail = cubit();
    addTearDown(detail.close);
    await detail.load();

    final error = await detail.join(password: 'errada');

    expect(error, AppError.forbidden);
    expect(repository.joins.single, 'errada');
  });
}
