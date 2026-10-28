import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gamification_ui/diary/diary_page.dart';
import 'package:gamification_ui/missions/missions_page.dart';
import 'package:gamification_ui/party/watch_party_page.dart';
import 'package:gamification_ui/poster/poster_game_page.dart';
import 'package:gamification_ui/shelter/shelter_page.dart';

part 'gamification_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class GamificationRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: ShelterRoute.page),
    AutoRoute(page: MissionsRoute.page),
    AutoRoute(page: DiaryRoute.page),
    AutoRoute(page: WatchPartyRoute.page),
    AutoRoute(page: PosterGameRoute.page),
  ];
}
