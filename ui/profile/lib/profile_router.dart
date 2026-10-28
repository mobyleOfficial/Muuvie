import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:profile/profile.dart';
import 'package:social_network/social_network.dart' show FollowList;
import 'package:profile_ui/edit_profile/edit_profile_page.dart';
import 'package:profile_ui/follows/follows_page.dart';
import 'package:profile_ui/member/highlights/highlights_editor_page.dart';
import 'package:profile_ui/profile_page.dart';
import 'package:profile_ui/retrospective/retrospective_page.dart';
import 'package:profile_ui/settings/settings_page.dart';
import 'package:profile_ui/tabs/shelves/add_movies_to_shelf_page.dart';
import 'package:profile_ui/tabs/shelves/movie_shelves_page.dart';
import 'package:profile_ui/tabs/shelves/saved_shelves_page.dart';
import 'package:profile_ui/tabs/shelves/shelf_detail/shelf_detail_page.dart';

part 'profile_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class ProfileRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: ProfileRoute.page),
    AutoRoute(page: EditProfileRoute.page),
    AutoRoute(page: AddMoviesToShelfRoute.page),
    AutoRoute(page: ShelfDetailRoute.page),
    AutoRoute(page: MovieShelvesRoute.page),
    AutoRoute(page: SavedShelvesRoute.page),
    AutoRoute(page: HighlightsEditorRoute.page),
    AutoRoute(page: FollowsRoute.page),
    AutoRoute(page: RetrospectiveRoute.page),
    AutoRoute(page: SettingsRoute.page),
  ];
}
