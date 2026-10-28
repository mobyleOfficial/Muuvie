import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:public_profile/public_profile_page.dart';

part 'public_profile_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class PublicProfileRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [AutoRoute(page: PublicProfileRoute.page)];
}
