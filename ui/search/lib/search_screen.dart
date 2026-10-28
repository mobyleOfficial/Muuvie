import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:movies/movies.dart';
import 'package:movies_ui/movie_detail/movie_detail_router.dart';
import 'package:search/discover/catalog_movie_card.dart';
import 'package:search/discover/discover_hub.dart';
import 'package:search/discover/discover_list_page.dart';
import 'package:search/discover/programacao_search_list.dart';
import 'package:search/search_bloc.dart';
import 'package:search/search_state.dart';

class SearchScreen extends StatefulWidget {
  final SearchCubit cubit;

  const SearchScreen({super.key, required this.cubit});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSearchResults = false;
  bool _showRecent = false;
  bool _holdsBack = false;

  // Shelves, locadoras and people search on the backend; wait for a pause in typing.
  static const _queryDelay = Duration(milliseconds: 400);
  Timer? _queryTimer;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_updateVisibility);
    _searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_updateVisibility);
    _searchController.removeListener(_onTextChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _queryTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    _updateVisibility();
    _queryTimer?.cancel();
    _queryTimer = Timer(_queryDelay, () {
      final query = _searchController.text.trim();
      if (mounted && query != _query) setState(() => _query = query);
    });
  }

  void _updateVisibility() {
    final hasText = _searchController.text.isNotEmpty;
    // The back button leaves the field, then clears it, before leaving the tab.
    final holdsBack = _focusNode.hasFocus || hasText;
    if (_holdsBack != holdsBack) setState(() => _holdsBack = holdsBack);
    final showResults = hasText && (_showSearchResults || _focusNode.hasFocus);
    final showRecent = !hasText && _focusNode.hasFocus;
    if (showResults != _showSearchResults || showRecent != _showRecent) {
      setState(() {
        _showSearchResults = showResults;
        _showRecent = showRecent;
      });
    }
  }

  /// Keeps what was typed in the recent searches (F14.2).
  void _remember([String? query]) {
    final text = (query ?? _searchController.text).trim();
    if (text.isNotEmpty) GetIt.I<AddRecentSearch>()(text);
  }

  void _searchAgain(String query) {
    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _queryTimer?.cancel();
    setState(() => _query = query);
    widget.cubit.onSearchChanged(query);
    _remember(query);
  }

  void _onBack(bool didPop, Object? _) {
    if (didPop) return;
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      return;
    }
    _queryTimer?.cancel();
    _searchController.clear();
    setState(() => _query = '');
    widget.cubit.onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: !_holdsBack,
      onPopInvokedWithResult: _onBack,
      child: BlocProvider.value(
        value: widget.cubit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: MuuvieEditText(
                controller: _searchController,
                focusNode: _focusNode,
                placeholder: l10n?.searchHint ?? '',
                textInputAction: TextInputAction.search,
                onChanged: widget.cubit.onSearchChanged,
                onSubmitted: _remember,
              ),
            ),
            Expanded(
              child: _showSearchResults
                  ? _SearchResultsSection(
                      cubit: widget.cubit,
                      query: _query,
                      onOpenMovie: _remember,
                    )
                  : _showRecent
                  ? _RecentSearches(onTap: _searchAgain)
                  : const DiscoverHub(),
            ),
          ],
        ),
      ),
    );
  }
}

/// The last searches while the field is focused and empty; the hub when there
/// are none.
class _RecentSearches extends StatefulWidget {
  final ValueChanged<String> onTap;

  const _RecentSearches({required this.onTap});

  @override
  State<_RecentSearches> createState() => _RecentSearchesState();
}

class _RecentSearchesState extends State<_RecentSearches> {
  static const _shown = 10;

  late final Stream<List<RecentSearch>> _searches =
      GetIt.I<ObserveRecentSearches>()();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final remove = GetIt.I<RemoveRecentSearches>();

    return StreamBuilder<List<RecentSearch>>(
      stream: _searches,
      builder: (context, snapshot) {
        final searches = snapshot.data ?? const <RecentSearch>[];
        if (!snapshot.hasData) return const SizedBox.shrink();
        if (searches.isEmpty) return const DiscoverHub();

        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        l10n?.searchRecent ?? '',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => remove(),
                    child: Text(l10n?.searchClearRecent ?? ''),
                  ),
                ],
              ),
            ),
            for (final search in searches.take(_shown))
              ListTile(
                leading: ExcludeSemantics(
                  child: Icon(
                    Icons.history,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                title: Text(search.query),
                onTap: () => widget.onTap(search.query),
                trailing: IconButton(
                  tooltip: l10n?.searchRemoveRecent,
                  icon: const Icon(Icons.close),
                  onPressed: () => remove(search.id),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SearchResultsSection extends StatelessWidget {
  final SearchCubit cubit;

  /// The typed text, after the pause; people, shelves and locadoras search
  /// with it.
  final String query;
  final VoidCallback onOpenMovie;

  const _SearchResultsSection({
    required this.cubit,
    required this.query,
    required this.onOpenMovie,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          MuuvieTabBar(
            isScrollable: true,
            tabs: [
              l10n?.searchTabMovies ?? '',
              l10n?.searchTabPeople ?? '',
              l10n?.profileTabShelves ?? '',
              l10n?.profileTabLocadoras ?? '',
              l10n?.programacaoCineClubesTab ?? '',
              l10n?.programacaoMaratonasTab ?? '',
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                MuuvieKeepAliveTab(
                  child: _MoviesResultsTab(
                    cubit: cubit,
                    onOpenMovie: onOpenMovie,
                  ),
                ),
                MuuvieKeepAliveTab(
                  child: DiscoverList(
                    kind: DiscoverKind.profiles,
                    query: query,
                  ),
                ),
                MuuvieKeepAliveTab(
                  child: DiscoverList(kind: DiscoverKind.shelves, query: query),
                ),
                MuuvieKeepAliveTab(
                  child: DiscoverList(
                    kind: DiscoverKind.locadoras,
                    query: query,
                  ),
                ),
                MuuvieKeepAliveTab(
                  child: ProgramacaoSearchList(
                    kind: ProgramacaoKind.cineclubes,
                    query: query,
                  ),
                ),
                MuuvieKeepAliveTab(
                  child: ProgramacaoSearchList(
                    kind: ProgramacaoKind.maratonas,
                    query: query,
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

class _MoviesResultsTab extends StatelessWidget {
  final SearchCubit cubit;
  final VoidCallback onOpenMovie;

  const _MoviesResultsTab({required this.cubit, required this.onOpenMovie});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    Widget message(String text) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );

    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) => switch (state) {
        SearchSearching() => const Center(child: CircularProgressIndicator()),
        SearchResults(:final movies) =>
          movies.isEmpty
              ? message(l10n?.noResults ?? '')
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: movies.length,
                  separatorBuilder: (_, _) => Divider(
                    indent: 72,
                    height: 1,
                    color: colorScheme.outlineVariant,
                  ),
                  itemBuilder: (context, index) => _MovieResultTile(
                    movie: movies[index],
                    onOpen: onOpenMovie,
                  ),
                ),
        SearchError(:final message) => MuuvieEmptyState(
          illustration: MuuvieIllustration.error,
          title: l10n?.emptyStateErrorTitle ?? '',
          message: message,
        ),
        // The results only show with text, so idle means too few letters.
        SearchIdle() => message(l10n?.searchMinLetters ?? ''),
      },
    );
  }
}

/// Poster, title and year, with the viewer's rating label or Já assisti /
/// Quero ver at the end (F14.2).
class _MovieResultTile extends StatelessWidget {
  final Movie movie;
  final VoidCallback onOpen;

  const _MovieResultTile({required this.movie, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final year = movie.year;
    final me = movie.me;
    final rating = me?.rating;
    final status = me?.status;
    final empty = Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.movie, size: 20, color: colorScheme.onSurfaceVariant),
    );

    return InkWell(
      onTap: () {
        onOpen();
        context.router.push(
          MovieDetailRoute(movieId: movie.id, movieTitle: movie.title),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            ExcludeSemantics(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 44,
                  height: 64,
                  child: movie.posterPath.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: TmdbImageUrl.buildPosterSmall(
                            movie.posterPath,
                          ),
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            color: colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: (_, _, _) => empty,
                        )
                      : empty,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (year != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      year,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (rating != null) ...[
              const SizedBox(width: 8),
              MuuvieRatingBadge(rating: rating),
            ] else if (status != null) ...[
              const SizedBox(width: 8),
              Semantics(
                label: catalogStateLabel(l10n, me),
                child: ExcludeSemantics(child: CatalogStateMark(state: me!)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
