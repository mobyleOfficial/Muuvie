import 'package:auth_domain/domain.dart';
import 'package:auth_ui/login/login_cubit.dart';
import 'package:auth_ui/login/login_screen.dart';
import 'package:auth_ui/login/login_state.dart';
import 'package:auth_ui/sign_up/sign_up_cubit.dart';
import 'package:auth_ui/sign_up/sign_up_screen.dart';
import 'package:auth_ui/sign_up/sign_up_state.dart';
import 'package:auth_ui/widgets/auth_text_field.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/golden.dart';

class _FakeAuthRepository implements AuthRepository {
  Result<void> loginResult = const Failure(AppError.unauthorized);
  Result<bool> nicknameResult = const Success(true);

  @override
  Future<Result<void>> login(OAuthProvider provider) async => loginResult;

  @override
  Future<Result<void>> loginWithEmail(String email, String password) async =>
      loginResult;

  @override
  Future<Result<bool>> isUserAuthenticated() async => const Success(false);

  @override
  Future<Result<void>> logout() async => const Success(null);

  @override
  Stream<void> observeSessionEnded() => const Stream.empty();

  @override
  Future<Result<void>> signUp(
    String email,
    String password,
    String nickname,
  ) async => const Failure(AppError.conflict);

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

Widget _login(
  LoginCubit cubit, {
  VoidCallback? onSignUpTap,
  Brightness brightness = Brightness.light,
}) => _app(
  BlocProvider.value(
    value: cubit,
    child: BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) =>
          LoginScreen(state: state, onSignUpTap: onSignUpTap),
    ),
  ),
  brightness: brightness,
);

Widget _signUp(
  SignUpCubit cubit, {
  VoidCallback? onLoginTap,
  Brightness brightness = Brightness.light,
}) => _app(
  BlocProvider.value(
    value: cubit,
    child: BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state) =>
          SignUpScreen(state: state, onLoginTap: onLoginTap),
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
    loginWithEmailUseCase: LoginWithEmail(repository),
    isUserAuthenticatedUseCase: IsUserAuthenticated(repository),
  );

  SignUpCubit signUpCubit() => SignUpCubit(
    signUp: SignUp(repository),
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

    testWidgets('does not flag the e-mail while it is being typed', (
      tester,
    ) async {
      usePhoneSize(tester);
      await tester.pumpWidget(_login(loginCubit()));
      await tester.enterText(field('E-mail'), 'ana@');
      await tester.pump();

      expect(find.text('Por favor digite um e-mail válido'), findsNothing);
    });

    testWidgets('submitting shows field errors', (tester) async {
      usePhoneSize(tester);
      await tester.pumpWidget(_login(loginCubit()));
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Este campo é obrigatório'), findsNWidgets(2));
    });

    testWidgets('wrong credentials show the error banner', (tester) async {
      usePhoneSize(tester);
      await tester.pumpWidget(_login(loginCubit()));
      await tester.enterText(field('E-mail'), 'ana@muuvie.app');
      await tester.enterText(field('Senha'), '12345678');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Usuário ou senha incorretos.'), findsOneWidget);
    });

    testWidgets('create account link calls back', (tester) async {
      usePhoneSize(tester);
      var tapped = false;
      await tester.pumpWidget(
        _login(loginCubit(), onSignUpTap: () => tapped = true),
      );
      await tester.tap(find.text('Crie uma conta'));

      expect(tapped, isTrue);
    });
  });

  group('SignUpScreen', () {
    for (final brightness in Brightness.values) {
      testWidgets('golden (${brightness.name})', (tester) async {
        usePhoneSize(tester);
        await tester.pumpWidget(_signUp(signUpCubit(), brightness: brightness));
        await settleSvgs(tester);

        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/sign_up_${brightness.name}.png'),
        );
      });
    }

    testWidgets('confirms an available nickname', (tester) async {
      usePhoneSize(tester);
      await tester.pumpWidget(_signUp(signUpCubit()));
      await tester.enterText(field('Apelido'), 'vaquinha');
      await tester.pump();
      expect(find.text('Verificando disponibilidade…'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Apelido disponível'), findsOneWidget);
    });

    testWidgets('shows a taken nickname right away', (tester) async {
      usePhoneSize(tester);
      repository.nicknameResult = const Success(false);
      await tester.pumpWidget(_signUp(signUpCubit()));
      await tester.enterText(field('Apelido'), 'vaquinha');
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Esse apelido já está em uso'), findsOneWidget);
    });

    testWidgets('login link calls back', (tester) async {
      usePhoneSize(tester);
      var tapped = false;
      await tester.pumpWidget(
        _signUp(signUpCubit(), onLoginTap: () => tapped = true),
      );
      await tester.tap(find.widgetWithText(TextButton, 'Entrar'));

      expect(tapped, isTrue);
    });
  });
}
