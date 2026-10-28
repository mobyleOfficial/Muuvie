import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:auth_domain/usecases/sign_up.dart';
import 'package:auth_domain/usecases/check_nickname_availability.dart';
import 'package:auth_ui/sign_up/sign_up_cubit.dart';
import 'package:auth_ui/sign_up/sign_up_state.dart';
import 'package:auth_ui/sign_up/sign_up_screen.dart';

@RoutePage()
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final SignUpCubit _cubit = SignUpCubit(
    signUp: GetIt.I<SignUp>(),
    checkNicknameAvailability: GetIt.I<CheckNicknameAvailability>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<SignUpCubit>.value(
    value: _cubit,
    child: BlocConsumer<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state is SignUpSuccess) {
          Navigator.of(context, rootNavigator: true).pop(true);
        }
      },
      builder: (context, state) => SignUpScreen(state: state),
    ),
  );
}
