import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:imports_ui/import_job/import_job_page.dart';
import 'package:imports_ui/import_start/import_start_page.dart';
import 'package:imports_ui/import_unmatched/import_unmatched_page.dart';

part 'imports_router.gr.dart';

@AutoRouterConfig(generateForDir: ['lib'])
class ImportsRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: ImportStartRoute.page),
    AutoRoute(page: ImportJobRoute.page),
    AutoRoute(page: ImportUnmatchedRoute.page),
  ];
}
