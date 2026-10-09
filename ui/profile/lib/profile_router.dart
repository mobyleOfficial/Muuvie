import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:profile_ui/edit_profile/edit_profile_page.dart';
import 'package:profile_ui/profile_page.dart';
import 'package:profile_ui/tabs/lists/create_list/create_list_page.dart';

part 'profile_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class ProfileRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: ProfileRoute.page),
        AutoRoute(page: EditProfileRoute.page),
      ];
}