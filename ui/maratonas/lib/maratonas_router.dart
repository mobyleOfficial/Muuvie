import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:maratonas_ui/detail/maratona_detail_page.dart';
import 'package:maratonas_ui/editor/maratona_editor_page.dart';

part 'maratonas_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class MaratonasRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: MaratonaDetailRoute.page),
    AutoRoute(page: MaratonaEditorRoute.page),
  ];
}
