import 'package:auto_route/auto_route.dart';
import 'package:cineclubes/cineclubes.dart' show CineClubeMovie;
import 'package:cineclubes_ui/detail/cineclube_detail_page.dart';
import 'package:cineclubes_ui/editor/cineclube_editor_page.dart';
import 'package:flutter/material.dart';

part 'cineclubes_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class CineClubesRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: CineClubeDetailRoute.page),
    AutoRoute(page: CineClubeEditorRoute.page),
  ];
}
