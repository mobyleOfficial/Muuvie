import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:auth/auth.dart';
import 'package:auth_ui/login/login_cubit.dart';
import 'package:auth_ui/login/login_state.dart';
import 'package:auth_ui/login/login_screen.dart';
import 'package:auth_ui/login_router.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginCubit _cubit = LoginCubit(
    loginUseCase: GetIt.I<Login>(),
    isUserAuthenticatedUseCase: GetIt.I<IsUserAuthenticated>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<LoginCubit>.value(
    value: _cubit,
    child: BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        switch (state) {
          case LoginAuthenticated():
            Navigator.of(context, rootNavigator: true).pop(true);
          case LoginNeedsNickname(:final suggestedNickname):
            context.router.replace(
              ChooseNicknameRoute(suggestedNickname: suggestedNickname),
            );
          case LoginLoading() || LoginFormState():
            break;
        }
      },
      builder: (context, state) => LoginScreen(state: state),
    ),
  );
}
