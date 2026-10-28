import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';

import 'package:search/browse_categories/browse_categories_bloc.dart';
import 'package:search/browse_categories/browse_categories_screen.dart';
import 'package:search/search_router.dart';

@RoutePage()
class BrowseCategoriesPage extends StatefulWidget {
  const BrowseCategoriesPage({super.key});

  @override
  State<BrowseCategoriesPage> createState() => _BrowseCategoriesPageState();
}

class _BrowseCategoriesPageState extends State<BrowseCategoriesPage> {
  late final BrowseCategoriesCubit _cubit = BrowseCategoriesCubit(
    GetIt.I<GetGenres>(),
    GetIt.I<GetCountries>(),
    GetIt.I<GetLanguages>(),
  );

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BrowseCategoriesScreen(
    cubit: _cubit,
    onGenreTap: (genre) => context.router.push(
      ReleaseDateMoviesRoute(title: genre.name, withGenres: '${genre.id}'),
    ),
    onCountryTap: (country) => context.router.push(
      ReleaseDateMoviesRoute(
        title: country.name,
        withOriginCountry: country.iso,
      ),
    ),
    onLanguageTap: (language) => context.router.push(
      ReleaseDateMoviesRoute(
        title: language.name,
        withOriginalLanguage: language.iso,
      ),
    ),
  );
}
