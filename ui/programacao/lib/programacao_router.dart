import 'package:auto_route/auto_route.dart';
import 'package:programacao/programacao_page.dart';

part 'programacao_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class ProgramacaoRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [AutoRoute(page: ProgramacaoRoute.page)];
}
