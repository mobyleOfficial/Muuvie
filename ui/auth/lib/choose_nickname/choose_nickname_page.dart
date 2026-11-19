import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:auth_domain/usecases/check_nickname_availability.dart';
import 'package:auth_domain/usecases/choose_nickname.dart';
import 'package:auth_ui/choose_nickname/choose_nickname_cubit.dart';
import 'package:auth_ui/choose_nickname/choose_nickname_state.dart';
import 'package:auth_ui/choose_nickname/choose_nickname_screen.dart';

/// Shown right after the first sign-in of a new account, which already has a
/// session (and a generated nickname). Closing it keeps that nickname; the
/// next sign-in asks again.
@RoutePage()
class ChooseNicknamePage extends StatefulWidget {
  final String? suggestedNickname;

  const ChooseNicknamePage({super.key, this.suggestedNickname});

  @override
  State<ChooseNicknamePage> createState() => _ChooseNicknamePageState();
}

class _ChooseNicknamePageState extends State<ChooseNicknamePage> {
  late final ChooseNicknameCubit _cubit = ChooseNicknameCubit(
    chooseNickname: GetIt.I<ChooseNickname>(),
    checkNicknameAvailability: GetIt.I<CheckNicknameAvailability>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<ChooseNicknameCubit>.value(
    value: _cubit,
    child: BlocConsumer<ChooseNicknameCubit, ChooseNicknameState>(
      listener: (context, state) {
        if (state is ChooseNicknameSuccess) {
          Navigator.of(context, rootNavigator: true).pop(true);
        }
      },
      builder: (context, state) => ChooseNicknameScreen(
        state: state,
        suggestedNickname: widget.suggestedNickname,
      ),
    ),
  );
}
