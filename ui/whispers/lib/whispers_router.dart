import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:whispers/conversation/conversation_page.dart';
import 'package:whispers/whispers_page.dart';

part 'whispers_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class WhispersRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: WhispersRoute.page),
    AutoRoute(page: ConversationRoute.page),
  ];
}
