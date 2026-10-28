import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shelves_ui/add_to_shelves/add_to_shelves_page.dart';

part 'shelves_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class ShelvesRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [AutoRoute(page: AddToShelvesRoute.page)];
}
