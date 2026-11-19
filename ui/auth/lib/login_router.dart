import 'package:auto_route/auto_route.dart';
import 'package:auth_ui/login/login_page.dart';
import 'package:auth_ui/choose_nickname/choose_nickname_page.dart';
import 'package:flutter/material.dart';

part 'login_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class LoginRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: ChooseNicknameRoute.page),
  ];
}
