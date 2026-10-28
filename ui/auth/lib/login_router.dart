import 'package:auto_route/auto_route.dart';
import 'package:auth_ui/login/login_page.dart';
import 'package:auth_ui/sign_up/sign_up_page.dart';

part 'login_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class LoginRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: SignUpRoute.page),
  ];
}
