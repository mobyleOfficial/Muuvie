import 'dart:convert';
import 'dart:io';

import 'package:auth/auth.dart' show Logout, AuthRepository;
import 'package:cineclubes/cineclubes.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maratonas/maratonas.dart';
import 'package:onboarding/onboarding.dart';
import 'package:onboarding_ui/onboarding_bloc.dart';
import 'package:onboarding_ui/onboarding_screen.dart';
import 'package:onboarding_ui/onboarding_state.dart';
import 'package:profile_ui/settings/settings_bloc.dart';
import 'package:profile_ui/settings/settings_state.dart';
import 'package:social_network/social_network.dart';

import '../../helpers/fake_cineclubes_repository.dart';
import '../../helpers/golden.dart';
import '../../helpers/fake_maratonas_repository.dart';
import '../../helpers/fake_push_messaging.dart';
import '../../helpers/fake_social_network_repository.dart';

class _MemoryOnboarding implements OnboardingRepository {
  bool seen = false;

  @override
  Result<bool> hasSeen() => Success(seen);

  @override
  Result<void> markSeen() {
    seen = true;
    return const Success(null);
  }

  @override
  Result<void> reset() {
    seen = false;
    return const Success(null);
  }
}

class _FakeAuth implements AuthRepository {
  var loggedOut = false;

  @override
  Future<Result<void>> logout() async {
    loggedOut = true;
    return const Success(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _MemoryOnboarding onboarding;
  late FakeMaratonasRepository maratonas;
  late FakeCineClubesRepository cineclubes;

  setUpAll(useTolerantGoldens);

  setUp(() {
    onboarding = _MemoryOnboarding();
    maratonas = FakeMaratonasRepository()
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
            ),
          ],
        ),
      );
    cineclubes = FakeCineClubesRepository();
  });

  OnboardingCubit cubit() => OnboardingCubit(
    getMaratonas: GetMaratonas(maratonas),
    getCineClubes: GetCineClubes(cineclubes),
    markSeen: MarkOnboardingSeen(onboarding),
  );

  test('the introduction shows once and comes back after a reset', () async {
    expect(
      (await ShouldShowOnboarding(onboarding)() as Success<bool>).data,
      isTrue,
    );
    final intro = cubit();
    addTearDown(intro.close);

    await intro.finish();
    expect(
      (await ShouldShowOnboarding(onboarding)() as Success<bool>).data,
      isFalse,
    );
    await ResetOnboarding(onboarding)();
    expect(
      (await ShouldShowOnboarding(onboarding)() as Success<bool>).data,
      isTrue,
    );
  });

  test('suggestions are only the open maratonas and CineClubes', () async {
    final intro = cubit();
    addTearDown(intro.close);

    await intro.load();

    expect(
      (intro.state as OnboardingSuccess).maratonas.single.slug,
      'terror-70',
    );
    expect(maratonas.filters.single.open, isTrue);
    expect(cineclubes.filters.single.open, isTrue);
  });

  testWidgets('the panels lead to the Filmow import and the suggestions', (
    tester,
  ) async {
    final intro = cubit()..load();
    addTearDown(intro.close);
    var imported = false;
    MaratonaSummary? opened;

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
        home: OnboardingScreen(
          cubit: intro,
          onFinish: () {},
          onImport: () => imported = true,
          onOpenMaratona: (m) => opened = m,
          onOpenCineClube: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('O Muuvie é uma maratona de filmes'), findsOneWidget);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Importar do Filmow'));
    expect(imported, isTrue);

    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Começar'), findsOneWidget);
    await tester.tap(find.text('Terror dos anos 70'));
    expect(opened?.slug, 'terror-70');
  });

  for (final brightness in Brightness.values) {
    testWidgets('the first panel shows the mascot (${brightness.name})', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final intro = cubit()..load();
      addTearDown(intro.close);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: brightness == Brightness.light
              ? MuuvieTheme.light
              : MuuvieTheme.dark,
          locale: const Locale('pt'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: OnboardingScreen(
            cubit: intro,
            onFinish: () {},
            onImport: () {},
            onOpenMaratona: (_) {},
            onOpenCineClube: (_) {},
          ),
        ),
      );
      // SVGs are decoded off the test clock; let the loads finish.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MuuvieIllustrationView), findsWidgets);
      await expectLater(
        find.byType(OnboardingScreen),
        matchesGoldenFile('goldens/onboarding_${brightness.name}.png'),
      );
    });
  }

  test('settings save the push preferences and log out', () async {
    final social = FakeSocialNetworkRepository();
    final auth = _FakeAuth();
    final settings = SettingsCubit(
      getPrefs: GetNotificationPrefs(social),
      savePrefs: SaveNotificationPrefs(social),
      resetOnboarding: ResetOnboarding(onboarding),
      logout: Logout(auth),
    );
    addTearDown(settings.close);

    await settings.load();
    await settings.setPrefs(const NotificationPrefs(loves: false));
    await settings.logout();

    expect(social.savedPrefs.single.loves, isFalse);
    expect(auth.loggedOut, isTrue);
    expect(settings.state, isA<SettingsLoggedOut>());
  });

  test('settings warn when push is blocked and register once allowed', () async {
    final social = FakeSocialNetworkRepository();
    final push = FakePushMessaging();
    final settings = SettingsCubit(
      getPrefs: GetNotificationPrefs(social),
      savePrefs: SaveNotificationPrefs(social),
      resetOnboarding: ResetOnboarding(onboarding),
      logout: Logout(_FakeAuth()),
      push: push,
      registerPushDevice: RegisterPushDevice(social, push),
    );
    addTearDown(settings.close);
    addTearDown(push.dispose);

    await settings.load();
    expect((settings.state as SettingsReady).pushBlocked, isTrue);

    await settings.allowPush();

    expect((settings.state as SettingsReady).pushBlocked, isFalse);
    expect(social.calls.single, startsWith('registerDevice:android:token-1'));
  });

  test('every string exists in the three languages (F11.4)', () {
    Map<String, dynamic> read(String lang) =>
        jsonDecode(File('ui/common/lib/l10n/app_$lang.arb').readAsStringSync())
            as Map<String, dynamic>;
    Set<String> keys(Map<String, dynamic> arb) =>
        arb.keys.where((key) => !key.startsWith('@')).toSet();
    final en = keys(read('en'));

    for (final lang in ['pt', 'es']) {
      final other = keys(read(lang));
      expect(en.difference(other), isEmpty, reason: 'missing in $lang');
      expect(other.difference(en), isEmpty, reason: 'only in $lang');
    }
  });

  test('Portuguese plurals spell out zero, which pt reads as "one"', () {
    final pt =
        jsonDecode(File('ui/common/lib/l10n/app_pt.arb').readAsStringSync())
            as Map<String, dynamic>;
    final missing = [
      for (final MapEntry(:key, :value) in pt.entries)
        if (value is String && value.contains('=1{') && !value.contains('=0{'))
          key,
    ];

    expect(missing, isEmpty);
  });
}
