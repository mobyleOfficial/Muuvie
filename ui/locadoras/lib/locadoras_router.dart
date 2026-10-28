import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:locadoras_ui/locadora_detail/locadora_detail_page.dart';
import 'package:locadoras_ui/pick_shelves/pick_shelves_page.dart';
import 'package:shelves/shelves.dart';

part 'locadoras_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class LocadorasRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LocadoraDetailRoute.page),
    AutoRoute(page: PickLocadoraShelvesRoute.page),
  ];
}
