import 'package:social/social_page.dart';
import 'package:auto_route/auto_route.dart';

part 'social_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class SocialRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [AutoRoute(page: SocialRoute.page)];
}
