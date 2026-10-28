import 'package:auto_route/auto_route.dart';
import 'package:onboarding_ui/onboarding_page.dart';

part 'onboarding_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class OnboardingRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [AutoRoute(page: OnboardingRoute.page)];
}
