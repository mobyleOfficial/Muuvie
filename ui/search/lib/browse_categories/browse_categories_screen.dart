import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movies/movies.dart';

import 'package:search/browse_categories/browse_categories_bloc.dart';
import 'package:search/browse_categories/browse_categories_state.dart';

class BrowseCategoriesScreen extends StatelessWidget {
  final BrowseCategoriesCubit cubit;
  final void Function(Genre genre) onGenreTap;
  final void Function(Country country) onCountryTap;
  final void Function(Language language) onLanguageTap;

  const BrowseCategoriesScreen({
    super.key,
    required this.cubit,
    required this.onGenreTap,
    required this.onCountryTap,
    required this.onLanguageTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: BlocProvider.value(
        value: cubit,
        child: BlocBuilder<BrowseCategoriesCubit, BrowseCategoriesState>(
          builder: (context, state) => switch (state) {
            BrowseCategoriesLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            BrowseCategoriesError(:final message) => MuuvieEmptyState(
              title: l10n?.emptyStateErrorTitle ?? '',
              message: message,
              action: cubit.reload,
              actionLabel: l10n?.emptyStateRetry ?? '',
            ),
            BrowseCategoriesSuccess() => _Content(
              state: state,
              onGenreTap: onGenreTap,
              onCountryTap: onCountryTap,
              onLanguageTap: onLanguageTap,
            ),
          },
        ),
      ),
    );
  }
}

class _Content extends StatefulWidget {
  final BrowseCategoriesSuccess state;
  final void Function(Genre genre) onGenreTap;
  final void Function(Country country) onCountryTap;
  final void Function(Language language) onLanguageTap;

  const _Content({
    required this.state,
    required this.onGenreTap,
    required this.onCountryTap,
    required this.onLanguageTap,
  });

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          MuuvieTabBar(
            tabs: [
              l10n?.searchBrowseGenre ?? '',
              l10n?.searchBrowseCountry ?? '',
              l10n?.searchBrowseLanguage ?? '',
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                MuuvieKeepAliveTab(
                  child: _CategoryList<Genre>(
                    items: widget.state.genres,
                    labelBuilder: (genre) => genre.name,
                    onTap: widget.onGenreTap,
                  ),
                ),
                MuuvieKeepAliveTab(
                  child: _CategoryList<Country>(
                    items: widget.state.countries,
                    labelBuilder: (country) => country.name,
                    onTap: widget.onCountryTap,
                  ),
                ),
                MuuvieKeepAliveTab(
                  child: _CategoryList<Language>(
                    items: widget.state.languages,
                    labelBuilder: (language) => language.name,
                    onTap: widget.onLanguageTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryList<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T item) labelBuilder;
  final void Function(T item) onTap;

  const _CategoryList({
    super.key,
    required this.items,
    required this.labelBuilder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(labelBuilder(item)),
          trailing: Icon(
            Icons.chevron_right,
            color: colorScheme.onSurfaceVariant,
          ),
          onTap: () => onTap(item),
        );
      },
    );
  }
}
