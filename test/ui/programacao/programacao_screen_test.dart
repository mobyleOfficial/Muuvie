import 'package:auth/auth.dart';
import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:cineclubes/cineclubes.dart';
import 'package:maratonas/maratonas.dart';
import 'package:programacao/cineclubes/cineclube_list.dart';
import 'package:programacao/maratonas/maratona_list.dart';
import 'package:programacao/programacao.dart';

import '../../helpers/fake_cineclubes_repository.dart';
import '../../helpers/fake_maratonas_repository.dart';

class _LoggedOutAuthRepository implements AuthRepository {
  @override
  Future<Result<bool>> isUserAuthenticated() async => const Success(false);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeMaratonasRepository repository;
  late FakeCineClubesRepository cineclubes;

  setUp(() {
    repository = FakeMaratonasRepository()
      ..pageResult = Success(
        MaratonaPage(
          maratonas: [
            MaratonaSummary(
              id: 1,
              slug: 'terror-70',
              title: 'Terror dos anos 70',
              startsOn: DateTime(2026, 10, 1),
              endsOn: DateTime(2026, 10, 31),
              status: MaratonaStatus.active,
              owner: const MaratonaUser(id: 'ana', username: 'ana'),
              totalChallenges: 3,
              totalParticipants: 2,
              joined: true,
            ),
          ],
        ),
      );
    GetIt.instance.registerFactory<GetMaratonas>(
      () => GetMaratonas(repository),
    );
    cineclubes = FakeCineClubesRepository()
      ..pageResult = Success(
        CineClubePage(
          cineclubes: [
            CineClubeSummary(
              id: 3,
              slug: 'kurosawa',
              title: 'Kurosawa de outubro',
              status: CineClubeStatus.active,
              owner: const CineClubeUser(id: 'ana', username: 'ana'),
              movie: const CineClubeMovie(id: 10, title: 'Rashomon'),
              startsOn: DateTime(2026, 10, 5),
              endsOn: DateTime(2026, 10, 12),
              debateOn: DateTime(2026, 10, 12),
            ),
          ],
        ),
      );
    GetIt.instance.registerFactory<GetCineClubes>(
      () => GetCineClubes(cineclubes),
    );
  });

  tearDown(() => GetIt.instance.reset());

  Widget wrap(
    ProgramacaoCubit cubit, {
    ValueChanged<MaratonaSummary>? onOpen,
  }) => MaterialApp(
    locale: const Locale('pt'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ProgramacaoScreen(
        cubit: cubit,
        maratonaListKey: GlobalKey<MaratonaListViewState>(),
        cineclubeListKey: GlobalKey<CineClubeListViewState>(),
        onOpenCineClube: (_) {},
        onCreateCineClube: () {},
        onOpenMaratona: onOpen ?? (_) {},
        onCreateMaratona: () {},
        onParticipatingChanged: cubit.setParticipatingOnly,
      ),
    ),
  );

  testWidgets('lists the maratonas and the CineClubes', (tester) async {
    final cubit = ProgramacaoCubit()..load();
    addTearDown(cubit.close);
    MaratonaSummary? opened;

    await tester.pumpWidget(wrap(cubit, onOpen: (m) => opened = m));
    await tester.pumpAndSettle();

    expect(find.text('Maratonas'), findsOneWidget);
    expect(find.text('CineClubes'), findsOneWidget);
    expect(find.text('Participando'), findsWidgets);
    expect(find.text('Terror dos anos 70'), findsOneWidget);
    expect(find.text('Criar maratona'), findsOneWidget);

    await tester.tap(find.text('Terror dos anos 70'));
    expect(opened?.slug, 'terror-70');

    await tester.tap(find.text('CineClubes'));
    await tester.pumpAndSettle();
    expect(find.text('Kurosawa de outubro'), findsOneWidget);
    expect(find.text('Criar CineClube'), findsOneWidget);
    expect(cineclubes.filters, isNotEmpty);
  });

  testWidgets('Participando narrows the list to what the user joined', (
    tester,
  ) async {
    final cubit = ProgramacaoCubit()..load();
    addTearDown(cubit.close);

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();
    final chip = find.widgetWithText(FilterChip, 'Participando');
    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect((cubit.state as ProgramacaoSuccess).participatingOnly, true);
    expect(tester.widget<FilterChip>(chip).selected, true);
    expect(repository.filters.last.participant, 'me');
  });

  testWidgets('a filter chip reloads the list with it', (tester) async {
    final cubit = ProgramacaoCubit()..load();
    addTearDown(cubit.close);

    await tester.pumpWidget(wrap(cubit));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Curadoria'));
    await tester.pumpAndSettle();

    expect(repository.filters.last.trusted, true);
  });

  testWidgets('Criadas por mim asks a logged out user to log in', (
    tester,
  ) async {
    GetIt.instance.registerFactory<IsUserAuthenticated>(
      () => IsUserAuthenticated(_LoggedOutAuthRepository()),
    );
    AuthGate.configure(loginRoute: const NamedRoute('Login'));
    final cubit = ProgramacaoCubit()..load();
    addTearDown(cubit.close);
    final router = RootStackRouter.build(
      routes: [
        NamedRouteDef(
          name: 'Home',
          path: '/',
          initial: true,
          builder: (context, _) => Scaffold(
            body: ProgramacaoScreen(
              cubit: cubit,
              maratonaListKey: GlobalKey<MaratonaListViewState>(),
              cineclubeListKey: GlobalKey<CineClubeListViewState>(),
              onOpenCineClube: (_) {},
              onCreateCineClube: () {},
              onOpenMaratona: (_) {},
              onCreateMaratona: () {},
              onParticipatingChanged: cubit.setParticipatingOnly,
            ),
          ),
        ),
        NamedRouteDef(
          name: 'Login',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.router.pop(false),
              child: const Text('login modal'),
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router.config(),
        locale: const Locale('pt'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    final chip = find.widgetWithText(FilterChip, 'Criadas por mim');
    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect(find.text('login modal'), findsOneWidget);

    await tester.tap(find.text('login modal'));
    await tester.pumpAndSettle();

    expect(tester.widget<FilterChip>(chip).selected, false);
    expect(repository.filters.last.mine, isNot(true));
  });
}
