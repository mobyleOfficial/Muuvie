import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:search/search_router.dart';
import 'package:search/release_date/years/release_date_years_screen.dart';

@RoutePage()
class ReleaseDateYearsPage extends StatelessWidget {
  final int decade;
  final String decadeLabel;

  const ReleaseDateYearsPage({
    super.key,
    required this.decade,
    required this.decadeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ReleaseDateYearsScreen(
      decade: decade,
      onAnyTap: () => context.router.push(
        ReleaseDateMoviesRoute(
          title: decadeLabel,
          releaseDateGte: '$decade-01-01',
          releaseDateLte: '${decade + 9}-12-31',
        ),
      ),
      onYearTap: (year) => context.router.push(
        ReleaseDateMoviesRoute(title: '$year', primaryReleaseYear: year),
      ),
    );
  }
}
