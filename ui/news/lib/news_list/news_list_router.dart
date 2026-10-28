import 'package:auto_route/auto_route.dart';
import 'package:news_ui/news_list/news_list_page.dart';

part 'news_list_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib/news_list'])
class NewsListRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [AutoRoute(page: NewsListRoute.page)];
}
