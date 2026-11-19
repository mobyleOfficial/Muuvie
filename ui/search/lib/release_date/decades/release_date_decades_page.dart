import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';

import 'package:search/search_router.dart';
import 'package:search/release_date/decades/release_date_decades_screen.dart';

@RoutePage()
class ReleaseDateDecadesPage extends StatelessWidget {
  const ReleaseDateDecadesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    return ReleaseDateDecadesScreen(
      onUpcomingTap: () => context.router.push(
        ReleaseDateMoviesRoute(
          title: AppLocalizations.of(context)?.releaseDateUpcoming ?? '',
          releaseDateGte: today,
          sortBy: 'primary_release_date.asc',
        ),
      ),
      onDecadeTap: (decade, label) => context.router.push(
        ReleaseDateYearsRoute(decade: decade, decadeLabel: label),
      ),
    );
  }
}
