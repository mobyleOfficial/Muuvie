import 'package:auto_route/auto_route.dart';
import 'package:common/common.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:profile/profile.dart';
import 'package:shelves/shelves.dart';

import 'package:search/discover/discover_widgets.dart';

/// What a discovery list shows.
enum DiscoverKind { shelves, locadoras, profiles }

/// "Ver tudo" of a section of the discovery hub (F5.6), or the people,
/// shelves and locadoras tabs of the search results when [query] is set.
@RoutePage()
class DiscoverListPage extends StatefulWidget {
  final DiscoverKind kind;
  final String? query;

  const DiscoverListPage({super.key, required this.kind, this.query});

  @override
  State<DiscoverListPage> createState() => _DiscoverListPageState();
}

class _DiscoverListPageState extends State<DiscoverListPage> {
  @override
  Widget build(BuildContext context) =>
      DiscoverList(kind: widget.kind, query: widget.query);
}

/// The paged list behind [DiscoverListPage]; also embedded in the search tabs.
class DiscoverList extends StatefulWidget {
  final DiscoverKind kind;
  final String? query;

  const DiscoverList({super.key, required this.kind, this.query});

  @override
  State<DiscoverList> createState() => _DiscoverListState();
}

class _DiscoverListState extends State<DiscoverList> {
  bool _hasNext = true;

  late final PagingController<int, Object> _pagingController = PagingController(
    getNextPageKey: (state) => _hasNext ? state.nextIntPageKey : null,
    fetchPage: _fetchPage,
  );

  Future<List<Object>> _fetchPage(int page) async {
    final params = DiscoverParams(query: widget.query, page: page);
    final Result<Paged<Object>> result = switch (widget.kind) {
      DiscoverKind.shelves => await GetIt.I<DiscoverShelves>()(params),
      DiscoverKind.locadoras => await GetIt.I<DiscoverLocadoras>()(params),
      DiscoverKind.profiles => await GetIt.I<DiscoverProfiles>()(params),
    };
    switch (result) {
      case Success(:final data):
        _hasNext = data.hasNext;
        return data.items;
      case Failure(:final error):
        throw Exception(error.message);
    }
  }

  @override
  void didUpdateWidget(DiscoverList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _hasNext = true;
      _pagingController.refresh();
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => PagedListView<int, Object>(
        state: state,
        fetchNextPage: fetchNextPage,
        padding: const EdgeInsets.symmetric(vertical: 8),
        builderDelegate: PagedChildBuilderDelegate<Object>(
          itemBuilder: (context, item, index) => switch (item) {
            Shelf() => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: DiscoveredShelfCard(shelf: item),
            ),
            Locadora() => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: DiscoveredLocadoraCard(locadora: item),
            ),
            ProfileCard() => DiscoveredProfileTile(profile: item),
            _ => const SizedBox.shrink(),
          },
          firstPageProgressIndicatorBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          firstPageErrorIndicatorBuilder: (_) => MuuvieEmptyState(
            illustration: MuuvieIllustration.error,
            title: l10n?.emptyStateErrorTitle ?? '',
            message: l10n?.emptyStateErrorMessage ?? '',
            action: fetchNextPage,
            actionLabel: l10n?.emptyStateRetry ?? '',
          ),
          noItemsFoundIndicatorBuilder: (_) => MuuvieEmptyState(
            illustration: MuuvieIllustration.search,
            title: l10n?.emptyStateNoItemsTitle ?? '',
            message: l10n?.discoverEmpty ?? '',
          ),
        ),
      ),
    );
  }
}
