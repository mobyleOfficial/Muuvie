import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:movies_ui/person_detail/person_detail_page.dart';

part 'person_detail_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib/person_detail'])
class PersonDetailRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [AutoRoute(page: PersonDetailRoute.page)];
}
