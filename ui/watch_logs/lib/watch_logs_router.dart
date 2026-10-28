import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:watch_logs/watch_logs.dart';
import 'package:watch_logs_ui/history/movie_history_page.dart';
import 'package:watch_logs_ui/log_session/log_session_page.dart';
import 'package:watch_logs_ui/rating/rate_movie_page.dart';

part 'watch_logs_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class WatchLogsRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: LogSessionRoute.page),
    AutoRoute(page: RateMovieRoute.page),
    AutoRoute(page: MovieHistoryRoute.page),
  ];
}
