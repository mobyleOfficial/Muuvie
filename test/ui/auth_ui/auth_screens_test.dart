import 'package:auth_domain/domain.dart';
import 'package:auth_ui/choose_nickname/choose_nickname_cubit.dart';
import 'package:auth_ui/choose_nickname/choose_nickname_screen.dart';
import 'package:auth_ui/choose_nickname/choose_nickname_state.dart';
import 'package:auth_ui/login/login_cubit.dart';
import 'package:auth_ui/login/login_screen.dart';
import 'package:auth_ui/login/login_state.dart';
import 'package:auth_ui/widgets/auth_text_field.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/golden.dart';

class _FakeAuthRepository implements AuthRepository {
  Result<SignInOutcome> loginResult = const Failure(AppError.unauthorized);
  Result<bool> nicknameResult = const Success(true);
  OAuthProvider? lastProvider;

  @override
  Future<Result<SignInOutcome>> login(OAuthProvider provider) async {
    lastProvider = provider;
    return loginResult;
  }

  @override
  Future<Result<void>> chooseNickname(String nickname) async =>
      const Success(null);

  @override
  Future<Result<bool>> isUserAuthenticated() async => const Success(false);

  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Stream<void> observeSessionEnded() => const Stream.empty();

  @override
  Future<Result<bool>> checkNicknameAvailability(String nickname) async =>
      nicknameResult;
}

Widget _app(Widget child, {Brightness brightness = Brightness.light}) =>
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
      home: Scaffold(body: SafeArea(child: child)),
    );

const _bothProviders = [OAuthProvider.apple, OAuthProvider.google];

Widget _login(
  LoginCubit cubit, {
  List<OAuthProvider> providers = _bothProviders,
  Brightness brightness = Brightness.light,
}) => _app(
  BlocProvider.value(
    value: cubit,
    child: BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) =>
          LoginScreen(state: state, providers: providers),
    ),
  ),
  brightness: brightness,
);

Widget _chooseNickname(
  ChooseNicknameCubit cubit, {
  String? suggestedNickname,
  Brightness brightness = Brightness.light,
}) => _app(
  BlocProvider.value(
    value: cubit,
    child: BlocBuilder<ChooseNicknameCubit, ChooseNicknameState>(
      builder: (context, state) => ChooseNicknameScreen(
        state: state,
        suggestedNickname: suggestedNickname,
      ),
    ),
  ),
  brightness: brightness,
);

void main() {
  late _FakeAuthRepository repository;

  setUpAll(useTolerantGoldens);

  setUp(() => repository = _FakeAuthRepository());

  LoginCubit loginCubit() => LoginCubit(
    loginUseCase: Login(repository),
    isUserAuthenticatedUseCase: IsUserAuthenticated(repository),
  );

  ChooseNicknameCubit chooseNicknameCubit() => ChooseNicknameCubit(
    chooseNickname: ChooseNickname(repository),
    checkNicknameAvailability: CheckNicknameAvailability(repository),
  );

  void usePhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  /// SVGs are decoded off the test clock; let the loads finish, then repaint.
  Future<void> settleSvgs(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.descendant(
    of: find.ancestor(
      of: find.text(label),
      matching: find.byType(AuthTextField),
    ),
    matching: find.byType(TextField),
  );

  group('LoginScreen', () {
    for (final brightness in Brightness.values) {
      testWidgets('golden (${brightness.name})', (tester) async {
        usePhoneSize(tester);
        await tester.pumpWidget(_login(loginCubit(), brightness: brightness));
        await settleSvgs(tester);

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/login_${brightness.name}.png'),
        );
      });
    }

    testWidgets('offers only the given providers, no e-mail or password', (
      tester,
    ) async {
      usePhoneSize(tester);
      await tester.pumpWidget(
        _login(loginCubit(), providers: const [OAuthProvider.google]),
      );

      expect(find.text('Continuar com Google'), findsOneWidget);
      expect(find.text('Continuar com Apple'), findsNothing);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('tapping a provider signs in with it', (tester) async {
      usePhoneSize(tester);
      await tester.pumpWidget(_login(loginCubit()));
      await tester.tap(find.text('Continuar com Apple'));
      await tester.pumpAndSettle();

      expect(repository.lastProvider, OAuthProvider.apple);
    });

    testWidgets('a failed sign-in shows the error banner', (tester) async {
      usePhoneSize(tester);
      await tester.pumpWidget(_login(loginCubit()));
      await tester.tap(find.text('Continuar com Google'));
      await tester.pumpAndSettle();

      expect(
        find.text('Algo deu errado, tente de novo mais tarde.'),
        findsOneWidget,
      );
    });

    testWidgets('a cancelled sign-in shows no error', (tester) async {
      usePhoneSize(tester);
      repository.loginResult = const Success(SignInCancelled());
      await tester.pumpWidget(_login(loginCubit()));
      await tester.tap(find.text('Continuar com Google'));
      await tester.pumpAndSettle();

      expect(
        find.text('Algo deu errado, tente de novo mais tarde.'),
        findsNothing,
      );
      expect(find.text('Continuar com Google'), findsOneWidget);
    });
  });

  group('ChooseNicknameScreen', () {
    for (final brightness in Brightness.values) {
      testWidgets('golden (${brightness.name})', (tester) async {
        usePhoneSize(tester);
        await tester.pumpWidget(
          _chooseNickname(chooseNicknameCubit(), brightness: brightness),
        );
        await settleSvgs(tester);

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/choose_nickname_${brightness.name}.png'),
        );
      });
    }

    testWidgets('prefills and checks the suggested nickname', (tester) async {
      usePhoneSize(tester);
      await tester.pumpWidget(
        _chooseNickname(chooseNicknameCubit(), suggestedNickname: 'Ana Clara'),
      );
      await tester.pump();

      expect(find.text('Ana Clara'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Apelido disponível'), findsOneWidget);
    });

    testWidgets('confirms an available nickname', (tester) async {
      usePhoneSize(tester);
      await tester.pumpWidget(_chooseNickname(chooseNicknameCubit()));
      await tester.enterText(field('Apelido'), 'vaquinha');
      await tester.pump();
      expect(find.text('Verificando disponibilidade…'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Apelido disponível'), findsOneWidget);
    });

    testWidgets('shows a taken nickname right away', (tester) async {
      usePhoneSize(tester);
      repository.nicknameResult = const Success(false);
      await tester.pumpWidget(_chooseNickname(chooseNicknameCubit()));
      await tester.enterText(field('Apelido'), 'vaquinha');
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Esse apelido já está em uso'), findsOneWidget);
    });
  });
}
